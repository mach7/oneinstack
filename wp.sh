#!/bin/bash
# WordPress site provisioning helper for OneinStack
# - Creates Nginx/Apache vhost for PHP-FPM
# - Downloads and configures WordPress
# - Issues and installs Let's Encrypt TLS cert (http-01 by default)
# - Can be run non-interactively via flags or environment variables

set -euo pipefail

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

# Root check
if [ "$(id -u)" != "0" ]; then
  echo "Error: You must be root to run this script" >&2
  exit 1
fi

oneinstack_dir=$(dirname "$(readlink -f "$0")")
pushd "${oneinstack_dir}" > /dev/null
. ./options.conf
. ./include/color.sh
. ./include/check_os.sh
. ./include/check_dir.sh

show_help() {
  cat <<'EOF'
Usage: ./wp.sh [options]
  --domain DOMAIN           Primary domain (required)
  --aliases "a.example.com b.example.com"   Space-separated domain aliases
  --root DIR                Web root (default: ${wwwroot_dir}/<domain>)
  --php_ver [53~81]         Use specific PHP-FPM socket version (if multi-PHP)
  --email EMAIL             Email for ACME registration
  --no-ssl                  Do not enable HTTPS/Let’s Encrypt
  --dnsapi PROVIDER         Use ACME DNS API (e.g., cf, ali). Requires env exports.
  --db_name NAME            Database name (optional)
  --db_user USER            Database user (optional)
  --db_pass PASS            Database password (optional)
  --db_host HOST            Database host (default: 127.0.0.1)
  --title TITLE             WordPress site title (optional for wp-cli)
  --admin_user USERNAME     WordPress admin username (optional for wp-cli)
  --admin_pass PASSWORD     WordPress admin password (optional for wp-cli)
  --admin_email EMAIL       WordPress admin email (optional for wp-cli)
  --quiet, -q               Quiet operation (less prompts)

Examples:
  ./wp.sh --domain example.com --aliases "www.example.com" --email admin@example.com
  ./wp.sh --domain blog.example.com --no-ssl --db_name wp_blog --db_user wp_blog --db_pass secret
EOF
}

ARG_NUM=$#
TEMP=$(getopt -o hq --long help,quiet,domain:,aliases:,root:,php_ver:,email:,no-ssl,dnsapi:,db_name:,db_user:,db_pass:,db_host:,title:,admin_user:,admin_pass:,admin_email: -- "$@" 2>/dev/null) || { echo "ERROR: unknown argument"; show_help; exit 1; }
eval set -- "$TEMP"

quiet_flag=
no_ssl_flag=
dnsapi=
php_ver=
domain=
aliases=
root_dir=
email=
db_name=
db_user=
db_pass=
db_host=
wp_title=
wp_admin_user=
wp_admin_pass=
wp_admin_email=

while :; do
  [ -z "$1" ] && break
  case "$1" in
    -h|--help) show_help; exit 0 ;;
    -q|--quiet) quiet_flag=y; shift 1 ;;
    --domain) domain=$2; shift 2 ;;
    --aliases) aliases=$2; shift 2 ;;
    --root) root_dir=$2; shift 2 ;;
    --php_ver) php_ver=$2; shift 2 ;;
    --email) email=$2; shift 2 ;;
    --no-ssl) no_ssl_flag=y; shift 1 ;;
    --dnsapi) dnsapi=$2; shift 2 ;;
    --db_name) db_name=$2; shift 2 ;;
    --db_user) db_user=$2; shift 2 ;;
    --db_pass) db_pass=$2; shift 2 ;;
    --db_host) db_host=$2; shift 2 ;;
    --title) wp_title=$2; shift 2 ;;
    --admin_user) wp_admin_user=$2; shift 2 ;;
    --admin_pass) wp_admin_pass=$2; shift 2 ;;
    --admin_email) wp_admin_email=$2; shift 2 ;;
    --) shift ;;
    *) echo "ERROR: unknown argument"; show_help; exit 1 ;;
  esac
done

# Validate inputs
[ -z "$domain" ] && { echo "ERROR: --domain is required"; show_help; exit 1; }
root_dir=${root_dir:-"${wwwroot_dir}/${domain}"}
db_host=${db_host:-127.0.0.1}

# Determine environment (Nginx vs Apache) and PHP socket
if [ -e "${web_install_dir}/sbin/nginx" ]; then
  web_is_nginx=y
fi
if [ -e "${apache_install_dir}/bin/httpd" ]; then
  web_is_apache=y
fi

# PHP socket path: if multi-php specified, otherwise default
php_sock="/dev/shm/php-cgi.sock"
if [ -n "$php_ver" ]; then
  php_sock="/dev/shm/php${php_ver}-cgi.sock"
fi

# Prepare directories and vhost
mkdir -p "$root_dir"
chown -R ${run_user}:${run_group} "$root_dir"

# Install acme.sh if SSL requested and not found
need_ssl=y
[ -n "$no_ssl_flag" ] && need_ssl=
if [ -n "$need_ssl" ] && [ ! -e ~/.acme.sh/acme.sh ]; then
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e acme.sh-master.tar.gz ] && wget -qc http://mirrors.linuxeye.com/oneinstack/src/acme.sh-master.tar.gz
  tar xzf acme.sh-master.tar.gz
  pushd acme.sh-master > /dev/null
  ./acme.sh --install > /dev/null 2>&1
  popd > /dev/null
  popd > /dev/null
fi
[ -e ~/.acme.sh/account.conf ] && sed -i '/^CERT_HOME=/d' ~/.acme.sh/account.conf

# Create Nginx or Apache vhost
moredomainame=""
[ -n "$aliases" ] && moredomainame=" $(echo "$aliases")"

if [ -n "$web_is_nginx" ]; then
  # Build common server block
  [ ! -d ${web_install_dir}/conf/vhost ] && mkdir -p ${web_install_dir}/conf/vhost
  [ ! -d ${web_install_dir}/conf/rewrite ] && mkdir -p ${web_install_dir}/conf/rewrite
  # WordPress rewrite
  cp -f config/wordpress.conf ${web_install_dir}/conf/rewrite/wordpress.conf 2>/dev/null || echo -e "location / {
    try_files \$uri \$uri/ /index.php?$args;
  }" > ${web_install_dir}/conf/rewrite/wordpress.conf

  # Base server block (http)
  cat > ${web_install_dir}/conf/vhost/${domain}.conf << EOF
server {
  listen 80;
  server_name ${domain}${moredomainame};
  access_log ${wwwlogs_dir}/${domain}_nginx.log combined;
  root ${root_dir};
  index index.php index.html index.htm;
  include ${web_install_dir}/conf/rewrite/wordpress.conf;
  location ~ \.php$ {
    fastcgi_pass unix:${php_sock};
    fastcgi_index index.php;
    include fastcgi.conf;
  }
  location /.well-known {
    allow all;
  }
}
EOF
  ${web_install_dir}/sbin/nginx -t && ${web_install_dir}/sbin/nginx -s reload || { rm -f ${web_install_dir}/conf/vhost/${domain}.conf; echo "Failed to reload Nginx"; exit 1; }

elif [ -n "$web_is_apache" ]; then
  [ ! -d ${apache_install_dir}/conf/vhost ] && mkdir -p ${apache_install_dir}/conf/vhost
  Apache_fcgi=""
  if [ -e "${php_install_dir}/sbin/php-fpm" ] && grep -Eq '^LoadModule.*mod_proxy_fcgi.so' ${apache_install_dir}/conf/httpd.conf; then
    Apache_fcgi=$(cat <<APCFGI
  <FilesMatch \.php$>
    SetHandler "proxy:unix:${php_sock}|fcgi://localhost"
  </FilesMatch>
APCFGI
)
  fi
  cat > ${apache_install_dir}/conf/vhost/${domain}.conf << EOF
<VirtualHost *:80>
  ServerAdmin admin@example.com
  DocumentRoot "${root_dir}"
  ServerName ${domain}
  $( [ -n "$moredomainame" ] && echo "ServerAlias${moredomainame}" )
  ErrorLog "${wwwlogs_dir}/${domain}_error_apache.log"
  CustomLog "${wwwlogs_dir}/${domain}_apache.log" common
${Apache_fcgi}
  <Directory "${root_dir}">
    Options FollowSymLinks ExecCGI
    AllowOverride All
    Require all granted
    DirectoryIndex index.php index.html index.htm
  </Directory>
</VirtualHost>
EOF
  ${apache_install_dir}/bin/apachectl -t && ${apache_install_dir}/bin/apachectl -k graceful || { rm -f ${apache_install_dir}/conf/vhost/${domain}.conf; echo "Failed to reload Apache"; exit 1; }
else
  echo "Error: No web server found (Nginx or Apache). Run ./setup.sh first." >&2
  exit 1
fi

# Obtain Let’s Encrypt cert and enable HTTPS
if [ -n "$need_ssl" ]; then
  PATH_SSL="${web_install_dir}/conf/ssl"
  if [ -n "$web_is_apache" ] && [ ! -n "$web_is_nginx" ]; then
    PATH_SSL="${apache_install_dir}/conf/ssl"
  fi
  mkdir -p "$PATH_SSL"

  if [ -n "$dnsapi" ]; then
    if [ -n "$email" ] && [ ! -e ~/.acme.sh/ca/acme.zerossl.com/account.key ]; then
      ~/.acme.sh/acme.sh --register-account -m "$email"
    fi
    more_D=""
    for D in $aliases; do more_D="$more_D -d $D"; done
    ~/.acme.sh/acme.sh --force --listen-v4 --issue --dns dns_${dnsapi} -d ${domain} ${more_D}
  else
    # http-01 via webroot
    more_D=""
    for D in $aliases; do more_D="$more_D -d $D"; done
    ~/.acme.sh/acme.sh --force --listen-v4 --issue -d ${domain} ${more_D} -w ${root_dir}
  fi

  if [ -s ~/.acme.sh/${domain}/fullchain.cer ]; then
    [ -e "${PATH_SSL}/${domain}.crt" ] && rm -f ${PATH_SSL}/${domain}.{crt,key}
    ReloadCmd=""
    if [ -n "$web_is_nginx" ]; then
      [ -e /bin/systemctl -a -e /lib/systemd/system/nginx.service ] && ReloadCmd='/bin/systemctl restart nginx' || ReloadCmd='/etc/init.d/nginx force-reload'
    elif [ -n "$web_is_apache" ]; then
      ReloadCmd="${apache_install_dir}/bin/apachectl -k graceful"
    fi
    ~/.acme.sh/acme.sh --force --install-cert -d ${domain} --fullchain-file ${PATH_SSL}/${domain}.crt --key-file ${PATH_SSL}/${domain}.key --reloadcmd "${ReloadCmd}" > /dev/null

    # Append SSL to vhost
    if [ -n "$web_is_nginx" ]; then
      if ${web_install_dir}/sbin/nginx -V 2>&1 | grep -Eq 'with-http_v2_module'; then
        LISTENOPT="443 ssl http2"
      else
        LISTENOPT="443 ssl spdy"
      fi
      sed -i "s@^server_name.*;@&\n  listen ${LISTENOPT};\n  ssl_certificate ${PATH_SSL}/${domain}.crt;\n  ssl_certificate_key ${PATH_SSL}/${domain}.key;\n  ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;\n  ssl_ciphers TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:\!MD5;\n  ssl_prefer_server_ciphers on;\n  ssl_session_timeout 10m;\n  ssl_session_cache builtin:1000 shared:SSL:10m;\n  add_header Strict-Transport-Security max-age=15768000;\n  ssl_stapling on;\n  ssl_stapling_verify on;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  root.*;@&\n  if (\$ssl_protocol = \"\") { return 301 https://\$host\$request_uri; }@" ${web_install_dir}/conf/vhost/${domain}.conf || true
      ${web_install_dir}/sbin/nginx -t && ${web_install_dir}/sbin/nginx -s reload
    else
      # Apache 443 vhost snippet
      [ -z "$(grep 'Listen 443' ${apache_install_dir}/conf/httpd.conf)" ] && sed -i "s@Listen 80@&\nListen 443@" ${apache_install_dir}/conf/httpd.conf
      [ -z "$(grep 'ServerName 0.0.0.0:443' ${apache_install_dir}/conf/httpd.conf)" ] && sed -i "s@ServerName 0.0.0.0:80@&\nServerName 0.0.0.0:443@" ${apache_install_dir}/conf/httpd.conf
      cat >> ${apache_install_dir}/conf/vhost/${domain}.conf << EOF
<VirtualHost *:443>
  ServerAdmin admin@example.com
  DocumentRoot "${root_dir}"
  ServerName ${domain}
  $( [ -n "$moredomainame" ] && echo "ServerAlias${moredomainame}" )
  SSLEngine on
  SSLCertificateFile "${PATH_SSL}/${domain}.crt"
  SSLCertificateKeyFile "${PATH_SSL}/${domain}.key"
  ErrorLog "${wwwlogs_dir}/${domain}_error_apache.log"
  CustomLog "${wwwlogs_dir}/${domain}_apache.log" common
${Apache_fcgi}
  <Directory "${root_dir}">
    Options FollowSymLinks ExecCGI
    AllowOverride All
    Require all granted
    DirectoryIndex index.php index.html index.htm
  </Directory>
</VirtualHost>
EOF
      ${apache_install_dir}/bin/apachectl -t && ${apache_install_dir}/bin/apachectl -k graceful
    fi
  else
    echo "Failed to obtain Let's Encrypt certificate for ${domain}" >&2
  fi
fi

# Download and configure WordPress
pushd "$root_dir" > /dev/null
if [ ! -f wp-load.php ]; then
  echo "==> Downloading WordPress"
  curl -fsSL -o latest.tar.gz https://wordpress.org/latest.tar.gz
  tar -xzf latest.tar.gz --strip-components=1
  rm -f latest.tar.gz
fi

# Create wp-config.php if db params provided
if [ -n "${db_name:-}" ] && [ -n "${db_user:-}" ] && [ -n "${db_pass:-}" ]; then
  if [ ! -f wp-config.php ]; then
    cp wp-config-sample.php wp-config.php
    sed -i "s/database_name_here/${db_name}/" wp-config.php
    sed -i "s/username_here/${db_user}/" wp-config.php
    sed -i "s/password_here/${db_pass}/" wp-config.php
    sed -i "s/localhost/${db_host}/" wp-config.php
    # Generate salts
    perl -i -pe 'BEGIN {@c=("a".."z","A".."Z",0..9); push @c, split //, "!@#\$%^&*()-_ []{}<>~`+=,.;:/?|"; sub s0 { join "", map $c[rand @c], 1..64 }} s/put your unique phrase here/s0()/ge' wp-config.php
  fi
fi

chown -R ${run_user}:${run_group} .

popd > /dev/null

printf "\n${CMSG}WordPress provisioning complete for ${domain}.${CEND}\n"
[ -n "$need_ssl" ] && echo "HTTPS enabled via Let's Encrypt."
[ -n "$aliases" ] && echo "Aliases: $aliases"


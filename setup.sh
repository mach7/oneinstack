#!/bin/bash
# WordPress server environment setup (OneinStack)
# Installs Nginx + PHP-FPM + MySQL + common PHP extensions + optional Redis + phpMyAdmin
# Non-interactive defaults tuned for WordPress. Safe to re-run; it skips installed components.

set -euo pipefail

# Resolve project root and ensure we run from there
ONEINSTACK_DIR=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
cd "$ONEINSTACK_DIR"

# Friendly banner similar to install.sh
[ -t 1 ] && [ -n "$TERM" ] && clear
printf "\n#######################################################################\n"
printf "#       OneinStack WordPress setup (non-interactive helper)           #\n"
printf "#       Uses install.sh under the hood with sensible defaults         #\n"
printf "#######################################################################\n\n"

echo "[setup] Starting setup.sh in $ONEINSTACK_DIR"

# Guard: require root
if [ "$(id -u)" != "0" ]; then
  echo "Error: You must be root to run this script" >&2
  exit 1
fi

# Load shared config if present to honor directories and paths
[ -f "$ONEINSTACK_DIR/options.conf" ] && { echo "[setup] Loading options.conf"; . "$ONEINSTACK_DIR/options.conf"; }
echo "[setup] Defaults and environment detection"

#
# Defaults (can be overridden via environment variables when invoking this script)
#
: "${WP_NGINX_OPTION:=1}"          # 1=Nginx, 2=Tengine, 3=OpenResty
: "${WP_APACHE:=n}"                # y to install Apache (defaults to Nginx only)
: "${WP_PHP_OPTION:=13}"           # 13=PHP 8.3, 14=PHP 8.4
: "${WP_DB_OPTION:=1}"             # 1=MySQL 8.4 (LTS)
: "${WP_DBROOTPWD:=}"
: "${WP_PHP_EXTENSIONS:=imagick,redis}" # Common for WP: imagick + redis (APCu/OPcache handled separately)
: "${WP_PHP_CACHE:=1}"             # 1=OPcache, 2=APCu
: "${WP_INSTALL_REDIS:=y}"         # Install Redis server
: "${WP_INSTALL_MEMCACHED:=n}"
: "${WP_INSTALL_PHPMYADMIN:=y}"
: "${WP_NODE:=n}"                  # Node is generally not required for core WP
: "${WP_REBOOT:=n}"

# Generate a strong DB password if not provided
if [ -z "$WP_DBROOTPWD" ]; then
  if command -v tr >/dev/null 2>&1; then
    # Fallback-safe generator; locale independent
    WP_DBROOTPWD=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c16 || true)
  fi
  if [ -z "${WP_DBROOTPWD:-}" ]; then
    # Final fallback to openssl if tr failed
    if command -v openssl >/dev/null 2>&1; then
      WP_DBROOTPWD=$(openssl rand -base64 18 | tr -dc 'A-Za-z0-9' | head -c16)
    else
      # Last resort static (warn)
      echo "[setup] WARNING: could not generate random password; using weak default" >&2
      WP_DBROOTPWD="ChangeMe12345678"
    fi
  fi
fi

echo "==> Setting up WordPress-ready environment with OneinStack"
echo "    Web: option=$WP_NGINX_OPTION  PHP option=$WP_PHP_OPTION  DB option=$WP_DB_OPTION"
echo "    PHP extensions: $WP_PHP_EXTENSIONS  PHP cache=$WP_PHP_CACHE"
echo "    Extras: redis=$WP_INSTALL_REDIS memcached=$WP_INSTALL_MEMCACHED phpMyAdmin=$WP_INSTALL_PHPMYADMIN"

# Build CLI arguments for install.sh
args=(
  --nginx_option "$WP_NGINX_OPTION"
  --php_option "$WP_PHP_OPTION"
  --phpcache_option "$WP_PHP_CACHE"
  --php_extensions "$WP_PHP_EXTENSIONS"
  --db_option "$WP_DB_OPTION"
  --dbrootpwd "$WP_DBROOTPWD"
)

if [ "$WP_APACHE" = "y" ]; then
  # Default Apache mode: php-fpm, MPM: event
  args+=( --apache --apache_mode_option 1 --apache_mpm_option 1 )
fi

[ "$WP_NODE" = "y" ] && args+=( --node )
[ "$WP_INSTALL_REDIS" = "y" ] && args+=( --redis )
[ "$WP_INSTALL_MEMCACHED" = "y" ] && args+=( --memcached )
[ "$WP_INSTALL_PHPMYADMIN" = "y" ] && args+=( --phpmyadmin )
[ "$WP_REBOOT" = "y" ] && args+=( --reboot )

# Run installer non-interactively
echo
echo "==> Running installer"
echo -n "    Command: bash install.sh"; for a in "${args[@]}"; do printf ' %q' "$a"; done; echo

# Guard: ensure install.sh exists
if [ ! -f ./install.sh ]; then
  echo "[setup] ERROR: install.sh not found in $ONEINSTACK_DIR" >&2
  exit 1
fi

# Force line-buffered stdout/stderr so progress is visible immediately
if command -v stdbuf >/dev/null 2>&1; then
  stdbuf -oL -eL bash ./install.sh "${args[@]}"
else
  bash ./install.sh "${args[@]}"
fi

echo
echo "==> Environment ready"
echo "MySQL root password: $WP_DBROOTPWD"
echo "Next: use ./wp.sh to add a vhost, install WordPress, and enable Let's Encrypt."


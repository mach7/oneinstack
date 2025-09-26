[![PayPal donate button](https://img.shields.io/badge/paypal-donate-green.svg)](https://paypal.me/yeho) [![支付宝捐助按钮](https://img.shields.io/badge/%E6%94%AF%E4%BB%98%E5%AE%9D-%E5%90%91TA%E6%8D%90%E5%8A%A9-green.svg)](https://static.oneinstack.com/images/alipay.png) [![微信捐助按钮](https://img.shields.io/badge/%E5%BE%AE%E4%BF%A1-%E5%90%91TA%E6%8D%90%E5%8A%A9-green.svg)](https://static.oneinstack.com/images/weixin.png)

This script is written using the shell, in order to quickly deploy `LEMP`/`LAMP`/`LNMP`/`LNMPA`/`LTMP` (Linux, Nginx/Tengine/OpenResty, MySQL/PostgreSQL, PHP, JAVA), applicable to Rocky/Alma/RHEL 8 ~ 9, Debian 10 ~ 12, Ubuntu 20.04 ~ 24.04, Fedora 27+ of 32 and 64.

Script properties:
- Continually updated, Provide Shell Interaction and Autoinstall
- Source compiler installation, most stable source is the latest version, and download from the official site
- Some security optimization
- Providing databases: MySQL 8.4 (LTS) and PostgreSQL (16/17)
- Providing PHP versions: PHP 8.3 and PHP 8.4
- Provide Nginx, Tengine, OpenResty, Apache and ngx_lua_waf
- Providing a plurality of Tomcat version (Tomcat-10, Tomcat-9, Tomcat-8, Tomcat-7)
- Providing a plurality of JDK version (JDK-11.0, JDK-1.8, JDK-1.7, JDK-1.6)
- According to their needs to install PHP Cache Accelerator provides ZendOPcache, xcache, apcu, eAccelerator. And php extensions,include ZendGuardLoader,ionCube,SourceGuardian,imagick,gmagick,fileinfo,imap,ldap,calendar,phalcon,yaf,yar,redis,memcached,memcache,mongodb,swoole,xdebug
- Installation Pureftpd, phpMyAdmin according to their needs
- Install memcached, redis according to their needs
- Jemalloc optimize MySQL, Nginx
- Providing add a virtual host script, include Let's Encrypt SSL certificate
- Provide Nginx/Tengine/OpenResty/Apache/Tomcat, MySQL/MariaDB/Percona, PHP, Redis, Memcached, phpMyAdmin upgrade script
- Provide local,remote(rsync between servers),Aliyun OSS,Qcloud COS,UPYUN,QINIU,Amazon S3,Google Drive and Dropbox backup script

## Supported software

| Component | Version | Purpose |
| --- | --- | --- |
| Nginx | 1.26.2 | Nginx is a high‑performance web server and reverse proxy. It efficiently serves static files and balances load across upstreams. It is widely used for TLS termination, HTTP/2, and as a gateway to PHP‑FPM and other backends. |
| Tengine | 2.3.3 | Tengine is an enterprise fork of Nginx maintained by Alibaba. It integrates patches and features optimized for large‑scale deployments. It offers enhanced performance metrics, connection handling, and module ecosystem compatibility. |
| OpenResty | 1.21.4.3 | OpenResty bundles Nginx with LuaJIT to enable dynamic request processing. It lets you write high‑performance web logic directly in Lua running inside Nginx. This is ideal for routing, A/B testing, WAFs, and caching at the edge. |
| Apache HTTP Server | 2.4.62 | Apache is a robust and extensible web server. It provides rich module support and flexible configuration models such as event and worker MPMs. It excels for legacy applications and scenarios that prefer `.htaccess`. |
| OpenSSL | 3.3.1 | OpenSSL provides cryptographic primitives and TLS protocols used by servers. It enables HTTPS, certificate management, and strong encryption. The stack relies on it for secure communications and modern cipher support. |
| MySQL | 8.4.2 | MySQL is a popular relational database for transactional workloads. It powers many PHP and web applications with SQL and ACID properties. This build targets the current LTS series for long‑term stability. |
| PostgreSQL | 16.3 | PostgreSQL is an advanced open‑source relational database. It emphasizes standards compliance, extensibility, and reliability. It is well suited for complex queries, JSON, and analytical workloads. |
| PHP | 8.3, 8.4 | PHP powers dynamic server‑side applications and frameworks. It runs via PHP‑FPM for efficient request handling behind Nginx/Apache. The provided versions cover current stable lines for performance and security. |
| Multi-PHP (optional) | 5.3–8.1 | Multiple PHP versions can run side‑by‑side. This allows hosting apps with different runtime requirements on one server. Service names and sockets are isolated to prevent conflicts. |
| Redis | 7.2.5 | Redis is an in‑memory data store used for caching, queues, and ephemeral data. It delivers low‑latency operations with persistence options. Many PHP applications use it to accelerate sessions and application data. |
| Memcached | 1.6.24 | Memcached is a high‑speed in‑memory cache. It is simple, distributed, and optimized for transient key‑value data. It helps reduce database load and speed up dynamic sites. |
| Node.js | 22.7.0 | Node.js provides a JavaScript runtime and tooling for modern frontends. It enables building assets, SSR, and utility scripts. It is commonly used to compile and bundle frontend resources during deploys. |
| JDK | 11, 8, 7, 6 | The Java Development Kit provides the Java runtime and tools. It supports running and building Java applications. Multiple versions are available to match application compatibility requirements. |
| Tomcat | 10/9/8/7 | Apache Tomcat is a servlet container for Java web applications. It runs WAR packages and supports JSP/Servlet specifications. It is lightweight and suitable for standalone Java services. |
| phpMyAdmin | 5.2.1 | phpMyAdmin is a web interface to administer MySQL/MariaDB. It simplifies database management tasks like queries, backups, and user privileges. It is convenient for quick operations without shell access. |
| Pure-FTPd | 1.0.49 | Pure‑FTPd is a security‑focused FTP server. It supports virtual users, TLS, and resource controls. It is appropriate for simple file transfer workflows and automated pipelines. |
| jemalloc | 5.2.1 | jemalloc is a general‑purpose memory allocator. It can reduce fragmentation and improve multi‑threaded performance. It is often used to optimize MySQL and Nginx memory behavior. |
| ImageMagick | 7.1.0-19 | ImageMagick provides image processing libraries and tools. It enables resizing, format conversion, and transformations. PHP extensions can leverage it for media‑heavy sites. |
| GraphicsMagick | 1.3.36 | GraphicsMagick is a fork focused on stability and performance. It is often faster and lighter for batch operations. It can be used as an alternative to ImageMagick depending on needs. |
| ngx_lua_waf | — | ngx_lua_waf is a web application firewall built on OpenResty. It helps block common attacks like SQL injection and XSS. It is customizable through Lua rules for your environment. |
| PHP extensions | various | Common PHP extensions extend functionality for caching, debugging, and integrations. Examples include Redis, Memcached, MongoDB, APCu, OPcache, Swoole, and Xdebug. You can install them selectively to match application needs. |

## Installation

Install the dependencies for your distro, download the source and run the installation script.

#### CentOS/Redhat

```bash
yum -y install wget screen
```

#### Debian/Ubuntu

```bash
apt-get -y install wget screen
```

#### Download Source and Install

From GitHub (git clone):
```bash
git clone https://github.com/mach7/oneinstack.git
cd oneinstack
```

Or download a tarball from GitHub:
```bash
curl -L https://github.com/mach7/oneinstack/archive/refs/heads/main.tar.gz -o oneinstack-main.tar.gz
tar xzf oneinstack-main.tar.gz
cd oneinstack-main
```

If you disconnect during installation, you can execute the command `screen -r oneinstack` to reconnect to the install window
```bash
screen -S oneinstack 
```

If you need to modify the directory (installation, data storage, Nginx logs), modify `options.conf` file before running install.sh
```bash
./install.sh
```

## How to install another PHP version

```bash
~/oneinstack/install.sh --mphp_ver 54

```

Valid values for `--mphp_ver`: 53, 54, 55, 56, 70, 71, 72, 73, 74, 80, 81

## How to add Extensions

```bash
~/oneinstack/addons.sh

```

## How to add a virtual host

```bash
~/oneinstack/vhost.sh
```

## How to delete a virtual host

```bash
~/oneinstack/vhost.sh --del
```

## How to add FTP virtual user

```bash
~/oneinstack/pureftpd_vhost.sh
```

## How to backup

```bash
~/oneinstack/backup_setup.sh    // Backup parameters
~/oneinstack/backup.sh    // Perform the backup immediately
crontab -l    // Can be added to scheduled tasks, such as automatic backups every day 1:00
  0 1 * * * cd ~/oneinstack/backup.sh  > /dev/null 2>&1 &
```

## How to manage service

Nginx/Tengine/OpenResty:
```bash
service nginx {start|stop|status|restart|reload|configtest}
```
MySQL/MariaDB/Percona:
```bash
service mysqld {start|stop|restart|reload|status}
```
PostgreSQL:
```bash
service postgresql {start|stop|restart|status}
```
MongoDB:
```bash
service mongod {start|stop|status|restart|reload}
```
PHP:
```bash
service php-fpm {start|stop|restart|reload|status}
```
Apache:
```bash
service httpd {start|restart|stop}
```
Tomcat:
```bash
service tomcat {start|stop|status|restart}
```
Pure-FTPd:
```bash
service pureftpd {start|stop|restart|status}
```
Redis:
```bash
service redis-server {start|stop|status|restart|reload}
```
Memcached:
```bash
service memcached {start|stop|status|restart|reload}
```

## How to upgrade

```bash
~/oneinstack/upgrade.sh
```

## How to uninstall

```bash
~/oneinstack/uninstall.sh
```

## Community

For feedback, questions, and to follow the progress of the project: <br />
[Telegram Group](https://t.me/oneinstack)<br />
[OneinStack](https://oneinstack.com)<br />

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
| Nginx | 1.26.2 | Web server |
| Tengine | 2.3.3 | High-performance Nginx fork |
| OpenResty | 1.21.4.3 | Nginx with Lua (dynamic routing, WAF, etc.) |
| Apache HTTP Server | 2.4.62 | Web server |
| OpenSSL | 3.3.1 | TLS/cryptography libraries used by servers |
| MySQL | 8.4.2 | Relational database |
| PostgreSQL | 16.3 | Relational database |
| PHP | 8.3, 8.4 | Server-side scripting (FPM) |
| Multi-PHP (optional) | 5.3–8.1 | Run multiple PHP versions side-by-side |
| Redis | 7.2.5 | In-memory data store/cache |
| Memcached | 1.6.24 | In-memory cache |
| Node.js | 22.7.0 | JavaScript runtime/tooling |
| JDK | 11, 8, 7, 6 | Java runtimes |
| Tomcat | 10/9/8/7 | Java application server |
| phpMyAdmin | 5.2.1 | MySQL/MariaDB web administration |
| Pure-FTPd | 1.0.49 | FTP server |
| jemalloc | 5.2.1 | Memory allocator to optimize MySQL/Nginx |
| ImageMagick | 7.1.0-19 | Image processing tools |
| GraphicsMagick | 1.3.36 | Image processing tools |
| ngx_lua_waf | — | Web application firewall for Nginx/OpenResty |
| PHP extensions | various | redis, memcached, mongodb, apcu, opcache, swoole, xdebug, etc. |

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

```bash
wget http://mirrors.linuxeye.com/oneinstack-full.tar.gz
tar xzf oneinstack-full.tar.gz
cd oneinstack 
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

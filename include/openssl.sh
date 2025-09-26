#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_openSSL() {
  if [ -e "${openssl_install_dir}/lib/libssl.a" ]; then
    echo "${CWARNING}openSSL already installed! ${CEND}"
  else
    pushd ${oneinstack_dir}/src > /dev/null
    # Prefer OpenSSL 3.x if provided; fallback to legacy ${openssl_ver}
    if [ -n "${openssl3_ver}" ] && [ -s "openssl-${openssl3_ver}.tar.gz" ]; then
      tar xzf openssl-${openssl3_ver}.tar.gz
      pushd openssl-${openssl3_ver} > /dev/null
    else
      tar xzf openssl-${openssl_ver}.tar.gz
      pushd openssl-${openssl_ver} > /dev/null
    fi
    make clean
    ./config -Wl,-rpath=${openssl_install_dir}/lib -fPIC --prefix=${openssl_install_dir} --openssldir=${openssl_install_dir}
    make depend
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${openssl_install_dir}/lib/libcrypto.a" ] || [ -f "${openssl_install_dir}/lib64/libcrypto.a" ]; then
      echo "${CSUCCESS}openSSL installed successfully! ${CEND}"
      /bin/cp cacert.pem ${openssl_install_dir}/cert.pem
      [ -n "${openssl3_ver}" ] && rm -rf openssl-${openssl3_ver}
      rm -rf openssl-${openssl_ver}
    else
      echo "${CFAILURE}openSSL install failed, Please contact the author! ${CEND}" && lsb_release -a
      kill -9 $$; exit 1;
    fi
    popd > /dev/null
  fi
}

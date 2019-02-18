#!/bin/bash
redis_version=3.2.9
THREAD=1
redis_install_dir=/usr/local/redis
OS='CentOS'
. memory.sh
cd src
tar xzf redis-${redis_version}.tar.gz
cd redis-${redis_version}
if [ "$OS_BIT" == '32' ]; then
  sed -i '1i\CFLAGS= -march=i686' src/Makefile
  sed -i 's@^OPT=.*@OPT=-O2 -march=i686@' src/.make-settings
fi
make -j ${THREAD}
if [ -f "src/redis-server" ]; then
mkdir -p ${redis_install_dir}/{bin,etc,var}
/bin/cp src/{redis-benchmark,redis-check-aof,redis-check-rdb,redis-cli,redis-sentinel,redis-server} ${redis_install_dir}/bin/
/bin/cp redis.conf ${redis_install_dir}/etc/
ln -s ${redis_install_dir}/bin/* /usr/local/bin/
sed -i 's@pidfile.*@pidfile /usr/local/redis/var/redis.pid@' ${redis_install_dir}/etc/redis.conf
sed -i "s@logfile.*@logfile ${redis_install_dir}/var/redis.log@" ${redis_install_dir}/etc/redis.conf
sed -i "s@^dir.*@dir ${redis_install_dir}/var@" ${redis_install_dir}/etc/redis.conf
sed -i 's@daemonize no@daemonize yes@' ${redis_install_dir}/etc/redis.conf
#sed -i "s@^# bind 127.0.0.1@bind 127.0.0.1@" ${redis_install_dir}/etc/redis.conf
redis_maxmemory=`expr $Mem / 8`000000
[ -z "`grep ^maxmemory ${redis_install_dir}/etc/redis.conf`" ] && sed -i "s@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory `expr $Mem / 8`000000@" ${redis_install_dir}/etc/redis.conf
echo "${CSUCCESS}Redis-server installed successfully! ${CEND}"
cd ..
rm -rf redis-${redis_version}
id -u redis >/dev/null 2>&1
[ $? -ne 0 ] && useradd -M -s /sbin/nologin redis
chown -R redis:redis ${redis_install_dir}
/bin/cp ../init.d/redis-init /etc/init.d/redis-server
if [ "$OS" == 'CentOS' ]; then
 #cc start-stop-daemon.c -o /sbin/start-stop-daemon
 chkconfig --add redis-server
 chkconfig redis-server on
elif [[ $OS =~ ^Ubuntu$|^Debian$ ]]; then
 update-rc.d redis-server defaults
fi
sed -i "s@/usr/local/redis@${redis_install_dir}@g" /etc/init.d/redis-server
[ -z "`grep 'vm.overcommit_memory' /etc/sysctl.conf`" ] && echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
sysctl -p
service redis-server start
else
rm -rf ${redis_install_dir}
echo "${CFAILURE}Redis-server install failed, Please contact the author! ${CEND}"
kill -9 $$
fi
cd ..


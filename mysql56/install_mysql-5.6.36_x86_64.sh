#!/bin/bash
rpm -qa|grep libaio
if [[ $? -gt 0 ]] 
then
yum install -y libaio
fi
cPWD=`pwd`
echo $PWD >> /tmp/mysql.log
groupadd -r mysql
useradd -r -g mysql -s /sbin/nologin mysql
mkdir -p /data/mysql
chown -R mysql:mysql /data/mysql
tar zxvf mysql-5.6.36-linux-glibc2.5-x86_64.tar.gz -C /usr/local
ln -s /usr/local/mysql-5.6.36-linux-glibc2.5-x86_64 /usr/local/mysql
chown -R mysql.mysql /usr/local/mysql
chown -R mysql.mysql /usr/local/mysql-5.6.36-linux-glibc2.5-x86_64
cd /usr/local/mysql
scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/data/mysql --user=mysql
ln -s /usr/local/mysql/bin/mysql /usr/bin/
ln -s /usr/local/mysql/bin/mysql_config /usr/bin/
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe
cp support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
#/etc/my.cnf
cd $cPWD
echo `pwd` >> /tmp/mysql.log
rm -f /etc/my.cnf
cp conf/my.cnf /etc/my.cnf
service mysqld start
#/usr/local/mysql/bin/mysqld_safe --user=mysql &
/usr/local/mysql/bin/mysqladmin -u root password 'root'
ln -s /usr/local/mysql/include /usr/include/mysql
echo "/usr/local/mysql/lib" > /etc/ld.so.conf.d/mysql.conf
ldconfig
ldconfig -v | grep mysql
#
#/usr/local/mysql/bin/mysql_secure_installation
{
mysql -uroot -proot -e "delete from mysql.user where user='';FLUSH PRIVILEGES;"
mysql -uroot -proot -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -uroot -proot -e "DROP DATABASE test;DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -uroot -proot -e "FLUSH PRIVILEGES;"
} > /dev/null 2>&1
echo "export PATH=/usr/local/mysql/bin:$PATH" >> /etc/profile
source /etc/profile
service mysqld restart

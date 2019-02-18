#!/bin/bash
yum install wget openssl openssl-devel xz readline readline-devel -y
tar xvf Python-3.6.1.tar.xz  
cd Python-3.6.1/  
./configure --prefix=/usr/local/python
THREAD=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)
make -j $THREAD 
make install  
cd ..
export PATH=/usr/local/python/bin:$PATH
echo 'export PATH=/usr/local/python/bin:$PATH' >> /etc/profile
source /etc/profile
mkdir $HOME/.pip
cp conf/pip.conf $HOME/.pip/
pip3 install --upgrade pip
rm -f /usr/bin/pip3
rm -f /usr/bin/python3
ln -s /usr/local/python/bin/pip3 /usr/bin/
ln -s /usr/local/python/bin/python3 /usr/bin/


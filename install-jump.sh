#!/bin/bash
CPWD=`pwd`
## env
cd /opt
python3 -m venv py3
source /opt/py3/bin/activate
git clone https://github.com/kennethreitz/autoenv.git
echo 'source /opt/autoenv/activate.sh' >> ~/.bashrc
source ~/.bashrc

## jumpserver
cd $CPWD/jumpserver-package
tar zxvf jumpserver-1.4.7.tar.gz -C /opt/
rm -f /opt/jumpserver
ln -s /opt/jumpserver-1.4.7/ /opt/jumpserver
echo "source /opt/py3/bin/activate" > /opt/jumpserver/.env 
cd /opt/jumpserver/requirements
sed -i 's/mariadb-devel mysql-devel//g' rpm_requirements.txt
yum -y install $(cat rpm_requirements.txt)
pip3 install --upgrade pip setuptools
pip3 install -r requirements.txt

### jumpserver config
cd ..
cp config_example.yml config.yml
SECRET_KEY=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 50`
BOOTSTRAP_TOKEN=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`
sed -i "s/SECRET_KEY:/SECRET_KEY: $SECRET_KEY/g" /opt/jumpserver/config.yml
sed -i "s/BOOTSTRAP_TOKEN:/BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN/g" /opt/jumpserver/config.yml
sed -i "s/# DEBUG: true/DEBUG: false/g" /opt/jumpserver/config.yml
sed -i "s/# LOG_LEVEL: DEBUG/LOG_LEVEL: ERROR/g" /opt/jumpserver/config.yml
sed -i "s/# SESSION_EXPIRE_AT_BROWSER_CLOSE: False/SESSION_EXPIRE_AT_BROWSER_CLOSE: True/g" /opt/jumpserver/config.yml
sed -i "s/DB_PASSWORD:.*/DB_PASSWORD: jumpserver/" config.yml
## coco
cd $CPWD/jumpserver-package/
tar zxvf coco-1.4.7.tar.gz -C /opt/
rm -f /opt/coco
ln -s /opt/coco-1.4.7/ /opt/coco
echo "source /opt/py3/bin/activate" > /opt/coco/.env
cd /opt/coco/requirements
yum -y  install $(cat rpm_requirements.txt)
pip3 install -r requirements.txt
cd ..
mkdir keys logs
#coco config
cp config_example.yml config.yml
## luna
cd $CPWD/jumpserver-package/ 
tar zxvf luna.tar.gz -C /opt/
chown -R root.root /opt/luna/




#!/bin/bash
# EC2 userdata
FRAMEWORK_PROPERTIES=/etc/rundeck/framework.properties
RUNDECK_CONFIG_PROPERTIES=/etc/rundeck/rundeck-config.properties
IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

yum update -y 
yum install epel-release -y
yum install htop -y
yum install python3 -y
yum install awscli java-11-openjdk -y

curl https://raw.githubusercontent.com/rundeck/packaging/main/scripts/rpm-setup.sh 2> /dev/null | bash -s rundeck
rpm -Uvh https://repo.rundeck.org/latest.rpm
yum install rundeck -y

python3 -m pip install --upgrade pip
python3 -m pip install boto3

# #################################################################################
# UPDATE FRAMEWORK.PROPERTIES file
sed -i 's/framework.server.name = localhost/framework.server.name = rundeck-io-app/g'  $FRAMEWORK_PROPERTIES
sed -i 's/framework.server.hostname = localhost/framework.server.hostname = rundeck-io-app/g'  $FRAMEWORK_PROPERTIES

sed -i 's/framework.server.port = 4440/framework.server.port = 4443/g'  $FRAMEWORK_PROPERTIES
sed -i 's/framework.server.url = http:\/\/localhost:4440/framework.server.url = https:\/\/'$IP':4443/g'  $FRAMEWORK_PROPERTIES

#########################################################################################
# UPDATE RUNDECK-CONFIG.PROPERTIES
sed -i 's/grails.serverURL=http:\/\/localhost:4440/grails.serverURL=https:\/\/'$IP':4443/g'  $RUNDECK_CONFIG_PROPERTIES

#########################################################################################
# adjust some environment variables
echo 'export RUNDECK_WITH_SSL=true' >> /etc/sysconfig/rundeckd
echo 'export RDECK_HTTPS_PORT=4443' >> /etc/sysconfig/rundeckd
if [ -n "${rdeck_jvm_settings}" ]; then
    echo 'export RDECK_JVM_SETTINGS=${rdeck_jvm_settings}' >> /etc/sysconfig/rundeckd
fi 

#########################################################################################
# Generate self-signed certificate used by Rundeck host.
keytool -genkey -alias rundeck -keyalg RSA -keystore keystore -dname "CN=app.rundeck.io, OU=devops, O=rundeck.io, L=Reno, S=Nevada, C=US" -storepass adminadmin -keypass adminadmin -validity 365
cp keystore truststore
mv keystore /etc/rundeck/ssl/
mv truststore /etc/rundeck/ssl/
chown rundeck:rundeck /etc/rundeck/ssl/keystore
chown rundeck:rundeck /etc/rundeck/ssl/truststore

hostnamectl set-hostname --static 'rundeck'

systemctl enable rundeckd
service rundeckd restart 

yum install nano -y

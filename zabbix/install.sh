#!/bin/bash
if [ $UID != 0 ]
then
	echo "You need to be root."
	exit
fi

DBPASS=pswd4mysql

echo "Installing rpm ..."

rpm -ivh http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm
yum install -y zabbix-{agent,get,java-gateway,proxy,proxy-mysql,sender,server,server-mysql,web,web-mysql} zabbix mysql-server
chkconfig mysqld on
chkconfig httpd on
service mysqld start

echo -e "Setting up DB ...\nMySQL root password is: $DBPASS"

mysqladmin -uroot password $DBPASS
mysql -uroot -p$DBPASS << EOF
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
exit
EOF

cd /usr/share/doc/zabbix-server-mysql*/create; mysql -uroot -ppswd4mysql < schema.sql; mysql -uroot -ppswd4mysql < images.sql; mysql -uroot -ppswd4mysql < data.sql

echo -e "DBHost=localhost\nDBPassword=zabbix\n" >> /etc/zabbix/zabbix_server.conf

echo -e "Starting service ..."

cat >> /etc/httpd/conf.d/zabbix.confi << EOF
"php_value max_execution_time 300
php_value memory_limit 128M
php_value post_max_size 16M
php_value upload_max_filesize 2M
php_value max_input_time 300
php_value date.timezone Asia/Shanghai"
EOF

service zabbix-server restart
chkconfig zabbix-server on
service httpd restart

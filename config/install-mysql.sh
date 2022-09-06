### 
### install_Mysql.sh ec2上安装mysql，wget 取sql 脚本，运行sql脚本，将自己的DNS吐出去
### Maintained by China PSA team


# Params info

                #   DBMasterUserPassword|${DBMasterUserPassword}
                #   DBMasterUsername|${DBMasterUsername}
                #   BucketName|${BucketName}
                #   MySQLversion|${MySQLversion}
#$appus','$apppw'


# DBMasterUserPassword|GravitonGameDay
# DBMasterUsername|graviton
# MySQLversion|8.0.23
# AppUsername|admin
# AppPassword|admin
###############################################

#!/bin/bash -xe
function exportParams() {
    Password=`grep 'DBMasterUserPassword' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
    Username=`grep 'DBMasterUsername' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
    MySQLversion=`grep 'MySQLversion' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
    appus=`grep 'AppUsername' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
    apppw=`grep 'AppPassword' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
}


PARAMS_FILE=/tmp/params.txt

Password='NONE'
Username='NONE'
MySQLversion='NONE'
appus='NONE'
apppw='NONE'

exportParams

# Install the basics
yum -y update -y
yum -y install jq -y
yum install python3.7 -y

pip3 install awscli --upgrade --user
echo "export PATH=~/.local/bin:$PATH" >> .bash_profile
sleep 1
pip3 install boto3 --user
pip3 install awscli --upgrade --user
sleep 1

##############################      install mysql      ##########################################

cd /home/ec2-user/

sudo yum install https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm -y

sudo yum repolist
sudo amazon-linux-extras install epel -y
sudo yum -y install mysql-community-server -y

sudo systemctl enable --now mysqld

#取root的初始临时密码到环境变量，（这里mysql 版本8和 5方式不一样，要写if判断，暂时先限制使用8版本）

tpw="`sudo grep 'temporary password' /var/log/mysqld.log | awk '{ print $NF}'`"

#mysql -uroot -p -$tpw

#改root的密码
mysql -u root -p"$tpw" --connect-expired-password <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$Password';
quit
EOF
sleep 1

#mysql -uroot -p$Password


#编写sql，创建应用的用户，库，表。插入联系人Java的用户密码
cat << EOF > /home/ec2-user/create_game_day.sql

# Create DBuser
CREATE USER '$Username'@'%' IDENTIFIED BY '$Password';
GRANT ALL PRIVILEGES ON *.* TO '$Username'@'%';
ALTER USER '$Username'@'%' IDENTIFIED WITH mysql_native_password BY '$Password';

# Create database
create database webappdb;

# Select the webapp database to use
use webappdb;

# Create user account table
create table user_accounts (user_name varchar(30) not null primary key, user_pass varchar(30) not null);

# Create user application table
create table users ( id int(3) NOT NULL AUTO_INCREMENT, name varchar(120) NOT NULL, email varchar(220) NOT NULL, company varchar(120), PRIMARY KEY (id) );

# Create user account role table
create table user_account_roles (user_name varchar(30) not null, role_name varchar(30) not null, primary key (user_name, role_name));

# Insert a default user into the user account table
insert into user_accounts values ('graviton@aws.psa','graviton@aws.psa');
insert into user_accounts values ('$appus','$apppw');

# Insert a default role associated with the user
insert into user_account_roles values ('graviton@aws.psa', 'standard');
insert into user_account_roles values ('$appus', 'standard');

EOF
#执行sql
sleep 1
mysql -h 127.0.0.1 -u root -p$Password < /home/ec2-user/create_game_day.sql

mysql -h 127.0.0.1 -u $Username -p$Password  -e "show databases;"

sleep 1
# OutPut
hostname=`curl -s http://169.254.169.254/latest/meta-data/hostname`
cat << EOF > /home/ec2-user/outputurl
$hostname //  is your mysql
EOF

echo " Done with installations"
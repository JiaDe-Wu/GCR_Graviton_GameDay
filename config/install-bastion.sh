### 
### install_bastion.sh：
#  ec2上安装bastion

#  去参数，数据库用户名密码，数据库地址，s3桶名字
#  下载 代码包，解压 (代码包要组装一下，包含两个源码包，4个依赖包,几个配置文件)
#  cat 填写aws-signup-lambda:  signupHandler class to reflect mysqlEndpoint, DBUserName, and DBPassword
#  cat 填写sample-webapp: UserDAO class to reflect the mysqlEndpoint, DBUserName, and DBPassword
#  安装 maven 
#  打包jar 包 maven package shade:shade
#  打包war 包 maven package shade:shade
#  sync 解压的压缩包上传到S3 
#  记下上传的s3路径，要和lambda填的一致
#  获取进行编译将自己的DNS吐出去

# DBMasterUserPassword|aaaaaaaaaaa
# DBMasterUsername|qqqqqqqqqqqqqq
# MySQLEndpoint|demozzzzzzzzzz.awawawaw.awadsdas.com
# RedisEndpoint|dededededccccccc.awawawaw.awadsdas.com
# BucketName|lalalala-graviton-game-day
# ### Maintained by China PSA team


#!/bin/bash -xe
function exportParams() {
    Password=`grep 'DBMasterUserPassword' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
    Username=`grep 'DBMasterUsername' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
    BucketName=`grep 'BucketName' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
    key=`grep 'KeyPairName' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
}


PARAMS_FILE=/tmp/params.txt

Password='NONE'
Username='NONE'
BucketName='NONE'
key='NONE'

exportParams

AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
REGION="`echo \"$AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"

##############################      Install the basics      ##########################################

yum -y update -y
yum -y install jq -y
yum install python3.7 -y

pip3 install awscli --upgrade --user
echo "export PATH=~/.local/bin:$PATH" >> .bash_profile
sleep 1
pip3 install boto3 --user
pip3 install awscli --upgrade --user
sleep 1

##############################      Install maven      ##########################################


cd /home/ec2-user/


sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
sudo yum install -y apache-maven

##############################      download code      ##########################################


sudo wget https://awspsa-quickstart.s3.cn-northwest-1.amazonaws.com.cn/gravitongameday/code/code.tar.gz

sudo tar -zxvf code.tar.gz
sleep 1

sudo mkdir /home/ec2-user/config/
sudo wget https://awspsa-quickstart.s3.cn-northwest-1.amazonaws.com.cn/gravitongameday/config/tomcat.service -O /home/ec2-user/config/tomcat.service
sudo wget https://awspsa-quickstart.s3.cn-northwest-1.amazonaws.com.cn/gravitongameday/config/server.xml -O /home/ec2-user/config/server.xml 
sudo wget https://awspsa-quickstart.s3.cn-northwest-1.amazonaws.com.cn/gravitongameday/config/context.xml -O /home/ec2-user/config/context.xml
sudo wget https://awspsa-quickstart.s3.cn-northwest-1.amazonaws.com.cn/gravitongameday/config/httpd.conf -O /home/ec2-user/config/httpd.conf
sudo wget https://awspsa-quickstart.s3.cn-northwest-1.amazonaws.com.cn/gravitongameday/config/redisson.yaml -O /home/ec2-user/config/redisson.yaml
sudo wget https://awspsa-quickstart.s3.cn-northwest-1.amazonaws.com.cn/gravitongameday/config/webappdb_create_tables.sql -O /home/ec2-user/config/webappdb_create_tables.sql
sleep 1


##############################      去取数据库的地址赋变量      ##########################################



cat << EOF > /home/ec2-user/get-stack-ip-addresses.py
###
### get-stack-info.py
### Need ec2:Describe* IAM policy / need python3 boto3 json
### Maintained by China PSA team

import boto3,json

stack={}
print(boto3.__version__)

# Get mysql
client = boto3.client('ec2',region_name='$REGION')
custom_filter = [{
    'Name':'tag:Name',
    'Values': ['Graviton_GameDay_MySQL1']},{
    'Name':'instance-state-name',
    'Values': ['running']}]
    # 'Values': ['running','waiting']}]
response = client.describe_instances(Filters=custom_filter)
print (response)
stack['MySQLEndpoint']=response['Reservations'][0]['Instances'][0]['PrivateDnsName']

# Get redis
client = boto3.client('ec2',region_name='$REGION')
custom_filter = [{
    'Name':'tag:Name',
    'Values': ['Graviton_GameDay_Redis1']},{
    'Name':'instance-state-name',
    'Values': ['running']}]
response = client.describe_instances(Filters=custom_filter)
print (response)
stack['RedisEndpoint']=response['Reservations'][0]['Instances'][0]['PrivateDnsName']

# Save to local file
print (json.dumps(stack))
with open('stack-info.json', 'w') as f:
    json.dump(stack, f)
EOF

chmod +x /home/ec2-user/get-stack-ip-addresses.py
sleep 1
python3 /home/ec2-user/get-stack-ip-addresses.py
sleep 1
MySQLEndpoint=`cat stack-info.json | jq -r '.MySQLEndpoint'`
RedisEndpoint=`cat stack-info.json | jq -r '.RedisEndpoint'`
sleep 1

# sample-webapp
cd /home/ec2-user/code/sample-webapp/


sudo sed -i "s|jdbc:mysql://<RDSEndpoint>:3306/webappdb?useSSL=false|jdbc:mysql://$MySQLEndpoint:3306/webappdb?useSSL=false|g" /home/ec2-user/code/sample-webapp/src/main/java/com/sample/app/usermanagement/dao/UserDAO.java
sudo sed -i "s|<DBUserName>|$Username|g" /home/ec2-user/code/sample-webapp/src/main/java/com/sample/app/usermanagement/dao/UserDAO.java
sudo sed -i "s|<DBPassword>|$Password|g" /home/ec2-user/code/sample-webapp/src/main/java/com/sample/app/usermanagement/dao/UserDAO.java

sleep 1

mvn clean install
sleep 1

# aws-signup-lambda
cd /home/ec2-user/code/aws-signup-lambda/

#cat /home/ec2-user/code/aws-signup-lambda/src/main/java/com/sample/app/lambda/signupHandler.java

sudo sed -i "s|jdbc:mysql://<RDSEndpoint>:3306/webappdb?useSSL=false|jdbc:mysql://$MySQLEndpoint:3306/webappdb?useSSL=false|g" /home/ec2-user/code/aws-signup-lambda/src/main/java/com/sample/app/lambda/signupHandler.java
sudo sed -i "s|<DBUserName>|$Username|g" /home/ec2-user/code/aws-signup-lambda/src/main/java/com/sample/app/lambda/signupHandler.java
sudo sed -i "s|<DBPassword>|$Password|g" /home/ec2-user/code/aws-signup-lambda/src/main/java/com/sample/app/lambda/signupHandler.java

sleep 1

mvn package shade:shade

sleep 1

#上传到s3
#lib/
aws s3 cp /home/ec2-user/code/sample-webapp/target/sample-webapp.war s3://$BucketName/lib/sample-webapp.war
aws s3 cp /home/ec2-user/code/aws-signup-lambda/target/create-user-lambda-1.0.jar s3://$BucketName/lib/create-user-lambda-1.0.jar
aws s3 cp /home/ec2-user/code/apache-tomcat-9.0.41.tar.gz s3://$BucketName/lib/apache-tomcat-9.0.41.tar.gz
aws s3 cp /home/ec2-user/code/redisson-all-3.14.1.jar s3://$BucketName/lib/redisson-all-3.14.1.jar
aws s3 cp /home/ec2-user/code/redisson-tomcat-9-3.14.1.jar s3://$BucketName/lib/redisson-tomcat-9-3.14.1.jar
aws s3 cp /home/ec2-user/code/tomcat-oidcauth-2.3.0-tomcat90.jar s3://$BucketName/lib/tomcat-oidcauth-2.3.0-tomcat90.jar
sleep 1
# #config/
aws s3 cp /home/ec2-user/config/tomcat.service s3://$BucketName/config/tomcat.service
aws s3 cp /home/ec2-user/config/server.xml  s3://$BucketName/config/server.xml 
aws s3 cp /home/ec2-user/config/context.xml s3://$BucketName/config/context.xml
aws s3 cp /home/ec2-user/config/httpd.conf s3://$BucketName/config/httpd.conf
aws s3 cp /home/ec2-user/config/redisson.yaml s3://$BucketName/config/redisson.yaml
aws s3 cp /home/ec2-user/config/webappdb_create_tables.sql s3://$BucketName/config/webappdb_create_tables.sql
sleep 1
# OutPut
hostname=`curl -s http://169.254.169.254/latest/meta-data/public-hostname`
cat << EOF > /home/ec2-user/outputurl
bastion[ssh -i $key ec2-user@$hostname] //login your bastion
EOF

sleep 1
echo " Done with installations"
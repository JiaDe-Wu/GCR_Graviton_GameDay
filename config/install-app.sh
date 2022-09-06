### 
### install_app.sh ec2上安装tomcat，下载堡垒机打包好的sample-webapp.war，取参数，对 context.xml进行配置，重启服务，将自己的DNS吐出去，给到ALB做目标组
### Maintained by China PSA team

# get Params info
                #   UserPoolId|${UserPoolId}
                #   DBMasterUserPassword|${DBMasterUserPassword}
                #   DBMasterUsername|${DBMasterUsername}
                #   MySQLEndpoint|${MySQLEndpoint}
                #   RedisEndpoint|${RedisEndpoint}
                #   BucketName|${BucketName}

# # for install
# clickhouseversion
###############################################

#!/bin/bash -xe

##############################      引入参数      ##########################################

function exportParams() {
#    UserPoolId=`grep 'UserPoolId' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
    DBMasterUserPassword=`grep 'DBMasterUserPassword' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
    DBMasterUsername=`grep 'DBMasterUsername' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
    MySQLEndpoint=`grep 'MySQLEndpoint' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
    RedisEndpoint=`grep 'RedisEndpoint' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
    BucketName=`grep 'BucketName' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
}


PARAMS_FILE=/tmp/params.txt

#UserPoolId='NONE'
DBMasterUserPassword='NONE'
DBMasterUsername='NONE'
MySQLEndpoint='NONE'
RedisEndpoint='NONE'
BucketName='NONE'

exportParams


AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
REGION="`echo \"$AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"

# Install the basics
yum -y update -y
yum -y install jq -y
yum install python3.7 -y
sudo amazon-linux-extras install java-openjdk11
pip3 install awscli --upgrade --user
echo "export PATH=~/.local/bin:$PATH" >> .bash_profile
sleep 1
pip3 install boto3 --user
pip3 install awscli --upgrade --user
sleep 1

##############################      install tomcat      ##########################################

sudo aws s3api get-object --bucket ${BucketName} --key config/tomcat.service /etc/systemd/system/tomcat.service
useradd -d /usr/share/tomcat -s /bin/nologin tomcat
sudo aws s3api get-object --bucket ${BucketName} --key lib/apache-tomcat-9.0.41.tar.gz /tmp/apache-tomcat-9.0.41.tar.gz
tar -zxvf /tmp/apache-tomcat-*.tar.gz
mv apache-tomcat-9.0.41/* /usr/share/tomcat
chown -R tomcat:tomcat /usr/share/tomcat/
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat
sudo yum install -y mysql
sudo yum install -y ruby
cd /home/ec2-user

##############################      config tomcat      ##########################################

sudo aws s3api get-object --bucket ${BucketName} --key lib/redisson-all-3.14.1.jar /usr/share/tomcat/lib/redisson-all-3.14.1.jar
sudo aws s3api get-object --bucket ${BucketName} --key lib/redisson-tomcat-9-3.14.1.jar /usr/share/tomcat/lib/redisson-tomcat-9-3.14.1.jar
sudo aws s3api get-object --bucket ${BucketName} --key lib/tomcat-oidcauth-2.3.0-tomcat90.jar /usr/share/tomcat/lib/tomcat-oidcauth-2.3.0-tomcat90.jar
sudo aws s3api get-object --bucket ${BucketName} --key config/server.xml /usr/share/tomcat/conf/server.xml


# you-can-find-it=`aws cognito-idp describe-user-pool-client --user-pool-id us-west-2_CjeVrgCbq --client-id 6avca1get6kf7v6jtp3m925ufb --region=us-west-2 --output=text | cut -f5`
# who-knows=`aws cognito-idp describe-user-pool-client --user-pool-id us-west-2_CjeVrgCbq --client-id 6avca1get6kf7v6jtp3m925ufb --region=us-west-2 --output=text | cut -f5`

#sudo aws s3api get-object --bucket ${BucketName} --key config/context.xml /usr/share/tomcat/conf/context.xml
sleep 1

cat << EOF > /usr/share/tomcat/conf/context.xml
<?xml version='1.0' encoding='utf-8'?>
<Context>
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
    <Manager className="org.redisson.tomcat.RedissonSessionManager"
        configPath="\${catalina.base}/conf/redisson.yaml" 
        readMode="REDIS" updateMode="AFTER_REQUEST" broadcastSessionEvents="false"
        keyPrefix=""/>
    <Resource name="jdbc/webappdb" auth="Container" type="javax.sql.DataSource"
               maxTotal="100" maxIdle="30" maxWaitMillis="10000"
               username="$DBMasterUsername" password="$DBMasterUserPassword" driverClassName="com.mysql.jdbc.Driver"
               url="jdbc:mysql://$MySQLEndpoint:3306/webappdb"/>
    <!--     
    <Valve className="org.bsworks.catalina.authenticator.oidc.c.OpenIDConnectAuthenticator"
       providers="[
           {
               name: 'Amazon Cognito',
               issuer: https://cognito-idp.$REGION.amazonaws.com/UserPoolId,
               clientId: you-can-find-it,
               clientSecret: who-knows
           }
       ]"
        hostBaseURI="https://graviton.tips.com" usernameClaim="email" />
    -->
</Context>

EOF

sleep 1

# sudo aws s3api get-object --bucket ${BucketName} --key config/redisson.yaml /usr/share/tomcat/conf/redisson.yaml

cat << EOF > /usr/share/tomcat/conf/redisson.yaml
singleServerConfig:
    idleConnectionTimeout: 10000
    connectTimeout: 10000
    timeout: 3000
    retryAttempts: 3
    retryInterval: 1500
    password: null
    subscriptionsPerConnection: 5
    clientName: null
    address: "redis://$RedisEndpoint:6379"
    subscriptionConnectionMinimumIdleSize: 1
    subscriptionConnectionPoolSize: 50
    connectionMinimumIdleSize: 10
    connectionPoolSize: 64
    database: 0
    dnsMonitoringInterval: 5000
threads: 0
nettyThreads: 0

EOF

sudo chown tomcat:tomcat /usr/share/tomcat/lib/redisson-all-3.14.1.jar
sudo chown tomcat:tomcat /usr/share/tomcat/lib/redisson-tomcat-9-3.14.1.jar
sudo chown tomcat:tomcat /usr/share/tomcat/lib/tomcat-oidcauth-2.3.0-tomcat90.jar
sudo systemctl restart tomcat
sudo rm -rf /usr/share/tomcat/webapps/sample-webapp.war
sudo aws s3api get-object --bucket ${BucketName} --key lib/sample-webapp.war /tmp/sample-webapp.war
cd cd /home/ec2-user
sudo cp /tmp/sample-webapp.war /usr/share/tomcat/webapps/sample-webapp.war
sudo systemctl restart tomcat
sudo systemctl status tomcat

# OutPut
hostname=`curl -s http://169.254.169.254/latest/meta-data/hostname`
cat << EOF > /home/ec2-user/outputurl
tomact[http://$hostname:8080/sample-webapp/] // is your tomact
EOF

echo " Done with installations"
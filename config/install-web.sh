### 
### install_apache.sh ec2上安装apache， 取java的alb dns配置到httpd，重启服务，将自己的DNS吐出去，给到cloudfront做https
### Maintained by China PSA team
# Params info
                #   BucketName|${BucketName}
###############################################

###############################################

#!/bin/bash -xe
function exportParams() {
    BucketName=`grep 'BucketName' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
}


PARAMS_FILE=/tmp/params.txt

BucketName='NONE'

exportParams

# Install the basics
yum -y update -y
yum -y install jq -y
pip3 install awscli --upgrade --user
echo "export PATH=~/.local/bin:$PATH" >> .bash_profile
sleep 1
pip3 install boto3 --user
pip3 install awscli --upgrade --user
sleep 1

##############################      install apache      ##########################################

yum install -y httpd
sleep 1
##############################      get tomcat alb dns for apache      ##########################################

AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
REGION="`echo \"$AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"

# 取ALB的DNS
#aws elbv2 describe-load-balancers --load-balancer-arns arn:aws:elasticloadbalancing:us-west-2:263168716248:loadbalancer/app/java-app-lb/a344724741ccd7a3 --region=us-west-2 --output=text | cut -f4
#java=$(aws elbv2 describe-load-balancers --load-balancer-arns $alb --region=$REGION --output=text | cut -f4)

##############################      去tomcat的地址赋变量      ##########################################



cat << EOF > /home/ec2-user/get-stack-ip-addresses.py
### get-stack-info.py
### Need ec2:Describe* IAM policy / need python3 boto3 json
### Maintained by China PSA team

import boto3,json

stack={}
print(boto3.__version__)

# Get APPEndpoint
client = boto3.client('ec2',region_name='$REGION')
custom_filter = [{
    'Name':'tag:Name',
    'Values': ['Graviton_GameDay_App1']},{
    'Name':'instance-state-name',
    'Values': ['running']}]
    # 'Values': ['running','waiting']}]
response = client.describe_instances(Filters=custom_filter)
print (response)
stack['APPEndpoint']=response['Reservations'][0]['Instances'][0]['PrivateDnsName']

# Save to local file
print (json.dumps(stack))
with open('stack-info.json', 'w') as f:
    json.dump(stack, f)
EOF
APPEndpoint

chmod +x /home/ec2-user/get-stack-ip-addresses.py
sleep 1
python3 /home/ec2-user/get-stack-ip-addresses.py
sleep 1
APPEndpoint=`cat stack-info.json | jq -r '.APPEndpoint'`
sleep 1

hostname=`curl -s http://169.254.169.254/latest/meta-data/public-hostname`

cat << EOF > /etc/httpd/conf/httpd.conf

ServerRoot "/etc/httpd"
Listen 80
<VirtualHost *:80>
ProxyPass / http://$APPEndpoint:8080/
ProxyPassReverse / http://$APPEndpoint:8080/
</VirtualHost>
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost
<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/var/www/html"
<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>
<Files ".ht*">
    Require all denied
</Files>
ErrorLog "logs/error_log"
LogLevel warn
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "logs/access_log" combined
</IfModule>
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>
<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>
<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8
<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>
EnableSendfile on
<IfModule mod_http2.c>
    Protocols h2 h2c http/1.1
</IfModule>
IncludeOptional conf.d/*.conf

EOF

sleep 1
##############################      config apache      ##########################################
#aws s3api get-object --bucket ${BucketName} --key config/httpd.conf /etc/httpd/conf/httpd.conf
systemctl start httpd.service
systemctl enable httpd.service
systemctl status httpd.service

usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo “Hello World from $hostname” > /var/www/html/index.html

sleep 1
# OutPut
cat << EOF > /home/ec2-user/outputurl
apache[http://$hostname:80/sample-webapp/] //is your apache
EOF

sleep 1

echo " Done with installations"
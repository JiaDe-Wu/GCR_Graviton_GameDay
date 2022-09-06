### 
### install_redis.sh ec2上安装redis，将自己的DNS吐出去
### Maintained by China PSA team

# Params info

                #   Redisversion|${Redisversion}

#!/bin/bash -xe

##############################      引入参数      ##########################################

function exportParams() {
    Redisversion=`grep 'Redisversion' ${PARAMS_FILE} | awk -F'|' '{print $2}' | sed -e 's/^ *//g;s/ *$//g'`
}


PARAMS_FILE=/tmp/params.txt

Redisversion='NONE'

exportParams

AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
REGION="`echo \"$AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
hostname=`curl -s http://169.254.169.254/latest/meta-data/hostname`

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

##############################      install redis     ##########################################
cd /home/ec2-user/
sudo amazon-linux-extras install epel -y
sudo yum install gcc jemalloc-devel openssl-devel tcl tcl-devel -y
sudo wget https://download.redis.io/releases/redis-$Redisversion.tar.gz  -O ./redis.tar.gz 
#Redisversion=6.0.9
#Redisversion=6.2.7
#Redisversion=7.0.4

sudo tar xvzf redis.tar.gz
cd redis-$Redisversion
sudo make BUILD_TLS=yes



sudo sed -i "s|protected-mode yes|protected-mode no|g" /home/ec2-user/redis-$Redisversion/redis.conf
sudo sed -i "s|bind 127.0.0.1|bind $hostname|g" /home/ec2-user/redis-$Redisversion/redis.conf
sudo /home/ec2-user/redis-$Redisversion/src/redis-server /home/ec2-user/redis-$Redisversion/redis.conf &

sleep 1

# OutPut
cat << EOF > /home/ec2-user/outputurl
Redis_On_ec2[$hostname:6379] // Here is your redis
EOF



echo " Done with installations"
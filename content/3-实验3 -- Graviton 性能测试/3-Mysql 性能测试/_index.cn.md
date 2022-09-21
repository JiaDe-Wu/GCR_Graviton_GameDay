+++
title = "Mysql 性能测试"
date = 2019-11-01T16:13:49-07:00
weight = 33
chapter = false
pre = "<b></b>"
+++




{{% notice info %}}
目标：通过对常规的mysql数据库性能测试，使学员快速了解到在X86架构和ARM架构的性能差异，以及熟练使用sysbench测试工具，分析比较不同架构的数据库性能差异.
{{% /notice  %}} 

##架构图
![](/images/Mysqltest-ac.png)

##1 测试前准备工作
1.1按照架构图部署测试环境，现有环境中部署3台主机，分别是1台压测服务器，提供压测，2台mysql服务器，1台X86，1台ARM架构，Mysql使用8.0版本

1.2 创建压测服务器，创建压测服务器，如果已经完成Java测试，请继续延续使用Java压测的服务器，无需创建新的主机

1.3 创建gravition-mysql目标主机

创建EC2如下：

    名称： gravition-mysql
    实例类型：r6g.xlarge
    Amazon Machine Image（AMI）： Amazon Linux 2 AMI（HVM）
    架构：64位（ARM）
    密钥对名称：自己创建的密钥对
    VPC： lab
    安全组：lab
    存储：默认
    配置用户数据：


## 2 Mysql 服务器环境部署

## 2.1使用putty或者第三方工具登录gravition-java目标服务器，也可以使用aws ssm工具登录

在r6g.xlarge的EC2上部署redis，请执行一下命令



```
sudo yum install https://dev.mysql.com/get/mysql80-community-release-el7-5.noarch.rpm
sudo systemctl enable --now mysqld

systemctl status mysqld

```

#A superuser account ‘root’@’localhost is created with initial password set and stored in the error log file. To reveal it, use the following command:
sudo grep 'temporary password' /var/log/mysqld.log

sudo mysql_secure_installation -p

所有的选项选Y即可，修改root账号的new password: Gravition2!

登录mysql，并且输入刚才修改好的密码Gravition2!

mysql -uroot -p

创建一个mysql测试用的账号gravition，并且给予次账号远程访问的权限，

ALTER USER 'root' IDENTIFIED WITH mysql_native_password BY 'Gravition2!';
CREATE USER 'graviton'@'%' IDENTIFIED BY 'Graviton2!';
GRANT ALL PRIVILEGES ON *.* TO 'graviton'@'%';
ALTER USER 'graviton' IDENTIFIED WITH mysql_native_password BY 'Graviton2!';

最后输入quit突出数据库命令行

优化mysql，请更改 mysql 配置文件：

sudo vim /etc/my.cnf


配置参数如下
[mysqld]
ssl=0
performance_schema=OFF
skip_log_bin
server_id = 7

# general
table_open_cache = 200000
table_open_cache_instances=64
back_log=3500
max_connections=4000
 join_buffer_size=256K
 sort_buffer_size=256K

# files
innodb_file_per_table
innodb_log_file_size=2G
innodb_log_files_in_group=2
innodb_open_files=4000

# buffers
innodb_buffer_pool_size=24000
innodb_buffer_pool_instances=8
innodb_page_cleaners=8
innodb_log_buffer_size=64M

default_storage_engine=InnoDB
innodb_flush_log_at_trx_commit  = 1
innodb_doublewrite= 1
innodb_flush_method= O_DIRECT
innodb_file_per_table= 1
innodb_io_capacity=2000
innodb_io_capacity_max=4000
innodb_flush_neighbors=0
max_prepared_stmt_count=1000000
bind_address = 0.0.0.0
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

重启 mysql: 

sudo systemctl restart mysqld


请在其他主机上安装 sysbench

curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash
sudo yum -y install sysbench

并使用以上的步骤，安装mysql数据库，并初始化配置

## 3 开始测试数据库性能

3.1请执行一下命令开始测试数据库性能

sysbench oltp_read_only --threads=4 --mysql-user=root --mysql-password=Gravition2! --table-size=10000000 --tables=10 --db-driver=mysql --mysql-db=sbtest prepare

sysbench oltp_read_only --time=300 --threads=4 --table-size=1000000 --mysql-host=<your mysql IP> --mysql-user=root --mysql-password='Gravition2!' --db-driver=mysql --mysql-db=sbtest run

执行结果如下图

![](/images/mysql1.png)

3.2 请观察目标主机的CPU使用率

分别在主机上安装htop工具

sudo yum -y install htop
htop

执行结果如下图

![](/images/mysql2.png)

## 4 测试总结

通过记录和分析X86和ARM架构的测试数据，我们可以看出两种不同架构服务器性能的差异
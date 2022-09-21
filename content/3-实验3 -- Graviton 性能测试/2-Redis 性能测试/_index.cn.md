+++
title = "Redis 性能测试"
date = 2019-11-01T16:13:49-07:00
weight = 32
chapter = false
pre = "<b></b>"
+++


{{% notice info %}}
目标：通过对常规的Redis性能测试，使学员快速了解到在X86架构和ARM架构的性能差异，以及熟练使用benchmark压力测试工具，分析比较不同架构的Redis性能差异.
{{% /notice  %}} 

##架构图
![](/images/Redistest-ac.png)

##1 测试前准备工作
1.1按照架构图部署测试环境，现有环境中部署3台主机，分别是1台压测服务器，提供压测，2台Redis服务器，1台X86，1台ARM架构

1.2 创建压测服务器，如果已经完成Java测试，请继续延续使用Java压测的服务器，无需创建新的主机

1.3 创建gravition-redis目标主机

    名称： gravition-redis
    实例类型：r6g.xlarge
    Amazon Machine Image（AMI）： Amazon Linux 2 AMI（HVM）
    架构：64位（ARM）
    密钥对名称：自己创建的密钥对
    VPC： lab
    安全组：lab
    存储：默认
    配置用户数据：


## 2 Redis 服务器环境部署

## 2.1使用putty或者第三方工具登录gravition-java目标服务器，也可以使用aws ssm工具登录
在r6g.xlarge的EC2上部署redis，请执行一下命令

```
sudo yum -y groupinstall "Development Tools"
git clone --recursive --depth 1 --branch 6.0.9 https://github.com/redis/redis.git
cd redis
make
sed -i 's/^bind 127.*$/bind 0\.0\.0\.0 ::1/' redis.conf
echo 'save ""' >> redis.conf
./src/redis-server redis.conf
```
执行完命令效果如下，redis已经成功运行

![](/images/redis1.png)

## 2.2 部署benchmark压测服务，使用putty或者第三方工具登录gravition-java目标服务器，也可以使用aws ssm工具登录

请在stress-test压测服务器上执行以下命令

```
sudo yum -y groupinstall "Development Tools"
sudo yum install -y autoconf automake make gcc-c++
sudo yum install -y pcre-devel zlib-devel libmemcached-devel libevent-devel openssl-devel
git clone https://github.com/RedisLabs/memtier_benchmark.git
cd memtier_benchmark/
autoreconf -ivf
 ./configure
make
sudo make install
```

执行完毕离开此页面即可。

## 3 开始对redis进行压力测试
请下载压测excel模版文档，对与压测结果进行记录和比较

3.1 请在stress-test压测服务器上执行以下命令，请把<redis server private IP>替换成你的Redis服务器的私网IP

```
memtier_benchmark -s <redis server private IP> --run-count 5 --data-size=128 --out-file bench_out --ratio 1:1 --threads=5 --key-pattern S:S -c 50
```
执行结果如下图

![](/images/redis2.png)

参数说明

3.2 请执行一下命令，查询本次压测的结果
在memtier_benchmark的目录下有个bench_out的log文档，

```
cat bench_out
```
执行完结果如下
![](/images/redis3.png)

请找到如下图的结果
![](/images/redis4.png)

参数说明，我们主要看以下3个指标，并且把记过保存到测试模版的excel文档中，注意区分X86和ARM服务器的不同性能。

	Total：吞吐量
 	Avg. Latency
	 p99 Latency

## 4 测试总结

通过测试的最终数据展示，我们可以发现ARM架构gravition的服务器在吞吐量和延迟上的表现有明显优势

测试结束请不要关闭压测服务器，以待数据库压测使用。
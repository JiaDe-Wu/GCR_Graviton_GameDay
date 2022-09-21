+++
title = "应用层迁移"
date = 2019-11-01T16:13:49-07:00
weight = 22
chapter = false
pre = "<b></b>"
+++



{{% notice info %}}
目标：通过本次应用迁移实验，使学员掌握了解常见Java的应用环境的迁移。
{{% /notice  %}}

### 应用迁移说明
在云计算时代，由于功耗低、高性能以及指令集的优势，越来越多的云厂商开始选择基于ARM体系来构建云服务。小汪公司的业务系统主要采用的是基于Java环境的应用，IT部正在对于系统从X86迁移到ARM环境提出了质疑，业务系统迁移到新的ARM架构中是否能够正常运维，迁移的可行性，POC等问题困扰着IT和业务部门。

那么常规的应用迁移步骤，如Java Python Go C++，不同语言如何迁移？
在以当前以java应用实例，如何做适配迁移，
我们需要考虑应用的兼容性（arm平台兼容的JVM），迁移源和目标的系统环境，确认是否使用那些第三方的库，依赖包的重新编译等。
又如：C/C++程序是计算机系统级别最为成功的语言之一。业界存在大量的知名开源软件基于C/C++构建，比如Windows/Linux操作系统自身，从源代码演变成运行中的进程，需要经历编译、汇编、链接、运行等一系列过程。



## 应用层迁移场景
本次迁移的实验环境为一套XX系统，

### 1. 应用评估
从X86到arm环境，我们首先需要对迁移的环境做评估，应该包含以下几个纬度

* 目标端硬件信息收集
* 目标端的软件栈信息收集
* 迁移分析，对收集到的信息做分析，主要分为代码迁移和软件包迁移

Java程序是基于jvm区运行的，所以需要使用arm平台兼容的JVM。


### 2. 目标端主机安装和配置

创建EC2，在左侧的控制台导航菜单选择EC2 Dashboard（EC2控制面板）

首先在控制台中上方搜索栏搜索 EC2，并从结果列表中选中此服务。

验证控制台右上角的Region（区域）是否与本次实验的Region值一致，然后从列表中选择 Launch instance（启动实例）下拉菜单，启动实例

选择启动实例
注意：架构处的下拉框请选中 64位（ARM），如下图
![](/images/graviton-AMI.png)

启动实例的参数如下：

创建EC2如下：

    名称： target APP
    实例类型：c6g.large
    密钥对名称：自己的用户名
    VPC： lab
    安全组：lab
    存储：默认
    
    角色：
    配置用户数据:
       #!/bin/sh
       #sudo yum groupinstall -y 'Development Tools'
       #yum install -y openssl-devel  java-11-amazon-corretto-headless maven
       #get ...

### 3. 应用迁移实施

![rds_benchmark](/images/rds_benchmark_3.png)

3.1使用登录SSM的远程连接管理器或者Putty连接EC2

连接方法请参考web迁移的2.2部分

![rds_benchmark](/images/SSM_connect_1.png)

3.2 部署应用相关的arm环境中的JVM环境，依赖包等


3.3 部署应用软件

3.4 启动应用软件


### 4。应用测试和验证

![rds_benchmark](/images/rds_benchmark_4.png)

测试应用软件的端口和返回值

### 5.总结

![rds_benchmark](/images/rds_benchmark_5.png)



### 参考链接

![rds_benchmark](/images/rds_benchmark_6.png)

## Appendix


* Go迁移的案例
* Python迁移 X86-ARM
* C++从X86-ARM


+++
title = "WEB层迁移"
date = 2019-11-01T16:13:49-07:00
weight = 23
chapter = false
pre = "<b></b>"
+++




{{% notice info %}}
目标：通过对常规的WEB层应用-apache迁移实验，使学员快速掌握WEB层应用如何使用Graviton创建和部署，以及如何迁移.
{{% /notice  %}}
## WEB层迁移场景

小汪公司是一个互联网企业，现在有一个电商系统，前端使用的是Nginx，原系统使用的是传统的X86部署，现在出于将本增效的目的，需要把系统迁移到AWS Graviton3架构的EC2主机上，并且希望能够把数据和配置都迁移到新的ARM架构系统上

### 1. 迁移前的准备工作

1.1登录实验账号

请参考“登录实验环境账号—登录AWS EventEngine说明”

1.2确认源端和目标端信息

在aws控制台查看一台X86架构的EC2主机，并且已安装nginx

![](/images/EC2-01.png)

Nginx的配置文件路径 /etc/nginx/conf.d/*.conf
网站目录路径： /usr/share/nginx/



- 需要把nginx的配置文件迁移到目标ARM服务器
- 需要把网站的数据迁移到目标ARM服务器
- 考虑对应的权限问题。

1.3 创建一个密钥

在左侧的控制台导航菜单选择EC2 Dashboard，选密钥对， 点击创建密钥对
![](/images/ec2-lab-01.png)

Name请使用自己的名字或小组名的拼音，创建一个.pem的key
![](/images/ec2-lab-02.png)

第一次创建.pem时，提示请下载时并妥善保存，只有创建时这一次下载机会。

1.4 创建一个AK，SK
首先在控制台中上方搜索栏搜索 IAM，并从结果列表中选中此服务。

然后从列表中选择 用户，并且选中自己的用户名，继续如下图操作
![](/images/AKSK-01.png)
请及时下载AKSK的CSV文件，并且妥善保存
![](/images/AKSK-02.png)

___

### 2. 创建GRAVITON的EC2实例

2.1 导航到EC2控制台

创建EC2，在左侧的控制台导航菜单选择EC2 Dashboard（EC2控制面板）

首先在控制台中上方搜索栏搜索 EC2，并从结果列表中选中此服务。

验证控制台右上角的Region（区域）是否与本次实验的Region值一致，然后从列表中选择 Launch instance（启动实例）下拉菜单，启动实例

选择启动实例
注意：架构处的下拉框请选中 64位（ARM），如下图
![](/images/graviton-AMI.png)

启动实例的参数如下：

创建EC2如下：

    名称： target Nginx
    实例类型：c6g.large
    Amazon Machine Image（AMI）： Amazon Linux 2 AMI（HVM）
    架构：64位（ARM）
    密钥对名称：自己的用户名
    VPC： lab
    安全组：lab
    存储：默认
    配置用户数据：
	
	
    角色：


最后点击启动实例按钮在，请在summary（汇总）核对下参数信息。
启动完毕EC2后，可以悬着 View all instance（查看所有实例），等待实例的状态显示为Running（正在运行），这表示实例已完成启动。

![](/images/EC2-01.png)


### 2.2 部署nginx
可以验证当前的nginx的前端页面是否已经启动。
可以查看一下当前EC2的公网IP地址,然后在浏览器上输入,得到以下页面
![](/images/EC2-web.png)

方法1，使用putty等linux工具连接到EC2，
打开putty，指定pem文件，服务器地址

Amazon的EC2中，默认是不允许使用用户名和密码直接连接Instance的，而是通过AWS (Amazon Web Service)提供的证书。在第一次使用EC2的时候，AWS会要求你创建一个证书并下载，证书是一个.pem文件。

![](/images/putty-session-config-01.png)

Host Name (主机名) 框中，输入 主机DNS或者公网IP地址

Amazon Linux AMI，用户名称是 ec2-user

端口： 22

在 Category (类别) 窗格中，展开 Connection (连接)，再展开 SSH，然后选择 Auth (身份验证)。完成以下操作：

单击 Browse (浏览)。

选择您为密钥对生成的 .ppk 或 .pem 文件，然后单击 Open (打开)。

如果这是您第一次连接到此实例，PuTTY 会显示安全警告对话框，询问您是否信任您要连接到的主机。请单击Yes
___

方法2，使用AWS 的 SSM 工具链接
点击， 确认你的EC2是否具有对应的ssm 角色

在左侧的控制台导航菜单选择EC2 Dashboard（EC2控制面板）
首先在控制台中上方搜索栏搜索 EC2，并从结果列表中选中此服务。然后选中对应的EC2，点击操作按钮，安全，编辑IAM角色。
![](/images/ec2-lab-sessionmanager-08.png)
如果已经有对应的SSM角色，则说明有SSM连接的权限。
![](/images/EC2-lab-03.png)

点击连接按钮，
![](/images/ec2-lab-09.png)
选择会话管理器session manager，点击连接，进入这台EC2的操作系统命令行界面
![](/images/ec2-lab-sessionmanager-11.png)


安装nginx，请执行以下命令，安装nginx，

	sudo amazon-linux-extras install -y nginx1
        systemctl enable nginx
        systemctl start nginx
	


### 3. 迁移Nginx实例

使用复制功能，复制nginx的配置文件

首先创建一个bucket桶

在左侧的控制台导航菜单选择S3 Dashboard（EC2控制面板）
首先在控制台中上方搜索栏搜索 S3，并从结果列表中选中此服务。然后选中对应的S3，点击操作按钮
点击创建桶
![](/images/gid-s3-02.png)
桶名请使用自己的组名+姓名的拼音命名。 最后点击创建
![](/images/gid-s3-03.png)

把文件上传到S3

源端的nginx已经安装AWS CLI

然后拷贝到目标服务器的对应目录

使用AWS CLi命令

	aws configure

填写AK，SK以及默认登录的地域等信息

        AWS Access Key ID [None]:
        AWS Secret Access Key [None]:
        Default region name [None]:
        Default output format [None]:

复制存储桶的对象文件

        aws s3 cp s3://yourbucket/nginx.conf /etc/nginx/conf.d/
        aws s3 cp s3://yourbucket/web /usr/share/nginx/


### 4. 验证迁移结果

访问EC2的公网地址。
查询方法
打开web浏览器，输入EC2公网地址，会见到以下页面




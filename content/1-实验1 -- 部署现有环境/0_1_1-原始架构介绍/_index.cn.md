+++
title = "原始系统架构介绍"
chapter = false
weight = 11
+++

***使用 CloudFormation 部署 Graviton Game Day 架构***
*   本实验中，我们将通过CloudFormation部署Graviton-GameDay原架构，部署完成后您将得到一个X86环境下典型的3层架构。您将基于此环境进行后续的GameDay实验，并赢得知识成就和比赛得分。
  
*   CloudFormation将为您快速部署下图的GameDay原始环境

![](/images/gamedayaws.png)

#### 资源清单

我们将使用CloudFormation模板配置以下资源：

1. 新建VPC，包含两个公有子网、两个私有子网，Internet网关和安全组以对外提供服务并支持安全访问控制。
2. 一台堡垒机EC2实例，创建将被放置在公有子网，是整套环境ssh的唯一入口对下游组件它将向架构前后端进行配置管理，对公网您可以配置只有您的本地IP地址可以与之通讯
3. 一台EC2用于部署Apache Web服务器`Apache HTTP Server ("httpd") `,放置在公有子网，他在公网上提供Tomcat的Web服务(使用了apache-tomcat-9.0.41转发应用服务器请求)
4. 一台EC2用于部署由Java 编写的 Tomcat `Apache Tomcat®` 应用程序,这是一个联系人管理系统的示例应用。他被放置在私有子网。
5. 一台EC2用于部署 Redis，该 Redis 与 Tomcat 缓存集成，用于保持用户的登录状态（使用了 Redisson Session Manager for Tomcat），他被放置在私有子网。
6. 一台EC2用于部署 MySQL，该 MySQL 与 Tomcat 数据库集成，可操作数据库的增删改查，他被放置在私有子网。
7. 部署AWS CloudFront 以Web服务器为源`Apache HTTP Server ("httpd") `,他提供动态加速，并提供了证书、迁移割接的便利性。
8. 新建安全组，包括 堡垒机/Web/App/DB 4个安全组，用户整套环境的最小访问权限控制。
9.  Amazon S3存储桶，用于保存整套环境的`源码和配置文件`。
10. IAM角色，堡垒机/Apache/Tomcat/Redis/MySQL.5个role用于管理整套环境服务权限
11. 您通过多达20种参数的自定义在集群创建之初即完成优化配置，这些参数都有默认值，是我们游戏日推荐的迁移和测试配置。（您可以在CloudFormation参数页面自定义配置参数）
12. 为方便内部测试，模板将为您的每台实例自动加载`AmazonSSMManagedInstanceCore`权限以满足PVRE合规要求，请放心食用



+++
title = "活动介绍"
chapter = false
weight = 5
+++

# GCR Graviton Game DAY


嗨，您好！欢迎来到中国区AWS APN动手训练营 GCR Graviton Game Day


![](/images/apn-logo.jpg)


{{% notice info %}}
要完成标准训练营内容，大约需要8小时。请各位学员合理安排好时间，手机调至静音。
{{% /notice  %}}
### 目标受众

训练营目标受众是AWS用户解决方案架构师、运维工程师，合作伙伴架构师、售前工程师。

---
### Game DAY 目标
通过本次培训

1，学员能熟练掌握Graviton实例的开通，配置，报价以及价格对比

2，学员能了解常见应用的迁移，如Apache，Java，Redis，Mysql等场景

3，学员能为客户宣讲ARM架构迁移的方案PPT,具备Graviton售前能力

4，学员能够具备Graviton性能测试能力

### 背景描述

小汪公司是国内高速发展的互联网企业。在过去3年的高速发展中，小汪公司IT资源已于初期的数台服务器单体架构演变成当前由划分业务的多中心多平台超500台实例的大型公有云集群，所有应用基于x86架构。近日，小汪公司经历了一次性能事故和内部成本核算会议，他们发现一些行业内先进的竞争对手在IT资源财报支出上要比他们低得多，并且在大促活动抗压能力和单日数据处理能力上体现出更高的性能。小汪公司即刻决定，对市场发起公开招标，要求供应商以咨询加交付的方式为小汪公司节省20%以上的成本，并提升10%以上的性能。

### YYY公司(由各位参加游戏的专家分成小组代表不同应标公司)需要在活动中完成5个动作：

* 1，理解甲方提供的现状材料，以Graviton为核心为客户设计降本增效的方案，并向甲方讲标。

    讲标模版PPT可以参考此链接（TODO），各小组可以自行调整讲标PPT内容

* 2，通过CloudFormation launch甲方当前的IT环境，包括，1台javaEC2、mysql、redis、nginx， 
* 3，按照讲标设计的方案对甲方现有环境进行迁移，验证业务可行性，整体方案。
* 4，按照甲方提供的测试脚本进行迁移后的性能测试，出具测试报告，测试报告参考链接（Todo），各小组可以自行调整。
* 5，为甲方核算综合性价比，提供降本增效优化建议


小汪公司将查看并点评每家供应商的交付物，公开每家供应商的成本节省率和性能优化率，评选中标供应商


![](/images/GameDay-1260x630.jpg)

#### 实验架构特点
***模拟一个生产级别的示范应用三层架构，包含：***

* Apache前端
* 基于Java的一个jar包应用程序，
* redis
* mysql


***这是由甲方提供的环境架构图，我们计划从此三层的X86环境迁移到ARM的三层架构，过程中您将使用不同的迁移手段和迁移工具***
![](/images/gamedayaws.png)

您将通过CloudFormation去创建原始环境，若您有兴趣，您可以下载保存[CloudFormation源代码](https://awspsa-quickstart.s3.cn-northwest-1.amazonaws.com.cn/gravitongameday/1_graviton-gameday-master.template)

# 现有环节的成本总结评估 todo

* 计算EC2-X86每月按需成本  ____$
* 计算EC2-X86每年按需成本  ____$
* 计算EC2-ARM每月按需成本  ____$
* 计算EC2-ARM每年按需成本  ____$
* 计算ARM架构的EC2每年节约成本百分比。 （EC2-X86年成本-EC2-ARM年成本）/EC2-ARM年成本= ____%

# 现有环节的性能测试表 todo

可以预先下载测试报告模版（Todo），下载链接


## AWS Graviton 处理器
#### 在 Amazon EC2 中实现更高性价比


AWS 设计的 AWS Graviton 处理器为 Amazon EC2 中运行的云工作负载提供最佳性价比。

与第一代 AWS Graviton 处理器相比，AWS Graviton2 处理器不管在性能还是功能上都实现了巨大的飞跃。基于 Graviton2 的实例为 Amazon EC2 中的工作负载提供最佳性价比。基于 Graviton2 的实例支持广泛的通用型、突发型、计算优化型、内存优化型、存储优化型和加速计算型工作负载，包括应用程序服务器、微服务、高性能计算 (HPC)、基于 CPU 的机器学习 (ML) 推理、视频编码、电子设计自动化、游戏、开源数据库和内存中的缓存。许多 AWS 服务（包括 Amazon Aurora、Amazon ElastiCache、Amazon EMR、AWS Lambda 和 AWS Fargate）也支持基于 Graviton2 的实例，以获得具有显著性价比优势的完全托管式体验。包括 Epic Games、DIRECTV、Intuit、Lyft 和 Formula 1 在内数以千计的客户在基于 Graviton2 的实例上运行生产工作负载，既显著提升了性能，又节省了成本。

AWS Graviton3 处理器是 AWS Graviton 处理器系列中的最新产品。与 AWS Graviton2 处理器相比，它们的计算性能提高多达 25%，浮点性能提高多达 2 倍，以及加密工作负载性能最多加快 2 倍。针对机器学习 (ML) 工作负载，AWS Graviton3 处理器所提供的性能比 AWS Graviton2 处理器高出多达 3 倍，并支持 bfloat16。它们还支持 DDR5 内存，相比 DDR4 内存带宽增加了 50%。





### 预期费用

您需要在您的AWS账户中运行此动手训练营时所使用的AWS服务的成本支付费用。截至发布之日，按计划中的实验基准成本应为：

* S3 ：< 0.1 $
* EC2：< 20 $
* VPC < 1 $


### 支持区域
```
    ap-northeast-1:
    ap-northeast-2:
    ap-southeast-1:
    ap-southeast-2:
    eu-central-1:
    sa-east-1:
    us-east-1:
    us-east-2:
    us-west-1:
    us-west-2:
```

{{% notice tip %}}
成本管理标签：我们建议您无论何时创建云资源，都对其进行标记。请您尝试在实验期间为实验资源设置统一的标记字段，例如项目：awschinaworkshop
{{% /notice %}}





{{% button href="https://issues.amazon.com/issues/create?template=f084dc94-e920-4d98-80f7-252d5cc7ce00" icon="fas fa-bug" %}}反馈您遇到的问题{{% /button %}}


{{% button href="mailto:wjiad@amazon.com" icon="fas fa-envelope" %}}联系本页面作者{{% /button %}}


{{% button href="https://w.amazon.com/bin/view/AWS/Teams/SA/Customer_Engagements/" icon="fas fa-graduation-cap" %}}了解更多的AWS动手训练营{{% /button %}}



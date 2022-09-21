+++
title = "CloudFormation部署"
chapter = false
weight = 12
+++




***实验选项***

如果您是一`个人使用自己的AWS账户`或是`使用PSA导师发送的AWS Event Engine账号`进行实验，建议您使用`cloudformation`启动环境。而如果您是`多人使用同一账户的不同IAM User`进行实验，建议您`手动搭建环境`进行实验，并在必要时明确区别您和他人的资源命名，例如在任何资源名后加入`-user1`。
  - [cloudformation搭建环境](#使用cloudformation搭建环境)



##### 登录实验环境账号---登录AWS EventEngine说明

如果您登录AWS Wokshop门户继续进行实验，则需要团队哈希值。单击此处，输入从活动组织者处收到的12位参与者哈希代码。这将更改右下角的按钮以接受条款和登录。单击该按钮继续下一步
![](/images/event-engine-01.png)
单击电子邮件一次性密码（OTP）按钮。
![](/images/Event_Engine_New.png)
写下您自己的电子邮件帐户，然后单击“发送代码”按钮。
![](/images/Event_Engine_New_Two.png)
在电子邮件收件箱中，检查您的一次性密码电子邮件主题，并复制密码。粘贴复制的密码，如下所示，然后按“登录”按钮。
![](/images/Event_Engine_New_Four.png)
在下一个屏幕上，按AWS控制台按钮接收登录链接以登录控制台。
![](/images/Event_Engine_New_Five.png)
单击打开AWS控制台按钮时，访问AWS管理控制台页面。此外，还可以找到环境的CLI访问和密钥访问密钥。
![](/images/event-engine-02.png)
完成以上所有步骤后，即可开始实验室

##### 使用cloudformation搭建环境

1.使用有效凭证登录AWS控制台

2.选择AWS区域。 此实验室的首选区域是`us-west-1`。

* 您可以点击以下的 Launch Stack ，这样将直接跳转到首选区域的堆栈创建页面

| 账户所属 | 实验模板 |
|:-------------:|:-------------:|
|    海外区域账户  | [![](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-1#/stacks/new?stackName=Graviton-GameDay&templateURL=https://awspsa-quickstart.s3.cn-northwest-1.amazonaws.com.cn/gravitongameday/1_graviton-gameday-master.template) |


4.在cloudformation Parameters创建页面，您可以对不同参数进行选择配置，如下图必选的参数为`KeyPairName`/`AvailabilityZones`。 其他参数您可以自定义或按照默认值进行。

![](/images/cloudformation配置.jpeg)


5.在cloudformation 预览页面，请勾选点击确认cloudformation有权创建IAM 角色。

![](/images/cloudformation确认.jpeg)


等待cloudformation供应所有资源。 大约需要35分钟才能完成执行

![](/images/cloudformation创建中.png)

6.cloudformation部署成功，包含4个内嵌stack，主stack为`Graviton-GameDay`

![cloudformation Console output](/images/cloudformation完成.png)

7.点击`Graviton-GameDay`进入output，即可查看您可访问的多个URL，其中您的公网入口为CloudFrontDNS的URL，他将允许您在参数中定义的`AccessCIDR`访问。

![cloudformation Console output](/images/cloudformation输出.png)


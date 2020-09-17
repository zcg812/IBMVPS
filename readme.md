### 1. 我们利用开源免费的Cloud Foundry项目来搭建V2ray

##### 1.1. 申请IBM免费VPS
> 地址：https://cloud.ibm.com/

# 1.2. V2ray一键安装代码(9月12日 00:01 更新)

```
wget --no-check-certificate -O install.sh https://github.com/cyberxsboy/IBMVPS/master/install.sh && chmod +x install.sh  && ./install.sh

```

> 注意事项：
>> 1. 记住填写的 应用名称 建议写：bigfang 
>> 2. 内存大小选择256m
>> 3. 一键安装完成后 保存生成VMESS链接

##### 1.3. 客户端配置

导入vmess链接

### 2. 利用Github创建每周开关机一次任务

##### 2.1. 项目地址
> https://github.com/cyberxsboy/IBMVPS

在项目里点击Fork，这样就复制程序到自己的Github里面

##### 2.2. 建立4项secret

> IBM_ACCOUNT // IBM Cloud的登录邮箱和密码
```
your@email.com  
password
```
> IBM_APP_NAME // 应用的名称
```
bigfang
```

> REGION_NUM // 区域编码
```
7
```

> RESOURSE_ID // 资源组ID
```
你的ID
```

>> 如何查找RESOURSE_ID？
>>> *打开IBM cloud shell，输入下面代码*

```
ibmcloud resource groups
```
 >>> *显示出来的ID就是你的RESOURSE_ID*
 
 
##### 2.3. 运行IBM项目

###### 2.3.1. 点击Actions，再点击绿色的框  
###### 2.3.2. 再点击Code--github/workflows---ibm.yml--右边的编辑按钮 修改一下第37行  
修改完点击start commit。
再回到Actions就能看到正在运行的项目，等到变成绿色的对号就运行了

### 3. cloudflare加速

登陆Cloudflare官网点击workers--创建--复制脚本--修改对应域名

```
addEventListener(
"fetch",event => {
let url=new URL(event.request.url);
url.hostname="bigfang.us-south.cf.appdomain.cloud";
let request=new Request(url,event.request);
event. respondWith(
fetch(request)
)
}
)
```

点击“发送”出现404也没有问题 直接保存部署
这时候会给一个网址，..workers.dev域名,这是cloudflare中转的域名

### 4. 客户端配置


### 5. 找回Vmess链接  


wget --no-check-certificate -O vmess.sh https://github.com/cyberxsboy/IBMVPS/master/vmess.sh && chmod +x vmess.sh  && ./vmess.sh


=============================================================  
=============================================================  
原作者代码库：https://github.com/bigfangfang/IBMVPS


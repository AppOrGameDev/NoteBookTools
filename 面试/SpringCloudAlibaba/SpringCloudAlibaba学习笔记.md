SpringCloudAlibaba学习笔记

## 微服务启动管理

`Services`代替idea老版本中的`run dashbord`

## 版本配套管理

> https://github.com/alibaba/spring-cloud-alibaba/wiki/%E7%89%88%E6%9C%AC%E8%AF%B4%E6%98%8E

## Nacos集群部署

> Ruoyi-Cloud默认连接Nacos地址:127.0.0.1:8848
>
> `server.port=8848`
>
> Nacos集群
>
> 127.0.0.1:8849
>
> 127.0.0.1:8850
>
> 127.0.0.1:8851

> 配套修改点
>
> `startup.cmd` 
>
> 集群部署 line 26 `set MODE="cluster"`
>
> JVM内存参数 line 68
>
> `NACOS_JVM_OPTS=-server -Xms512m -Xmx512m -Xmn256m`
>
> 
>
> `application.properties`
>
> 端口号 line 23 `server.port=8849`
>
> 集群部署 数据都只能使用MySQL集中管理 
>
> ```properties
> spring.datasource.platform=mysql
> db.num=1
> db.url.0=jdbc:mysql://localhost:3306/ry-config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC
> db.user.0=root
> db.password.0=12345678
> ```
>
> `cluster.conf`
>
> 参考cluster.conf.example文件复制一份`cluster.conf`
>
> ```conf
> 127.0.0.1:8849
> 127.0.0.1:8850
> 127.0.0.1:8851
> ```
>

> 启用权限
>
> `application.properties`
>
> `nacos.core.auth.enabled=true`

### 查看端口被占用

> ```SHELL
> # Windows命令
> netstat -ano | findstr 8848
> # linux命令
> netstat -tunlp | grep 8848
> ```
>
> 

> ```shell
> # windows 命令
> tasklist | findstr 14548 
> # 如果是Linux部署请使用下面这个命令
> ps -ef | grep 14548 
> ```

> ```shell
> # Windows杀死进程
> taskkill /pid 14548 -f
> # linux杀死进程
> kill -9 14548
> ```
>
> 

## win11 安装Nginx

> https://blog.csdn.net/weixin_46560589/article/details/125661743

> 修改`conf/nginx.conf`
>
> 端口默认是在8848的基础上便宜1000和1001，所以每启动一个Nacos都会占用三个端口`8848/9848/9849`
>
> `只解决了Nacos管理面8848的反向代理,放在http中`
>
> ```conf
> 	upstream nacoscluster {
> 		server 127.0.0.1:8849;
> 		server 127.0.0.1:8851;
> 		server 127.0.0.1:8853;
> 	}
> 
> 	server {
>      listen       8848;
>      server_name  localhost;
>      location /nacos/ {
>          proxy_pass http://nacoscluster/nacos/;
>      }
> 	}
> ```
>
> `Nacos2.0版本后grpc新增的两个端口号9848、9849怎么处理`
>
> `Nacos2.X版本相比1.X新增了[gRPC](https://so.csdn.net/so/search?q=gRPC&spm=1001.2101.3001.7020)的通信方式，因此需要增加2个端口。新增端口是在配置的主端口(server.port)基础上，进行一定偏移量自动生成。`
>
> | 端口 | 与主端口的偏移量 | 描述                                                       |
> | :--- | :--------------- | :--------------------------------------------------------- |
> | 9848 | 1000             | 客户端gRPC请求服务端端口，用于客户端向服务端发起连接和请求 |
> | 9849 | 1001             | 服务端gRPC请求服务端端口，用于服务间同步等                 |
>
> `跟http同一级别，新增stream`
>
> ```conf
> stream {
> 	upstream nacosclustergrpc {
> 		server 127.0.0.1:9849;
> 		server 127.0.0.1:9850;
> 		server 127.0.0.1:9851;
> 		server 127.0.0.1:9852;
> 		server 127.0.0.1:9853;
> 		server 127.0.0.1:9854;
> 	}
> 
> 	server {
>      listen       9848;
>      proxy_pass   nacosclustergrpc;
> 	}
> }
> ```
>

# SpringCloudAlibaba学习路线

## 目标是搭建自己的项目模板

> 1. 将B站上教程里面的核心组件梳理出来，然后网上找教程去集成这些组件。
> 2. 参考Ruoyi-Cloud

### 1.初始化SpringCloudAlibaba项目

> 根pom添加SpringCloudAlibaba依赖
>
> ```xml
> ```
>
> 

> 版本配套关系
>
> `2.2.X分支` `适配 Spring Boot 为 2.4`
>
> | Spring Cloud Alibaba Version | Spring Cloud Version     | Spring Boot Version |
> | ---------------------------- | ------------------------ | ------------------- |
> | 2.2.9.RELEASE                | Spring Cloud Hoxton.SR12 | 2.3.12.RELEASE      |
>
> 组件配套关系
>
> `每个 Spring Cloud Alibaba 版本及其自身所适配的各组件对应版本如下表所示（注意，Spring Cloud Dubbo 从 2021.0.1.0 起已被移除出主干，不再随主干演进）：`
>
> | Spring Cloud Alibaba Version | Sentinel Version | Nacos Version | RocketMQ Version | Dubbo Version | Seata Version |
> | ---------------------------- | ---------------- | ------------- | ---------------- | ------------- | ------------- |
> | 2.2.9.RELEASE                | 1.8.5            | 2.1.0         | 4.9.4            | ~             | 1.5.2         |
>
> 

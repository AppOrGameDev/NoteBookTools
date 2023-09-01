# EasyExcel预研

## 预研目标

> 目前项目`fastboot-parent`里面已经有`excel组件`，但是技术比较老，现在是想预研`EasyExcel`是否具备Excel和CSV（最好是能支持，不能支持看是否有备选方案）的导入导出能力，能否集成到`fastboot-parent`中新增一个组件。
>
> 
>
> 不是把之前的老的Excel组件替换成EasyExcel，而是把`EasyExcel`集成到`fastboot-parent`中，现在的版本有需求涉及Excel/CSV导入导出能力，然后直接使用这个新组件。

> 技术实现手段：
>
> - 使用`si-scada`项目引入`EasyExcel`，是否有版本兼容性问题。<strong style="color:green">添加依赖OK，可以正常启动</strong>
> - 编写Excel/CSV导入导出，4个Controller接口。<strong style="color:green">支持Excel/CSV，准备编写测试用例</strong>
> - 使用PostMan验证。<strong style="color:green">CSV验证OK</strong>

> fastboot-dependencies修改EasyExcel的版本号
>
> 重构验证json，Date，DateTime转换类
>
> ![](img/Snipaste_2023-08-23_16-13-21.png)

# EasyExcel技术评审

> 目标：支持Excel和CSV的导入导出和解析
>
> 现状是EasyExcel版本为2.2.7
>
> 技术选型策略：看EasyExcel的最新release版本是否支持Excel和CSV，然后API是否向前兼容。（既解决Excel/CSV同时支持，又尽量少修改历史代码；避免切换新jar包，历史代码需要适配修改的问题）

> 修改点：
>
> http://47.92.146.195:40462/unified-platform/fastboot/-/merge_requests/33
>
> 1. EazyExcel版本2.2.7升级到3.3.2
> 2. 涉及到的代码修改（主要是api变化导致适配修改，对现有逻辑无影响。）![](img/Snipaste_2023-08-23_16-13-21.png)

> 集成到si-scada-biz中测试验证
>
> 1. CSV导入测试。![](img/Snipaste_2023-08-24_12-22-58.png)
> 2. CSV导出测试。![](img/Snipaste_2023-08-24_12-57-22.png)
> 3. Excel导入测试。![](img/Snipaste_2023-08-24_12-55-28.png)
> 4. Excel导出测试。![](img/Snipaste_2023-08-24_12-57-22.png)

# 导入导出组件预研

## 目标

- 导入导出只支持二维表格，表格中都是文本数据（不支持插入图片等二进制数据）
- 后端开发定义好导入导出表的表头(列)
- 导入->预览->确认导入->后端处理（新增/修改）
- 查询->导出
- 下载导入模板

## 测试要点

- 后端开发定义OV/DTO/Bean对象
- 暴露Query/Import/Save/Export五个接口
  - Query查询表头，前端生成Excel/CSV的导入模板。（待定.../宏林说是产品经理定义的,不需要开发实现）
  - Import导入Excel/CSV，解析Excel/CSV，并做字段合法性校验和业务主键唯一性校验，Preview预览导入数据和校验结果。
  - Save保存，
  - Export导出数据。

# 后端Bean定义

```java
@Data
@EqualsAndHashCode
public class DownloadData {

    @ExcelProperty(value = "名称",index = 0)
    @NotBlank(message = "名称不能为空")
    @Length(max = 20, message = "名称长度不能超过20")
    @ApiModelProperty(value = "名称", required = true,example = "测试001abc", position = 0)
    private String name;

    @ExcelProperty(value = "创建时间",index = 1,converter = LocalDateTimeConverter.class)
    @ApiModelProperty(value = "创建时间", required = true,example = "2023-08-28 16:01:00", position = 1)
    private Date createTime;

    @ExcelProperty(value = "价格",index = 2)
    @ApiModelProperty(value = "价格", required = true,example = "123", position = 2)
    private Integer price;
}

// 注解里面定义了value为表头的中文名称,position为表的第几列,example为导出模板的样例
```

`@ExcelProperty(value = "创建时间",index = 1,converter = LocalDateTimeConverter.class)` 定义导出的表头,第几列,格式转换

`读Excel/CSV不根据表头来映射Bean字段,而是根据顺序读取`

```txt
-------------------------------表头英文跟Bean中属性字段映射顺序保持一致-------------------------------
name,createTime,price
haha,2023-08-23 14:35:00,123456
hehe,2023-08-23 14:36:00,987654


-------------------------------中文表头映射正确.csv-------------------------------
名称,创建时间,价格
haha,2023-08-23 14:35:00,123456
hehe,2023-08-23 14:36:00,987654

-------------------------------中文表头顺序不一致,但表内容是映射正确.csv-------------------------------
名称,价格,创建时间
haha,123456,2023-08-23 14:35:00
hehe,987654,2023-08-23 14:36:00

-------------------------------中文表头顺序不一致,表内容映射错误.csv-------------------------------
价格,名称,创建时间
haha,123456,2023-08-23 14:35:00
hehe,987654,2023-08-23 14:36:00

```

![](img/Snipaste_2023-08-29_11-06-56.jpg)

![](img/Snipaste_2023-08-29_11-10-23.jpg)

![](img/Snipaste_2023-08-29_11-10-48.jpg)

---

- 流程图
- 时序图
- 导入时只能全部新增/全部更新
- 更新前后内容一致的更新，是否允许？？？
- 数据校验范围
  - 字段合法性校验
    - string，int，boolean，datetime
    - 手机号码
    - 邮箱
    - 等等
  - 一行记录的逻辑主键唯一性校验。（一个Excel映射一张表）
    - 新增时，不能重复
    - 更新时，主键要存在
- 预览数据校验结果
  - 每一行的校验结果；失败原因。（若有多因，至少显示一条原因）
  - 仅全部校验通过后，才能确认导入。
  - 真正的导入操作采用异步任务执行。（流程图需要补充异步任务队列的部分）

![](img/Excel导入时序图_异步任务保存V1.0.jpg)

![](img/Excel导入通用模板_异步任务保存V1.0.jpg)

# 导入导出基础表设计

## 导入导出操作日志记录表

`import_export_log_records`

| 列名                 | 名称(中文)                        | 数据类型   | 样例                                                         |
| -------------------- | --------------------------------- | ---------- | ------------------------------------------------------------ |
| record_id            | 操作记录ID(主键ID)                | uuid       | 163CDFFE-5F4B-334A-5FB5-DEEAE81E9A24                         |
| customer_id          | 用户ID                            | bigint     | 001                                                          |
| customer_name        | 用户名称                          | vchar(50)  | xux                                                          |
| start_time           | 开始时间                          | datetime   | 2023-08-29 15:28:00                                          |
| end_time             | 结束时间                          | datetime   | 2023-08-29 15:28:00                                          |
| action_object        | 操作对象(导出的用户,工序)         | vchar(256) | USER                                                         |
| action_type          | 操作类型(导入/导出)               | vchar(32)  | import                                                       |
| status               | 当前状态(未开始/进心中/成功/失败) | vchar(32)  | (0:未开始-init/1:进心中-running/2:成功-success/3:失败-failed) |
| success_record_count | 成功记录数                        | int        | 100                                                          |
| failed_record_count  | 失败记录数                        | int        | 0                                                            |

## 导入任务执行记录表

`Import_task_execute_records`

| 列名          | 名称(中文)                            | 数据类型    | 样例                                                         |
| ------------- | ------------------------------------- | ----------- | ------------------------------------------------------------ |
| task_id       | 任务ID/主键ID                         | uuid        | 163CDFFE-5F4B-334A-5FB5-DEEAE81E9A24                         |
| action_object | 操作对象                              | vchar(256)  | USER/TECHNOLOGY                                              |
| task_handler  | 任务处理者                            | vchar(512)  | 导入处理类                                                   |
| file_save_url | 导入文件网络存储路径                  | vchar(1024) | OSS的网络存储路径                                            |
| params        | 参数                                  | vchar(1024) | 辅助参数                                                     |
| status        | 任务执行状态(未开始/进心中/成功/失败) | vchar(32)   | (0:未开始-init/1:进心中-running/2:成功-success/3:失败-failed) |
| create_time   | 任务创建时间                          | datetime    | 前端确认导入的时间                                           |
| start_time    | 任务开始时间                          | datetime    | 导入任务真正被拉起执行的时间                                 |
| end_time      | 任务结束时间                          | datetime    | 导入任务结束的时间                                           |
| consume_time  | 任务耗时(s秒)                         | bigint      | 结束时间-开始时间                                            |
| record_id     | 操作记录ID                            | uuid        | 163CDFFE-5F4B-334A-5FB5-DEEAE81E9A24                         |
| remark        | 备注                                  | vchar(512)  |                                                              |

## 异步任务调度时，同一条导入任务不会被多个执行节点/线程重复执行，加锁

```sql
# 查询一条未开始的任务
select * from Import_task_execute_records where status = 0 and task_type = 'USER_IMPORT' order by create_time limit 1;
# 返回结果非空时，走下一步更新；返回空，重试3次；

# 立即对该任务加锁更新,
update Import_task_execute_records set status=1,start_time = current_time where task_id = 'uuid' and status = 1;
# 影响数据行数为1时，更新(加锁成功)，执行导入任务；影响行数为0，更新失败；返回上一步继续查询。
```

## 校验结果数据结构

```json
{
	"total": 1000,
	"successCount": 900,
	"failedCount": 100,
	"validResult": false,
	"data": [{
		"userName": "张三 ",
		"sex": "male",
		"age": "24",
		"validResult": false,
		"reason": "主键重复"
	}, {
		"userName": "李四",
		"sex": "male",
		"age": "17",
		"validResult": false,
		"reason": "年龄>=18"
	}]
}
```

### 最后确认导入时注意点

> - [x] 即便之前预览校验全部通过，最后异步导入任务执行时，仍然需要做一遍校验，例如我开两个页面，导入相同的数据。那么第二次导入就会全部重复，导入失败。
>
> - [x] 异步导入任务的执行结果是有总数量，成功数量，失败数量；要支持部分成功部分失败的情况。
> - [x] 要么全部新增；要么全部更新；不能部分新增部分更新。
>   - [x] 批量导入时，事务控制在单条记录中。

# 导出（没有异步任务，直接导出）

## 导出勾选的记录

## 导出搜索条件查询的结果



# 异步导入方式的两种方案

```txt
方案一：（弃用）
用户点击确认导入后，后端立即返回前端"开始导入"（前端不需要等待导入全部完成，一直置灰转圈）。用户可以继续跳转到其他页面，只是过段时间后去“查看历史导入日志”中查看之前的导入结果（成功多少条，失败多少条）。

这里面的问题点：
假如有A,B,C三个用户同时导入A 1000条数据,B 10000条数据,C 100000条数据；这样后端服务会同时拉起3个比较繁重的导入任务；导致服务繁忙，没有响应。（高并发场景）
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

方案二：(我想的是这种处理方式)（采纳）
用户点击确认导入后，后端只是记录一条导入任务记录，进入任务队列；但是导入任务真正开始执行，是等待线程池的线程按任务队列挨个处理。

这样比较繁重的导入任务处理速度，就取决于线程池大小（可控）；而不是用户点击确认导入的次数。

用户点击确认导入------------->Task Record------->Task Queue[Task0,Task1,Task2,Task3,Task4,Task5]
															  |     |
														Thread0, Thread1, 多线程挨个处理
```

# 预览页面

## 后端将校验结果按先校验失败，后校验成功的排序，返回给前端。

## 前端自己完成分页操作



# 导入导出操作日志记录

## 操作记录成功/失败数量显示超链接，弹框提示失败详情

> https://lanhuapp.com/web/#/item/project/product?tid=c6cd94d5-cd0f-4fe6-95e3-cd64641003df&pid=ccd7551d-768e-413b-b14e-f5edc9f52487&versionId=6f40c409-b1b6-4ab5-926a-694017e53f55&docId=e3b295dc-071d-4765-9a2c-96890e556b3b&docType=axure&pageId=a515f59255354e6992c3c25e41a21b14&image_id=e3b295dc-071d-4765-9a2c-96890e556b3b&parentId=333215caeab54d159bcf37f35933d7f5
>
> ![](img/Snipaste_2023-08-31_10-46-24.jpg)



# ~~生产环境存在异构网络的问题，暂时放弃mount共享磁盘的方案~~

> 我们设计的服务架构：
>
> 业务用到上传Excel功能的模块有很多，但是他们公用同一个网络存储服务，这些业务服务可能会部署到不同的云服务厂商，不同租户下。（存在跨机房，跨数据中心，跨地域的问题）因此该网络存储服务要能被不同云服务厂商访问到。

> 我们的服务可能存在跨网络，跨服务提供商（阿里云，腾讯云，华为云），OS版本不一样的情况。
>
> mount共享磁盘，适用于同一个局域网或者子网下的场景。
>
> OS版本不一样，导致相关mount的命令脚本不一样。需要写好几个版本的shell脚本。

## ~~Ali OSS 对象存储服务器（不采纳）~~

> https://help.aliyun.com/zh/oss/product-overview/faq-15
>
> 1.OSS提供标准、低频访问、归档、冷归档、深度冷归档多种存储类型，全面覆盖从热到冷的各种数据存储场景。
>
> 2.OSS总存储容量不限制，单个Bucket容量也不限制。
>
> 3.按量收费。收费灵活。
>
> 4.可以跨网络访问。

## ~~Ali ECS 轻量应用服务器（使用vsftpd搭建FTP服务器）（不采纳）~~

> https://help.aliyun.com/zh/simple-application-server/use-cases/build-an-ftp-server?spm=5176.21213303.J_6704733920.7.7f6f53c9EHa35h&scm=20140722.S_help@@%E6%96%87%E6%A1%A3@@60152._.ID_help@@%E6%96%87%E6%A1%A3@@60152-RL_FTP%E6%9C%8D%E5%8A%A1%E5%99%A8-LOC_llm-OR_ser-V_3-RK_rerank-P0_0
>
> 1. 支持一键扩容分区和磁盘，无需重启，服务不中断。
> 1. 这个可能一次性初始化1T，后续不够再加。但无OSS那么多档位，收费不够灵活。
> 1. 可以跨网络访问。

## Ali ECS 轻量应用服务器（使用MinIO搭建OSS服务）(采纳)

>https://doc.iocoder.cn/file/#_4-%E6%96%87%E4%BB%B6%E5%AE%A2%E6%88%B7%E7%AB%AF
>
>芋道源码的方案
>
>1. 基础设施->文件配置管理->添加OSS服务器/FTP服务器/DataBase
>2. 以OSS服务器为例，支持文件管理（上传/删除）
>  1. OSS存储结构key-value形式，路径只是逻辑上的
>
>https://www.iocoder.cn/Spring-Boot/MinIO/?yudao
>
>MinIO自身支持文件列表查询和上传/删除
>
>1.Bucket新建桶
>
>2.添加 readonly 访问规则。Prefix 为 `/` Access 为 `readonly` 的规则。
>
>3.上传文件/文件夹
>
>
>
>案例代码
>
>https://github.com/YunaiV/ruoyi-vue-pro/blob/master/yudao-framework/yudao-spring-boot-starter-file/src/main/java/cn/iocoder/yudao/framework/file/core/client/s3/S3FileClientConfig.java
>
>
>
>TODO
>
>- [x] 确认芋道源码的文件上传下载的页面详细细节。
>
>http://dashboard-vue3.yudao.iocoder.cn/infra/file/file-config
>
>![](img/Snipaste_2023-08-31_11-14-19.jpg)
>
>![](img/Snipaste_2023-08-31_11-15-06.jpg)
>
>![](img/Snipaste_2023-08-31_11-16-21.jpg)
>
>- [ ] 本地VM安装MinIO，确认上传文件夹的能力。
>
>> ```shell
>> Invoke-WebRequest -Uri "https://dl.min.io/server/minio/release/windows-amd64/minio.exe" -OutFile "F:\MinIO\minio.exe" ## 国外资源，龟速下载
>> setx MINIO_ROOT_USER admin
>> setx MINIO_ROOT_PASSWORD password
>> F:\MinIO\minio.exe server F:\MinIO\Data --console-address ":9001" ## F:\Data 存储目录；--console-address 是 UI 界面的端口
>> ```
>>
>> `minio server F:\MinIO\Data --console-address ":9001"`
>
>> CentOS公开的最新版本7.9.2009,内核版本低于4.0.0;MinIO的最新版本要求内核高于4.x版本
>
>```txt
># 启动MinIO
>wget https://dl.min.io/server/minio/release/linux-amd64/minio ## 国外资源，龟速下载
>chmod +x minio
>MINIO_ROOT_USER=admin MINIO_ROOT_PASSWORD=password ./minio server /Users/yunai/minio --console-address ":9001" ## /Users/yunai/minio 存储目录；--console-address 是 UI 界面的端口
>
># 7.9.2009版本不行
># MinIO 要求内核版本高于4.X，CentOS7低于4.0.0版本
># 启动成功
>[root@localhost MinIO]# MINIO_ROOT_USER=admin MINIO_ROOT_PASSWORD=password ./min                                                                                                                              io server /Users/yunai/minio --console-address ":9001"
>WARNING: Detected Linux kernel version older than 4.0.0 release, there are some                                                                                                                               known potential performance problems with this kernel version. MinIO recommends                                                                                                                               a minimum of 4.x.x linux kernel version for best performance
>Formatting 1st pool, 1 set(s), 1 drives per set.
>WARNING: Host local has more than 0 drives of set. A host failure will result in                                                                                                                               data becoming unavailable.
>MinIO Object Storage Server
>Copyright: 2015-2023 MinIO, Inc.
>License: GNU AGPLv3 <https://www.gnu.org/licenses/agpl-3.0.html>
>Version: RELEASE.2023-08-29T23-07-35Z (go1.19.12 linux/amd64)
>
>Status:         1 Online, 0 Offline.
>S3-API: http://192.168.245.129:9000  http://127.0.0.1:9000
>RootUser: admin
>RootPass: password
>
>Console: http://192.168.245.129:9001 http://127.0.0.1:9001
>RootUser: admin
>RootPass: password
>
>Command-line: https://min.io/docs/minio/linux/reference/minio-mc.html#quickstart
>   $ mc alias set myminio http://192.168.245.129:9000 admin password
>
>Documentation: https://min.io/docs/minio/linux/index.html
>Warning: The standard parity is set to 0. This can lead to data loss.
>
>```
>
>快速启动
>
>`http://192.168.245.129:9000/docs/minio/linux/reference/minio-mc.html#quickstart`
>
>文档
>
>`https://192.168.245.129:9000/docs/minio/linux/index.html`
>
> 1. VM安装Docker，再安装MinIO
>
>- [ ] 跟黄永宣确认前端研发人力。



## 一个网络磁盘(网络共享文件夹)被挂载到多台服务器上,达到大家共享同一个文件夹的目标。

![](img/mount挂载文件夹.jpg)

# CentOS 7 安装Docker

<strong style="color:red">我的安装在702上</strong>

> 安装完CentOS7，启用网络连接
>
> https://blog.csdn.net/qq_45743985/article/details/121152504
>
> ```shell
> vi /etc/sysconfig/network-scripts/ifcfg-ens33
> 
> BOOTPROTO=dhcp
> ONBOOT=yes
> 
> # 重启网卡生效
> service network restart
> # 查看本机IP地址
> ip addr
> ```
>
> 

## 安装命令

```shell
# 安装Docker
yum -y install docker
# 启动Docker
systemctl start docker
# 查看Docker是否启动
systemctl status docker
# 设置Docker开机自启动
systemctl enable docker.service
```



# Docker安装MinIO

```shell
# 下载minio镜像
sudo docker pull minio/minio
# 查看已下载的镜像
sudo docker images
# 允许镜像
docker run -d -it \
   -p 9000:9000 \
   -p 9090:9090 \
   --name minio \
   --privileged=true \
   -v /mydata/minio/data:/data \
   -v /mydata/minio/config:/root/.minio \
   -e "MINIO_ROOT_USER=rootname" \
   -e "MINIO_ROOT_PASSWORD=changeme123" \
   quay.io/minio/minio server /data --console-address ":9090"

```

# 访问MinIO的管理页面

> http://192.168.245.129:9090/access-keys/new-account

## 创建access-key，并设置权限JSON

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "admin:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}
```

> 上面默认的是对所有桶可以进行所有操作，这个是有安全风险的。
>
> 每个桶单独设置一个access-key,对全局桶只读，对自己的桶可写
>
> 参考链接
>
> https://blog.csdn.net/qq_38425803/article/details/115125361

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::xux001/*"
            ]
        }
    ]
}
```

> `http://192.168.245.129:9090`
>
> bucket `xux001`
>
> 我配置的样例 Access Key `BpmF5kRkTmrfeRMTYQdm`   Secret Key `XadqT6GObC29I3t9JNuRdgvW7oDdPpjvp09MG5NW`
>
> 目标是对xux001桶做查询(下载),上传,删除
>
> ```json
> {
>     "Version": "2012-10-17",
>     "Statement": [
>         {
>             "Effect": "Allow",
>             "Action": [
>                 "s3:PutObject",
>                 "s3:GetBucketLocation",
>                 "s3:GetObject",
>                 "s3:DeleteObject"
>             ],
>             "Resource": [
>                 "arn:aws:s3:::xux001/*"
>             ]
>         }
>     ]
> }
> ```
>
> ![](img/Snipaste_2023-08-31_15-29-22.jpg)
>
> MinIO文件管理页面是B+树结构
>
> ![](img/Snipaste_2023-08-31_15-37-49.jpg)
>
> 
>
> ![](img/Snipaste_2023-08-31_15-38-02.jpg)

# Java实现对MinIO查询,上传,下载,删除的操作

> ![](img/Snipaste_2023-08-31_16-54-21.jpg)
>
> ![](img/Snipaste_2023-08-31_16-55-12.jpg)

# 使用MinIO部署独立存储服务

## 对外暴露的接口

> 1. 上传文件（Minio没有限制文件大小，但是网络传输，可能Nginx可能会限制；SpringBoot会限制）
>    - 上传文件大小限制
>    - 超大文件上传是否需要分片
> 2. 下载文件（Minio没有限制文件大小，但是网络传输，可能Nginx可能会限制；SpringBoot会限制）
>    - 超大文件下载是否需要分片
> 3. 删除文件
> 4. 获取文件URL
>    - http://192.168.245.129:9000/xux001/test.csv?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=BpmF5kRkTmrfeRMTYQdm%2F20230901%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20230901T030358Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f3a3b8b23cabfd4b18d96cca011577fa91392663545bf9198b0af9430d4bc483
> 5. 横向鉴权
>    - 不用业务mes，scada要存储在各自的bucket桶里面。
>    - 各个桶都有独立的access-key，该access-key对本桶有上传下载删除查询权限。
>    - 还有一个超级管理员，拥有全部权限，就是默认json配置
> 6. MinIO的管理不做新开发，复用自带UI-Web，管理access-key，bucket，文件管理
>
> 各个案例验证截图
>
> ![](img/Snipaste_2023-09-01_11-08-15.jpg)
>
> ![](img/Snipaste_2023-09-01_11-09-10.jpg)
>
> ![](img/Snipaste_2023-09-01_11-10-04.jpg)
>
> ![](img/Snipaste_2023-09-01_11-11-29.jpg)
>
> ![](img/Snipaste_2023-09-01_11-11-51.jpg)
>
> ![](img/Snipaste_2023-09-01_11-14-02.jpg)

> MinioClient API详解
>
> https://www.hxstrive.com/subject/minio.htm?id=683
>
> 
>
> 芋道源码里面这个案例，写了读取S3 OSS的文件为二进制流，并返回给前端。
>
> cn.iocoder.yudao.module.infra.controller.admin.file.FileController#getFileContent

> 修改文件存储主配置
>
> http://api-dashboard.yudao.iocoder.cn/admin-api/infra/file-config/update-master?id=17
>
> 
>
> OSS 独立微服务,操作MinIO需要一个`minioClient`，那么这个客户端我要能根据MinIO上面配置access-key自动生成对应的`minioClient`；业务服务调用时能自动找到对应的`minioClient`。
>
> - 这个要参考芋道源码的项目真实代码，有一些参考价值。设置主配置，作为MinIO Client的配置。

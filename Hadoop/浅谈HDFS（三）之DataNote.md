## DataNode工作机制

![](D:\MyWork\BigData\img\DataNode工作机制.png)

1. 一个数据块在DataNode上以文件形式存储在磁盘上，包括两个文件，一个是数据本身，一个是元数据包括数据块的长度，块数据的校验和，以及时间戳。
2. DataNode启动后向NameNode注册，通过后，周期性（1小时）的向NameNode上报所有的块信息。
3. DataNode与NameNode之间有一个**心跳事件**，心跳是每3秒一次，心跳返回结果带有NameNode给该DataNode的命令，如果超过10分钟没有收到某个DataNode的心跳，则认为该节点不可用。
4. 集群运行中可以安全加入和退出一些机器



## 数据完整性

> 思考：如果电脑磁盘里面存储的数据是控制高铁信号灯的红灯信号（1）和绿灯信号（0），但是存储该数据的磁盘坏了，一直显示是绿灯，是否很危险？
>
> 同理，DataNode节点上的数据损坏了，却没有发现，是否也很危险，那么如何解决呢？

* 保证数据完整性的方法

1. 当DataNode读取Block的时候，它会计算CheckSum（校验和）
2. 如果计算后的CheckSum，与Block创建时值不一样，说明Block已经损坏
3. Client读取其他DataNode上的Block
4. DataNode在其文件创建后周期验证CheckSum，如下图：

![](D:\MyWork\BigData\img\校验和.png)

## 掉线时参数设置

>  DataNode进程死亡或者网络故障造成DataNode无法与NameNode通信时的TimeOut参数设置

1. NameNode不会立即把该节点判断为死亡，要经过一段时间，这段时间称作**超时时长**
2. HDFS默认的超时时长为10分钟+30秒
3. 超时时长的计算公式为：

```shell
# dfs.namenode.heartbeat.recheck-interval默认为300000ms，dfs.heartbeat.interval默认为5s
TimeOut = 2 * dfs.namenode.heartbeat.recheck-interval + 10 * dfs.heartbeat.interval
```

* 实际开发的时候，可以根据自己服务器的情况进行调整，比如服务器性能比较低，那么可以适当的把时间调长；如果服务器性能很好，那么可以适当缩短。

## 服役新数据节点

> 需求：随着公司业务的增长或者重大活动（例如双11），数据量越来越大，原有的数据节点的容量已经不能满足存储数据的需求，需要在原有集群基础上动态添加新的数据节点。

* 步骤：

1. 克隆一台虚拟机
2. 修改IP地址和主机名称
3. **删除原来HDFS文件系统中留存的data和logs文件**
4. 直接单点启动节点即可

## 退役旧数据节点

> 退役旧数据节点有两种方式：添加白名单和黑名单退役

### 添加白名单

* 步骤：

1. 在NameNode的`hadoop安装目录/etc/hadoop`目录下创建dfs.hosts文件
2. 添加白名单主机名称
3. 在NameNode的hdfs-site.xml配置文件中增加dfs.hosts属性

```shell
<property>
	<name>dfs.hosts</name>
	# dfs.hosts文件所在路径
	<value>/opt/module/hadoop-2.7.2/etc/hadoop/dfs.hosts</value>
</property>
```

4. 配置文件同步到集群其它节点
5. 刷新NameNode

```shell
[kocdaniel@hadoop102 hadoop-2.7.2]$ hdfs dfsadmin -refreshNodes
Refresh nodes successful
```

6. 更新ResourceManager节点

```shell
[kocdaniel@hadoop102 hadoop-2.7.2]$ yarn rmadmin -refreshNodes
```

7. 如果数据不均衡，可以用命令实现集群的再平衡

```shell
[kocdaniel@hadoop102 sbin]$ ./start-balancer.sh
```



### 黑名单退役

* 步骤：

1. 在NameNode的`hadoop安装目录/etc/hadoop`目录下创建dfs.hosts.exclude文件
2. 添加要退役的主机名称
3. 在NameNode的hdfs-site.xml配置文件中增加dfs.hosts.exclude属性

```shell
<property>
	<name>dfs.hosts.exclude</name>
     <value>/opt/module/hadoop-2.7.2/etc/hadoop/dfs.hosts.exclude</value>
</property>

```

4. 配置文件同步到集群其它节点

5. 刷新NameNode、刷新ResourceManager

```shell
[kocdaniel@hadoop102 hadoop-2.7.2]$ hdfs dfsadmin -refreshNodes
Refresh nodes successful
[kocdaniel@hadoop102 hadoop-2.7.2]$ yarn rmadmin -refreshNodes
```

6. 检查Web浏览器，退役节点的状态为decommission in progress（退役中），说明数据节点正在复制块到其他节点
7. 等待退役节点状态为decommissioned（所有块已经复制完成），停止该节点及节点资源管理器。

* **注意：如果副本数是3，服役的节点小于等于3，是不能退役成功的，需要修改副本数后才能退役**
* **注意：不允许白名单和黑名单中同时出现同一个主机名称。**

### 两者的不同

* 添加白名单比较暴躁，会直接把要退役的节点服务关掉，不复制数据
* 黑名单退役，会将要退役的节点服务器的数据复制到其它节点上，不会直接关闭节点服务，比较慢

## DataNode多目录配置

* DataNode也可以配置成多个目录，每个目录存储的**数据不一样**。即：数据不是副本，与NameNode多目录不同
* 作用：**保证所有磁盘都被利用均衡，类似于windows中的磁盘分区**
# 主从复制
## 定义
* 主从复制，就是主机数据更新后根据配置和策略，**自动同步到备机的master/slaver机制，Master以写为主，Slave以读为主**
* ![b839637a8cf89095f353bd225255f5a7.png](en-resource://database/2365:1)

## 用处
* 读写分离，性能扩展
* 容灾快速恢复

## 一主二仆模式演示
### 几个问题
1. 切入点问题：slave1和slave2从头开始复制还是从切入点开始？**从头开始**
2. 从机是否可写？**不可**
3. 主机shutdown后，从机上位还是原地待命？**原地待命**
4. 主机回来之后，主机新增记录，从机能否顺利复制？**能，因为从头开始复制**
5. 其中一台从机down掉后，依照原有可以跟上大部队吗？**不能，需要重新认主**

### 复制原理
* 每次从机联通后，都会给主机发送sync指令
* 主机立刻进行存盘操作，发送RDB文件，给从机
* 从机收到RDB文件后，进行全盘加载
* 之后每次主机的写操作，都会立刻发送给从机，从机执行相同的命令
* ![ffbe243fad15b1d5b47e0fa6b3e69458.png](en-resource://database/2367:1)

### 薪火相传
* 上一个slave可以是下一个slave的Master，slave同样可以接收其他slaves的连接和同步请求，那么该slave作为了链条中下一个的master, **可以有效减轻master的写压力,去中心化降低风险**。
* **风险**：一旦某个slave宕机，后面的slave都没法备份

### 反客为主
* 当一个master宕机后，后面的slave可以立刻升为master，其后面的slave不用做任何修改
* 用 `slaveof  no one ` 将从机变为主机
* 但是每次都需要手动指定主机，比较繁琐

### 哨兵模式(sentinel)
* 反客为主的自动版，能够后台监控主机是否故障，如果故障了根据投票数自动将从库转换为主库
* 当主机重新上线时，sentinel会向其发送slaveof命令，让其成为新主的从
* ![3221b9a12882f49b0d840923b0e17812.png](en-resource://database/2373:1)

* 选择条件依次为
1. 选择优先级靠前的：优先级在redis.conf中的slave-priority 100设置
2. 选择偏移量最大的：偏移量是指获得原主数据最多的
3. 选择runid最小的从服务：每个redis实例启动后都会随机生成一个40位的runid

#### 配置哨兵
1. 调整为一主二仆模式
2. 自定义的/myredis目录下新建sentinel.conf文件
3. 在配置文件中填写内容：`sentinel  monitor  mymaster  127.0.0.1  6379  1`
*    其中mymaster为监控对象起的服务器名称， 1 为 至少有多少个哨兵同意迁移的数量。 
*    127.0.0.1  6379：为主机ip与port

#### 启动哨兵
* 执行： `redis-sentinel  /myredis/sentinel.conf `

## 几个命令
1. ` info replication`：打印主从复制的相关信息
2. `slaveof <ip> <port>`：成为某个实例的从服务器

## 如何搭建一主二仆模式
* 配从不配主
* 新建redis6379.conf配置文件（文件名自定义），使用include包含原redis.conf
* 并配置如下信息：
* ![5a0081acdf5b1fc4df69d4b08a21d39d.png](en-resource://database/2375:1)
```
include /root/myredis/redis.conf    // include
pidfile "/var/run/redis_6379.pid"   // pidfile
port 6379   // 端口号
dbfilename "dump6379.rdb"  // rdb名称
```
* Appendonly：关掉或换名字
* 按照以上步骤配置三个redis.conf文件，然后通过`slaveof <ip> <port>`认主

# 集群

## 问题
1. 容量不够，redis如何进行扩容？
2. 并发写操作，redis如何分摊？

## 什么是集群？
* Redis 集群实现了对Redis的水平扩容，即启动N个redis节点，将整个数据库分布存储在这N个节点中，每个节点存储总数据的1/N；
* Redis 集群通过分区（partition）来提供一定程度的可用性（availability）： 即使集群中有一部分节点失效或者无法进行通讯， 集群也可以继续处理命令请求。
* 集群就相当于多个主从复制的合体

## 配置集群
1. 执行： ` yum install ruby`
   执行： `yum install rubygems`
2. 拷贝`redis-3.2.0.gem`（本地文件）到/opt目录下
3. 在opt目录下执行：  `gem install --local redis-3.2.0.gem`
4. 制作6个实例，6379,6380,6381,6389,6390,6391（6389为6379的从，6390为6380的从，6391为6381的从）
5. 拷贝多个redis.conf文件，在里面配置信息，加入集群
![9a4f8db5a3dbfa63466200e0e1365779.png](en-resource://database/2379:1)
```
cluster-enabled yes    打开集群模式
cluster-config-file  nodes-6379.conf  设定节点配置文件名
cluster-node-timeout 15000   设定节点失联时间，超过该时间（毫秒），集群自动进行主从切换。
```
6. 将六个节点合成一个集群
* 组合之前，确保所有redis实例启动后，node-xxxx.conf文件都生成正常
![59543086b95c05e3427c029df056f1eb.png](en-resource://database/2385:1)
* 合体
```
cd  /opt/redis-3.2.5/src  // 切换到src目录下，因为要执行src下的redis-trib.rb命令

// 此处不要用127.0.0.1， 请用真实IP地址
// 此命令会自动分配主从关系，前三个为主，后三个依次为前三个的从
./redis-trib.rb create --replicas 1 192.168.1.100:6379 192.168.1.100:6380 192.168.1.100:6381 192.168.1.100:6389 192.168.1.100:6390 192.168.1.100:6391
```
7. 通过 `cluster nodes` 命令查看集群信息，可通过红框框住的序列号找到主从关系
![13b8f3cace143297f45abec4ae380ace.png](en-resource://database/2389:1)

## 什么是slots
![76f358683c03ac609a9ed5a8af5f88f3.png](en-resource://database/2393:1)
* 一个 Redis 集群包含 16384 个插槽（hash slot），数据库中的每个键都属于这 16384 个插槽的其中一个
* 集群使用公式 `CRC16(key) % 16384` 来计算键 key 属于哪个槽， 其中 CRC16(key) 语句用于计算键 key 的 CRC16 校验和 。
* 集群中的每个节点负责处理一部分插槽
![5e151fde563ad3fe33f27f5f7993a39b.png](en-resource://database/2397:1)
* 如图所示，
* 节点 6379 负责处理 0 号至 5460 号插槽。
* 节点 6380 负责处理 5461 号至 10922 号插槽。
* 节点 C 负责处理 10923 号至 16383 号插槽。

## 在集群中录入值
* **自动重定向**：redis-cli客户端提供了 –c 参数实现自动重定向，即使用 `redis-cli  -c –p 6379` 登录
* 在redis-cli每次录入、查询键值，redis都会计算出该key应该送往的插槽，如果是以自动重定向登录，会自动切换到对应插槽所属节点，否则会报错
* 不在一个slot下的键值，是不能使用mget,mset等多键操作
* 可以通过{}来定义组的概念，从而使key中{}内相同内容的键值对放到一个slot中去，但是不建议使用

## 查询集群中的值
* `CLUSTER KEYSLOT <key>` ：计算键 key 应该被放置在哪个槽上。

* `CLUSTER COUNTKEYSINSLOT <slot>` ： 返回槽 slot 目前包含的键值对数量。  

* `CLUSTER GETKEYSINSLOT <slot> <count>` ： 返回 count 个 slot 槽中的键。
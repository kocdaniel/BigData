* Redis提供了两个不同形式的持久化方式：RDB（Redis Database）和 AOF（Append Of File）

# RDB（Redis Database）
## 原理
* 在指定的时间间隔内将内存中的数据集快照写入磁盘，恢复时是将快照文件直接读到内存里（可以通过配置文件redis.conf修改和查看他的持久化机制）

## 执行过程
* Redis会单独创建（fork）一个子进程来进行持久化，会先将数据写入到一个临时文件中，待持久化过程结束之后，再用这个临时文件替换上次持久化好的文件
* fork()会产生一个和父进程完全相同的子进程，且出于效率考虑，一般情况下父进程与子进程共用一段物理内存（linux引入的写时复制技术），只有在进程空间的各段的内容要发生变化时，才会将父进程的内容复制一份给子进程

## redis.conf配置文件中的信息
### rdb保存的文件
* 在redis.conf中，默认为dump.rdb
* ![1568864387751](https://github.com/kocdaniel/BigData/blob/master/img/rdb.png)

## rdb文件的保存路径
* 默认为 ./，即redis服务启动时所在的当前目录下，可以修改
* ![1568864432733](https://github.com/kocdaniel/BigData/blob/master/img/redis%E6%96%87%E4%BB%B6%E7%9A%84%E4%BF%9D%E5%AD%98%E8%B7%AF%E5%BE%84.png)

## rdb保存策略（自动保存快照策略）
![1568864454094](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1568864454094.png)
![1568864472685](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1568864472685.png)

## 手动保存快照
* 命令：
1. save：只管保存，其它不管，保存时其它进程阻塞
2. bgsave：后台保存，不会阻塞其它进程

## stop-writes-on-bgsave-error yes
* 当Redis无法写入磁盘的话，直接关掉Redis的写操作

## rdbcompression yes
* 进行rdb保存时，将文件压缩

## rdbchecksum yes
* 在存储快照后，还可以让Redis使用CRC64算法来进行数据校验，但是这样做会增加大约10%的性能消耗，如果希望获取到最大的性能提升，可以关闭此功能

## rdb的备份
* 先通过config get dir  查询rdb文件的目录 
* 将*.rdb的文件拷贝到别的地方

## rdb的恢复
* 关闭Redis
* 先把备份的文件拷贝到工作目录下
* 启动Redis, 备份数据会直接加载

## 优缺点
* **优点**：

1. 整个过程中，主进程不进行任何IO操作，确保了在恢复大规模数据时的极高的性能
2. 对于数据恢复的完整性不是非常敏感，比AOF方式更加高效
3. 节省磁盘空间
4. 恢复速度快

* **缺点**：
1. 在备份周期在一定时间间隔做一次备份，所以如果redis意外down掉的话，就会丢失最后一次快照后的所有修改
2. 虽然redis在fork时使用了写时拷贝技术，但是如果数据庞大还是比较耗费性能

# AOF（Append Of File）

## 原理

* **以日志的形式来记录每个写操作**，
* 将Redis执行过的所有写指令记录下来(读操作不记录)，
* 只许追加文件但不可以改写文件，Redis启动之初会读取该文件重新构建数据，
* 换言之，Redis重启的话就根据日志文件的内容将写指令从前到后执行一次以完成数据的恢复工作。

## redis.conf配置文件信息
### AOF默认不开启，需要手动在配置文件中配置
![1568864518687](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1568864518687.png)
* 改为yes即可开启

### 设置配置文件名称，默认为appendonly.aof

![1568864542761](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1568864542761.png)

### AOF文件的保存路径与RDB一致
### AOF与RDB同时开启，系统默认读取AOF的数据

### AOF文件故障恢复
* `redis-check-aof  --fix  appendonly.aof `  进行恢复

### AOF同步频率设置
![1568864567772](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1568864567772.png)

* 始终同步，每次redis的写入都会立刻记入日志
* 每秒同步，每秒记录一次，如果宕机，本秒的数据可能丢失
* 不主动进行同步，把同步时机交给操作系统

### Rewrite重写机制
* AOF采用文件追加方式，文件会越来越大为避免出现此种情况，新增了重写机制,当AOF文件的大小超过所设定的阈值时，Redis就会启动AOF文件的内容压缩，只保留可以恢复数据的最小指令集.可以使用命令`bgrewriteaof`。
#### 如何实现重写

* AOF文件持续增长而过大时，会fork出一条新进程来将文件重写(也是先写临时文件最后再rename)，遍历新进程的内存中数据，每条记录有一条的Set语句。
* 重写aof文件的操作，并没有读取旧的aof文件，而是将整个内存中的数据库内容用命令的方式重写了一个新的aof文件，这点和快照有点类似。

#### 何时重写
* 重写虽然可以节约大量磁盘空间，减少恢复时间。但是每次重写还是有一定的负担的，因此设定Redis要满足一定条件才会进行重写。
* ![1568864590883](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1568864590883.png)
* 系统载入时或者上次重写完毕时，Redis会记录此时AOF大小，设为base_size,如果`Redis的AOF当前大小>= base_size +base_size*100% (默认)且当前大小>=64mb(默认)`的情况下，Redis会对AOF进行重写。

## 优缺点

### 优点
1. 备份机制更稳健，丢失数据概率更低
2. 可读的日志文件，通过操作AOF文件，可以处理误操作

### 缺点
1. 比起RDB占用更多的磁盘空间
2. 恢复备份速度更慢
3. 每次读写都同步的话，有一定的性能压力
4. 存在个别bug，造成恢复不能

# 用哪个好？

* 官方推荐两个都使用
* 如果对数据完整性不敏感，可以单独用RDB
* 不建议单独用AOF，因为可能会出bug
* 如果只是做纯内存缓存，可以都不用

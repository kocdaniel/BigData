## 产生背景及定义

>  HDFS：分布式文件系统，用于存储文件，主要特点在于其分布式，即有很多服务器联合起来实现其功能，集群中的服务器各有各的角色

* 随着数据量越来越大，一个操作系统存不下所有的数据，那么就分配到更多的操作系统管理的磁盘中，但是管理和维护极不方便，于是迫切**需要一种系统来管理多台机器上的文件**，这就是分布式管理系统，**HDFS是其中一种**。
* HDFS的使用适合**一次写入，多次读出**的场景，且不支持对文件的直接修改，**仅支持在文件末尾追加**
* HDFS采用**流式的数据访问方式**：特点就是像流水一样，数据不是一次过来，而是一点一点“流”过来，处理数据也是一点一点处理。如果是数据全部过来之后才处理，那么延迟就会很大，而且会消耗很大的内存。

## 优缺点

1. 高容错性
   * 数据自动保存多个副本，通过增加副本的方式，提高容错性
   * 若某一个副本丢失后，它可以自动分配到其它节点作为新的副本
2. 处理大数据
   * 数据规模：能够处理的数据规模可以达到GB，TB，甚至PB级别的数据
   * 文件规模：能够处理百万规模以上的文件数量，数量相当之大
3. 可构建在廉价的机器上，通过多副本机制，提高可靠性

## 组成架构

![](https://mmbiz.qpic.cn/mmbiz_png/hlLEC0QP5QWvnziakXl5NQjOE6B7RMerzSPrm88JIWjmv2yicoaPuz9ypRknWCaEeOU85D3fKSy1gx1oDUcv7Fsg/0?wx_fmt=png)

1. `namenode（nn）`：就是Master，是一个管理者，存放元数据
   * 管理HDFS的名称空间
   * 配置副本策略
   * 管理数据块的映射信息
   * 处理客户端的读写请求
2. `datanode（dn）`：就是slave，真正存储文件的地方
   * 存储实际的数据块
   * 执行数据块的读写操作
3. `secondarynamenode（2nn）`：并非namenode的热备，当namenode挂掉的时候，并不能马上替换namenode并提供服务
   * 作为namenode的辅助，分担其工作量，比如定期合并Fsimage和Edits（文章后边会讲到这两个东西），并推送给namenode
   * 在紧急情况下，可辅助恢复namenode，但是只能恢复部分，而不能全部恢复
4. `client`：客户端
   * 文件的切分，在上传HDFS之前，client将文件切分为一个一个的Block，然后一个一个进行上传
   * 与namenode交互，获取文件的datanode信息
   * 与datanode交互，读取或写入数据
   * client提供一些命令来管理HDFS，比如namenode的格式化
   * client通过一些命令来访问HDFS，比如对HDFS的增删查改等

## 文件块大小

> 为什么要把文件抽象为Block块存储？
>
> 1. block的拆分使得单个文件大小可以大于整个磁盘的容量，构成文件的Block可以分布在整个集群， 理论上，单个文件可以占据集群中所有机器的磁盘。 
> 2. Block的抽象也简化了存储系统，对于Block，无需关注其权限，所有者等内容（这些内容都在文件级别上进行控制）。 
> 3. Block作为容错和高可用机制中的副本单元，即以Block为单位进行复制。

> HDFS中的文件在物理内存中分块存储（Block），块的大小在Hadoop2.x版本中默认为128M，在老版本中为64M，那么为什么为128M呢？
>
> 其实，**HDFS的块的大小的设置主要取决于磁盘传输速率**，如下：

1. 如果在HDFS中，寻址时间为10ms，即查找到目标Block的时间为10ms
2. **专家说**操作的最佳状态为：**寻址时间为传输时间的1%**，因此传输时间为1s
3. 而目前磁盘的传输速率普遍为100M/s

> 为什么块大小不能设置太小，也不能设置太大？
>
> 1. HDFS的块设置太小，会增加寻址时间，使得程序可能一直在寻找块的开始位置
> 2. 如果设置的太大，从磁盘传输数据的时间会明显大于定位这个块所需的寻址时间，导致程序处理这块数据时会非常慢

## HDFS的数据流

### HDFS写数据流程

![HDFS写数据流程](https://mmbiz.qpic.cn/mmbiz_png/hlLEC0QP5QWvnziakXl5NQjOE6B7RMerzfvX3TO7c3m3RcK9AXxVze0wGmExdL87MFltMlg78H7534ibMF3iaBp8w/0?wx_fmt=png)

1. 客户端通过Distributed FileSystem模块向NameNode请求上传文件，NameNode检查目标文件是否已存在，父目录是否存在。
2. NameNode返回是否可以上传。
3. 客户端请求第一个 Block上传到哪几个DataNode服务器上。
4. NameNode返回3个DataNode节点，分别为dn1、dn2、dn3， **如果有多个节点，返回实际的副本数量，并根据距离及负载情况计算**
5. 客户端通过FSDataOutputStream模块请求dn1上传数据，dn1收到请求会继续调用dn2，然后dn2调用dn3，将这个通信管道建立完成。
6. dn1、dn2、dn3逐级应答客户端。
7. 客户端开始往dn1上传第一个Block（先从磁盘读取数据放到一个本地内存缓存），以Packet为单位，dn1收到一个Packet就会传给dn2，dn2传给dn3；dn1每传一个packet会放入一个应答队列等待应答。
8. 当一个Block传输完成之后，客户端再次请求NameNode上传第二个Block的服务器。（重复执行3-7步）。

### 网络拓扑---节点距离计算

> 在HDFS写数据的过程中，NameNode会选择距离待上传数据最近距离的DataNode接收数据，那么这个最近距离是怎么计算的呢？
>
> 结论：两个节点到达最近的**共同祖先**的距离总和，即为节点距离。

![](https://mmbiz.qpic.cn/mmbiz_png/hlLEC0QP5QWvnziakXl5NQjOE6B7RMerziaRojaxTZmQ4URmxTY3K0e9uLZ9CVJoc6wYrsJcBTGf1yKWTC6ibibvQA/0?wx_fmt=png)

如上图所示：

* 同一节点上的进程节点距离为0
* 同一机架上不同节点的距离为两个节点到共同机架r1的距离总和，为2
* 同一数据中心不同机架的节点距离为两个节点到共同祖先集群d1的距离之和，为4
* 不同数据中心的节点距离为两个节点到达共同祖先数据中心的距离之和，为6

### 机架感知（副本存储的节点选择）

> 副本的数量我们可以从配置文件中设置，那么HDFS是怎么选择副本存储的节点的呢？

![1](https://mmbiz.qpic.cn/mmbiz_png/hlLEC0QP5QWvnziakXl5NQjOE6B7RMerzqDQt2u9XXDATjfd1xdkr9yNiaBDxvtvjvkLNicl8hFRhM2nV2CKjuLsw/0?wx_fmt=png)

如上图所示，为了提高容错性，有如下设置，加入现在有3个副本：

* 第一个副本在Client所在的节点上，如果客户端在集群外，则随机选一个
* 第二个副本和第一个副本位于相同机架，随机节点
* 第三个副本位于不同机架，随机节点

这样做的目的就是为了提高容错性。

### HDFS读数据流程

![HDFS读数据流程](https://mmbiz.qpic.cn/mmbiz_png/hlLEC0QP5QWvnziakXl5NQjOE6B7RMerzl3t3g1LJ3ZeuQBObmG7CItVwfnE73jEjicXdv36XS7OknjHX99hULZQ/0?wx_fmt=png)

1. 客户端通过Distributed FileSystem向NameNode请求下载文件，NameNode通过查询元数据，找到文件块所在的DataNode地址。

2. 挑选一台DataNode（就近原则，然后随机）服务器，请求读取数据。

3. DataNode开始传输数据给客户端（从磁盘里面读取数据输入流，以Packet为单位来做校验）。

4. 客户端以Packet为单位接收，先在本地缓存，然后写入目标文件。
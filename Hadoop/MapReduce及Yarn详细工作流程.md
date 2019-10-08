## MapReduce详细工作流程之Map阶段

![MR一](https://mmbiz.qpic.cn/mmbiz_png/hlLEC0QP5QUCtQDYX29t2JotdFQTVPluHxZp9tIlHAia6D5tQZhxvNVcfibuibvrk8zCKtaWG12ROD8WWNW2n1YicQ/0?wx_fmt=png)

> 如上图所示

1. 首先有一个200M的待处理文件
2. 切片：在客户端提交之前，根据参数配置，进行任务规划，将文件按128M每块进行切片
3. 提交：提交可以提交到本地工作环境或者Yarn工作环境，本地只需要提交切片信息和xml配置文件，Yarn环境还需要提交jar包；本地环境一般只作为测试用
4. 提交时会将每个任务封装为一个job交给Yarn来处理（详细见后边的Yarn工作流程介绍），计算出MapTask数量（等于切片数量），每个MapTask并行执行
5. MapTask中执行Mapper的map方法，此方法需要k和v作为输入参数，所以会首先获取kv值；
   * 首先调用InputFormat方法，默认为TextInputFormat方法，在此方法调用createRecoderReader方法，将每个块文件封装为k，v键值对，传递给map方法
6. map方法首先进行一系列的逻辑操作，执行完成后最后进行写操作
7. map方法如果直接写给reduce的话，相当于直接操作磁盘，太多的IO操作，使得效率太低，所以在map和reduce中间还有一个shuffle操作
   * map处理完成相关的逻辑操作之后，首先通过outputCollector向环形缓冲区写入数据，环形缓冲区主要两部分，一部分写入文件的元数据信息，另一部分写入文件的真实内容
   * 环形缓冲区的默认大小是100M，当缓冲的容量达到默认大小的80%时，进行**反向**溢写
8. 在溢写之前会将缓冲区的数据按照指定的分区规则进行分区和排序，之所以反向溢写是因为这样就可以边接收数据边往磁盘溢写数据
9. 在分区和排序之后，溢写到磁盘，可能发生多次溢写，溢写到多个文件
10. 对所有溢写到磁盘的文件进行归并排序
11. 在9到10步之间还可以有一个Combine合并操作，意义是对每个MapTask的输出进行局部汇总，以减少网络传输量
    * Map阶段的进程数比Reduce阶段要多，所以放在Map阶段处理效率更高
    * Map阶段合并之后，传递给Reduce的数据就会少很多
    * 但是Combiner能够应用的前提是不能影响最终的业务逻辑，而且Combiner的输出kv要和Reduce的输入kv类型对应起来

> 整个MapTask分为Read阶段，Map阶段，Collect阶段，溢写（spill）阶段和combine阶段
>
> * Read阶段：MapTask通过用户编写的RecordReader，从输入InputSplit中解析出一个个key/value
> * Map阶段：该节点主要是将解析出的key/value交给用户编写map()函数处理，并产生一系列新的key/value
> * Collect收集阶段：在用户编写map()函数中，当数据处理完成后，一般会调用OutputCollector.collect()输出结果。在该函数内部，它会将生成的key/value分区（调用Partitioner），并写入一个环形内存缓冲区中
> * Spill阶段：即“溢写”，当环形缓冲区满后，MapReduce会将数据写到本地磁盘上，生成一个**临时文件**。需要**注意**的是，将数据写入本地磁盘之前，先要对数据进行一次本地排序，并在必要时对数据进行合并、压缩等操作

## MapReduce详细工作流程之Reduce阶段

![MR二](https://mmbiz.qpic.cn/mmbiz_png/hlLEC0QP5QUCtQDYX29t2JotdFQTVPlug1PVsOu03HZicVDBkSqBwliaEicsN93Rr9gHcictB2ZvKsnicwo8mMcETgA/0?wx_fmt=png)

> 如上图所示

12. 所有的MapTask任务完成后，启动相应数量的ReduceTask（和分区数量相同），并告知ReduceTask处理数据的范围
13. ReduceTask会将MapTask处理完的数据拷贝一份到磁盘中，并合并文件和归并排序
14. 最后将数据传给reduce进行处理，一次读取一组数据
15. 最后通过OutputFormat输出

> 整个ReduceTask分为Copy阶段，Merge阶段，Sort阶段（Merge和Sort可以合并为一个），Reduce阶段。
>
> * Copy阶段：ReduceTask从各个MapTask上远程拷贝一片数据，并针对某一片数据，如果其大小超过一定阈值，则写到磁盘上，否则直接放到内存中
> * Merge阶段：在远程拷贝数据的同时，ReduceTask启动了两个后台线程对内存和磁盘上的文件进行合并，以防止内存使用过多或磁盘上文件过多
> * Sort阶段：按照MapReduce语义，用户编写reduce()函数输入数据是按key进行聚集的一组数据。为了将key相同的数据聚在一起，Hadoop采用了基于排序的策略。由于各个MapTask已经实现对自己的处理结果进行了局部排序，因此，ReduceTask只需对所有数据进行一次归并排序即可
> * Reduce阶段：reduce()函数将计算结果写到HDFS上

## Shuffle机制

![](https://mmbiz.qpic.cn/mmbiz_png/hlLEC0QP5QUCtQDYX29t2JotdFQTVPluG21x84beRCgibgApd3OTpJk3ibsttsPo2iaGS689vfbjZ8XSby8AuWCLg/0?wx_fmt=png)

> Map方法之后，Reduce方法之前的数据处理过程称之为Shuffle。shuffle流程详解如下：

1. MapTask收集map()方法输出的kv对，放到环形缓冲区中
2. 从环形缓冲区不断溢出到本地磁盘文件，可能会溢出多个文件
3. 多个溢出文件会被合并成大的溢出文件
4. 在溢出过程及合并的过程中，都要调用Partitioner进行分区和针对key进行排序
5. ReduceTask根据自己的分区号，去各个MapTask机器上取相应的结果分区数据
6. ReduceTask将取到的来自同一个分区不同MapTask的结果文件进行归并排序
7. 合并成大文件后，shuffle过程也就结束了，进入reduce方法

## Yarn工作机制

![Yarn工作机制](https://mmbiz.qpic.cn/mmbiz_png/hlLEC0QP5QUCtQDYX29t2JotdFQTVPlu1yDopKJMbQJZDmicJSBRmwufkBKgDHg9Hv6dgG0p4dqJ3PkSFMOHI4Q/0?wx_fmt=png)

> job提交全过程

1. MR程序提交到客户端所在的节点，YarnRunner向ResourceManager申请一个Application
2. RM将该Application的资源路径和作业id返回给YarnRunner
3. YarnRunner将运行job所需资源提交到HDFS上
4. 程序资源提交完毕后，申请运行mrAppMaster
5. RM将用户的请求初始化成一个Task
6. 其中一个NodeManager领取到Task任务
7. 该NodeManager创建容器Container，并产生MRAppmaster
8. Container从HDFS上拷贝资源到本地
9. MRAppmaster向RM 申请运行MapTask资源
10. RM将运行MapTask任务分配给另外两个NodeManager，另两个NodeManager分别领取任务并创建容器
11. MR向两个接收到任务的NodeManager发送程序启动脚本，这两个NodeManager分别启动MapTask，MapTask对数据分区排序
12. MrAppMaster等待所有MapTask运行完毕后，向RM申请容器，运行ReduceTask
13. ReduceTask向MapTask获取相应分区的数据
14. 程序运行完毕后，MR会向RM申请注销自己

> 进度和状态更新：
>
> YARN中的任务将其进度和状态(包括counter)返回给应用管理器, 客户端每秒(通过mapreduce.client.progressmonitor.pollinterval设置)向应用管理器请求进度更新, 展示给用户

> 作业完成：
>
> 除了向应用管理器请求作业进度外, 客户端每5秒都会通过调用waitForCompletion()来检查作业是否完成。时间间隔可以通过mapreduce.client.completion.pollinterval来设置。作业完成之后, 应用管理器和Container会清理工作状态。作业的信息会被作业历史服务器存储以备之后用户核查
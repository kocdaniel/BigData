# YARN Cluster模式

​	![](D:\MyWork\BigData\img\YARN_Cluster模式.png)

```
0. 准备操作：执行提交程序的shell指令，首先在本地环境下创建一个SparkSubmit进程，进入当前进程的main方法，在main方法中，在集群环境下获取"org.apache.spark.deploy.yarn.Client"的main方法并执行
 
1. 进入"org.apache.spark.deploy.yarn.Client"的main方法，new一个Client对象，并获取到yarn中的rmClient和rmAddress，用于连接yarn的RM；client创建好之后向RM进行应用程序的提交
 
2. RM收到客户端提交的应用程序后，通知一个NodeManager，在Container中启动ApplicationMaster进程
 
3. 启动一个driver线程
 
4. driver线程启动之后向RM申请运行task所需的资源（Executor内存）
 
5. RM向Driver返回可用资源列表（分配container）
 
6. 然后在合适的NodeManager上启动Container
 
7. 在Container中启动ExecutorBackend进程
 
8. ExecutorBackend向driver反向注册Executor，通知driver需要的Executor已经准备好了
 
9. driver收到注册信息后，创建计算对象Executor
 
最后：Executor全部注册完成后Driver开始执行main函数，之后执行到Action算子时，触发一个job，并根据宽依赖开始划分stage，每个stage生成对应的taskSet，之后将task分发到各个Executor上执行。
```




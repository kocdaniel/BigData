> 集群环境：
>
> 1. centOs6.8：hadoop102，hadoop103，hadoop104
> 2. jdk版本：jdk1.8.0_144
> 3. hadoop版本：Hadoop 2.7.2

首先准备三台客户机（hadoop102，hadoop103，hadoop104），关闭防火墙，修改为静态ip和ip地址映射

## 配置集群

> 编写集群分发脚本

1. 创建一个远程同步的脚本xsync，并放到当前用户下新建的bin目录下，配置到PATH中，使得此脚本在任何目录下都可以执行

2. 脚本实现

```shell
[kocdaniel@hadoop102 ~]$ mkdir bin
[kocdaniel@hadoop102 ~]$ cd bin/
[kocdaniel@hadoop102 bin]$ vim xsync
```

在文件中编写如下脚本代码

```shell
#!/bin/bash
#1 获取输入参数个数，如果没有参数，直接退出
pcount=$#
if((pcount==0)); then
echo no args;
exit;
fi

#2 获取文件名称
p1=$1
fname=`basename $p1`
echo fname=$fname

#3 获取上级目录到绝对路径 –P指向实际物理地址，防止软连接
pdir=`cd -P $(dirname $p1); pwd`
echo pdir=$pdir

#4 获取当前用户名称
user=`whoami`

#5 循环
for((host=103; host<105; host++)); do
        echo ------------------- hadoop$host --------------
        rsync -rvl $pdir/$fname $user@hadoop$host:$pdir
done
```

3. 修改脚本xsync具有执行权限，并调用脚本，将脚本复制到103和104节点

```shell
[kocdaniel@hadoop102 bin]$ chmod 777 xsync
[kocdaniel@hadoop102 bin]$ xsync /home/atguigu/bin
```

> 集群配置

1. 集群部署规划

|      | hadoop102           | hadoop103                     | hadoop104                    |
| ---- | ------------------- | ----------------------------- | ---------------------------- |
| HDFS | NameNode   DataNode | DataNode                      | SecondaryNameNode   DataNode |
| YARN | NodeManager         | ResourceManager   NodeManager | NodeManager                  |

**由于计算机配置有限，只能使用三台虚拟机，工作环境中根据需要规划集群**

2. 配置集群

切换到`hadoop安装目录/etc/hadoop/`

* 配置core-site.xml

```shell
[kocdaniel@hadoop102 hadoop]$ vim core-site.xml
# 在文件中写入如下内容
<!-- 指定HDFS中NameNode的地址 -->
<property>
	<name>fs.defaultFS</name>
      <value>hdfs://hadoop102:9000</value>
</property>

<!-- 指定Hadoop运行时产生文件的存储目录 -->
<property>
		<name>hadoop.tmp.dir</name>
		<value>/opt/module/hadoop-2.7.2/data/tmp</value>
</property>
```

* HDFS配置文件

  * 配置`hadoop-env.sh`

  ```shell
  [kocdaniel@hadoop102 hadoop]$ vim hadoop-env.sh
  export JAVA_HOME=/opt/module/jdk1.8.0_144
  ```

  **注意：**我们已经在/etc/profile文件中配置了JAVA_HOME，这里为什么还需要配置JAVA_HOME?

  答：因为Hadoop运行是守护进程（[守护进程是一个在后台运行并且不受任何终端控制的进程。--摘自百度百科]([https://baike.baidu.com/item/%E5%AE%88%E6%8A%A4%E8%BF%9B%E7%A8%8B/966835?fr=aladdin](https://baike.baidu.com/item/守护进程/966835?fr=aladdin))），正是因为它后台运行，不接受任何终端控制，所以它读取不到我们配置好的环境变量，所以这里需要单独配置一下。

  * 配置`hdfs-site.xml`

  ```shell
  [kocdaniel@hadoop102 hadoop]$ vim hdfs-site.xml
  # 写入如下配置
  <!-- 配置副本数量为3，默认也为3，所以这个也可以删掉 -->
  <property>
  		<name>dfs.replication</name>
  		<value>3</value>
  </property>
  
  <!-- 指定Hadoop辅助名称节点主机配置 -->
  <property>
        <name>dfs.namenode.secondary.http-address</name>
        <value>hadoop104:50090</value>
  </property>
  ```

* YARN配置文件

  * 配置`yarn-env.sh`

  ```shell
  [kocdaniel@hadoop102 hadoop]$ vim yarn-env.sh
  export JAVA_HOME=/opt/module/jdk1.8.0_144
  ```

  * 配置`yarn-site.xml`

  ```shell
  [kocdaniel@hadoop102 hadoop]$ vi yarn-site.xml
  # 增加如下配置
  <!-- Reducer获取数据的方式 -->
  <property>
  		<name>yarn.nodemanager.aux-services</name>
  		<value>mapreduce_shuffle</value>
  </property>
  
  <!-- 指定YARN的ResourceManager的地址 -->
  <property>
  		<name>yarn.resourcemanager.hostname</name>
  		<value>hadoop103</value>
  </property>
  ```

* MapReduce配置文件

  * 配置`mapred-env.sh`

  ```shell
  [kocdaniel@hadoop102 hadoop]$ vim mapred-env.sh
  export JAVA_HOME=/opt/module/jdk1.8.0_144
  ```

  * 配置`mapred-site.xml`

  ```shell
  # 如果是第一次配置的话，需要先将mapred-site.xml.template重命名为mapred-site.xml
  [kocdaniel@hadoop102 hadoop]$ cp mapred-site.xml.template mapred-site.xml
  [kocdaniel@hadoop102 hadoop]$ vim mapred-site.xml
  # 在文件中增加如下配置
  <!-- 指定MR运行在Yarn上 -->
  <property>
  		<name>mapreduce.framework.name</name>
  		<value>yarn</value>
  </property>
  ```

3. 将配置好的文件利用集群分发脚本同步到hadoop103和hadoop104节点

```shell
[kocdaniel@hadoop102 hadoop]$ xsync /opt/module/hadoop-2.7.2/
```

* 最好在同步完成之后检查一下同步结果，避免错误

## 单点启动

1. 如果是**第一次**启动，需要格式化namenode，否则跳过此步

```shell
[kocdaniel@hadoop102 hadoop-2.7.2]$ hadoop namenode -format
```

* 格式化需要**注意**的问题：
  * 只有第一次启动需要格式化，以后不要总是格式化，否则会出现namenode和datanode的集群id不一致的情况，导致datanode启动失败
  * **正确的格式化姿势**：
    * 在执行第一次格式化时会在hadoop安装目录下产生data文件夹，里面会生成namenode的信息
    * 在启动namenode和datanode后，还会在同样的目录下产生logs的日志文件夹
    * 所以在格式化之前需要先将这两个文件夹删除，然后再格式化，最后启动namenode和datanode

2. 在hadoop102上启动namenode

```shell
[kocdaniel@hadoop102 hadoop-2.7.2]$ hadoop-daemon.sh start namenode
[kocdaniel@hadoop102 hadoop-2.7.2]$ jps
3461 NameNode
```

3. 在hadoop102、hadoop103以及hadoop104上分别启动DataNode

```shell
[kocdaniel@hadoop102 hadoop-2.7.2]$ hadoop-daemon.sh start datanode
[kocdaniel@hadoop102 hadoop-2.7.2]$ jps
3461 NameNode
3608 Jps
3561 DataNode
[kocdaniel@hadoop103 hadoop-2.7.2]$ hadoop-daemon.sh start datanode
[kocdaniel@hadoop103 hadoop-2.7.2]$ jps
3190 DataNode
3279 Jps
[kocdaniel@hadoop104 hadoop-2.7.2]$ hadoop-daemon.sh start datanode
[kocdaniel@hadoop104 hadoop-2.7.2]$ jps
3237 Jps
3163 DataNode
```

4. 访问[hadoop102:50070](hadoop102:50070)查看结果

* 但是以上单点启动有一个问题：
  * 每次都一个一个节点启动，如果节点数增加到1000个怎么办？

## 配置ssh免密登录

1. 配置ssh

   * ssh 另一个节点的ip    就可以切换到另一台机器，但是得输入密码

2. 免密ssh配置

   * 免密登录原理

   ![1569326608911](https://mmbiz.qpic.cn/mmbiz_png/hlLEC0QP5QV039Z20n7Y9YxfwD9mEAy0ZDpFOKuIoEeaKdraF3zc7j6HnLEnq8JoS7ezVDAE0w0QnDibAHER6Qg/0?wx_fmt=png)

   * 在配置namenode的主机hadoop102上生成私钥和公钥

     * 切换目录到`/home/用户名/.ssh/`

     ```shell
     [kocdaniel@hadoop102 .ssh]$ ssh-keygen -t rsa
     ```

     * 然后敲（三个回车），就会生成两个文件id_rsa（私钥）、id_rsa.pub（公钥）
     * 将公钥拷贝到要免密登录的目标机器上

     ```shell
     [kocdaniel@hadoop102 .ssh]$ ssh-copy-id hadoop103
     [kocdaniel@hadoop102 .ssh]$ ssh-copy-id hadoop104
     # 注意：ssh访问自己也需要输入密码，所以我们需要将公钥也拷贝给102
     [kocdaniel@hadoop102 .ssh]$ ssh-copy-id hadoop102
     ```

   * 同样，在配置resourcemanager的主机hadoop103上执行同样的操作，然后就可以群起集群了

## 群起集群

1. 配置slaves

   * 切换目录到：`hadoop安装目录/etc/hadoop/`
   * 在目录下的slaves文件中添加如下内容

   ```shell
   [kocdaniel@hadoop102 hadoop]$ vim slaves
   # 注意结尾不能有空格，文件中不能有空行
   hadoop102
   hadoop103
   hadoop104
   ```

   * 同步所有节点的配置文件

   ```shell
   [kocdaniel@hadoop102 hadoop]$ xsync slaves
   ```

   

2. 启动集群

   * 同样，如果是第一次启动，需要格式化
   * 启动HDFS

   ```shell
   [kocdaniel@hadoop102 hadoop-2.7.2]$ sbin/start-dfs.sh
   
   # 查看启动结果，和集群规划（配置文件中）的一致
   [atguigu@hadoop102 hadoop-2.7.2]$ jps
   4166 NameNode
   4482 Jps
   4263 DataNode
   
   [atguigu@hadoop103 hadoop-2.7.2]$ jps
   3218 DataNode
   3288 Jps
   
   [atguigu@hadoop104 hadoop-2.7.2]$ jps
   3221 DataNode
   3283 SecondaryNameNode
   3364 Jps
   ```

   * 启动YARN

   ```shell
   # 注意：NameNode和ResourceManger如果不是同一台机器，不能在NameNode上启动 YARN，应该在ResouceManager所在的机器上启动YARN
   [kocdaniel@hadoop103 hadoop-2.7.2]$ sbin/start-yarn.sh
   ```

3. web端查看相关信息


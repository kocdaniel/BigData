## Hive元数据备份

在hive中元数据是非常重要的，那么元数据的备份就显得非常重要了，元数据配置存储到MySQL中，以下三种备份方案：

1. 只配一个MySQL，定期备份元数据信息到硬盘
2. 配置MySQL一主一从模式，利用MySQL的主从复制，当主挂掉之后，主机从从机中恢复数据（注意：MySQL中的主从，从机不会自动上位）
3. 配置MySQL双主模式，基于keepalived的MySQl HA

## MySQL一主一从

![](D:\MyWork\BigData\img\MySQL一主一从.png)

* mysql的master会维护一个bin_log日志文件，在master上产生的任何操作都会在bin_log中记录；
* mysql的slave会维护一个中继日志的文件，此文件会将bin_log中的内容同步
* 然后slave根据中继日志记录的操作，生成从机上的数据，实现主从一致

## MySQL双主模式及keepalived原理

双主模式是基于keepalived的MySQl HA

![](D:\MyWork\BigData\img\基于keepalived的MySQL HA.png)

* keeplived也有主从之分，可以用其来实现MySQL的双主高可用
* keeplived的master和backup同时维护一个虚拟ip（vip），且此vip开始默认指向keeplived的master
* 维护vip的同时还各自维护一个各自节点的真实ip，
* 所以当hive访问MySQL时，是通过vip找到对应的真实ip
* 当master挂掉时，最初指向master的vip自动切换到backup，从机上位

## MySQL和keeplived的启动顺序

配置基于keeplived的高可用之后，要注意的是MySQL和keeplived的开机自启动顺序

**原理：**

* 当keeplived所在节点的mysql挂掉之后，会首先将keeplived服务stop掉，从keeplived上位

* 所以当开机自启的时候，如果先启动keeplived，这时keeplived发现mysql服务没有启动，就会判断为mysql挂掉，

  于是再次干掉keeplived，导致keeplived无法启动

* 所以设置开机自启一定是MySQL先启动（**具体配置见MySQL HA文档**）




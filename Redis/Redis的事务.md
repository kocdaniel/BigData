# 定义
* Redis事务是一个单独的隔离操作：事务的所有命令都会序列化、按顺序的执行，在执行的过程中不会被其他客户端发来的命令打断
* 主要作用：**串联多个命令，防止别的命令插队**

# 执行过程
## Multi，Exec，discard
* 从输入Multi命令开始，输入的命令一次进入命令队列中，但是不会执行
* 直到输入Exec后，Redis会将之前的命令队列中的命令依次执行
* 组队的过程中可以通过discard来放弃组队
* 如下图：

![https://github.com/kocdaniel/BigData/blob/master/img/redis%E4%BA%8B%E5%8A%A1%E6%89%A7%E8%A1%8C%E8%BF%87%E7%A8%8B.png](https://github.com/kocdaniel/BigData/blob/master/img/redis事务执行过程.png)

## 事务的错误处理
1. 组队时错误：组队中某个命令出现错误，执行时整个的所有队列都会取消而不执行

**如图：Exec不执行**

![https://github.com/kocdaniel/BigData/blob/master/img/%E7%BB%84%E9%98%9F%E6%97%B6%E9%94%99%E8%AF%AF.png](https://github.com/kocdaniel/BigData/blob/master/img/组队时错误.png)

2. 执行时错误：如果执行时某个命令发生错误，则只有报错的命令不执行，其他命令会依次执行，而不会发生回滚

**如图：只有error处不执行**
[!https://github.com/kocdaniel/BigData/blob/master/img/%E6%89%A7%E8%A1%8C%E6%97%B6%E9%94%99%E8%AF%AF.png](https://github.com/kocdaniel/BigData/blob/master/img/执行时错误.png)

# 为什么要做成事务
* 解决事务冲突的问题

## 悲观锁与乐观锁
### 悲观锁（Pessimistic Lock）
* 顾名思义，就是很悲观，每次去拿数据都认为别人会修改数据
* 所以在每次拿数据的时候都会上锁，这样别人想拿这个数据就会block直到他拿到锁
* 传统的关系型数据库就用到了很多这种锁机制，都是在操作之前先上锁

### 乐观锁（Optimistic Lock）
* 顾名思义，就是很乐观，每次去拿数据时都认为别人不会修改，所以不会上锁
* 但是在更新数据的时候会判断别人有没有去更新这个数据，使用**版本号等机制**，每次更新操作都会更新版本号
* 乐观锁适用于多读的应用类型，这样可以提高吞吐量
* Redis就是利用这种check-and-set机制，实现事务

### 理解悲观锁与乐观锁
![https://github.com/kocdaniel/BigData/blob/master/img/%E6%82%B2%E8%A7%82%E9%94%81%E4%B8%8E%E4%B9%90%E8%A7%82%E9%94%81.png](https://github.com/kocdaniel/BigData/blob/master/img/悲观锁与乐观锁.png)

## WATCH key [key ...]
* 在执行multi之前，先执行watch key1[key2...]，可以监视一个（或多个）key
* 如果在事务执行之前这个（或这些）key被其它命令改动，该事务被打断

## unwatch
* 取消watch命令对所有key的监视
* 如果在执行watch之后，exec或discard命令先被执行的话，就不需要unwatch了

# Redis的三特性
1. 单独的隔离操作

    事务中的所有命令都会序列化、按顺序地执行。事务在执行的过程中，不会被其他客户端发送来的命令请求所打断。
2. 没有隔离级别的概念

    队列中的命令没有提交之前都不会实际的被执行，因为事务提交前任何指令都不会被实际执行，也就不存在“事务内的查询要看到事务里的更新，在事务外查询不能看到”这个让人万分头痛的问题 

3. 不保证原子性
    Redis同一个事务中如果有一条命令执行失败，其后的命令仍然会被执行，没有回滚      
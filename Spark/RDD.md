



# Spark Core 之 RDD编程

## 一、RDD的创建

### 1. RDD从内存（集合）中创建

（1）**两个方法**

* 两种方式：parallelize 和 makeRDD
* makeRDD内部调用parallelize ，所以二者完全一样

```scala
  def main(args: Array[String]): Unit = {

    // 创建配置文件，并创建SparkContext()对象
    val conf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("Spark01_WordCount1")
    val sc: SparkContext = new SparkContext(conf)
    // 新建集合对象
    val datas: List[Int] = List(1,2,3,4)
    // 从内存中创建RDD
    val dataRDD: RDD[Int] = sc.parallelize(datas)
//    val dataRDD: RDD[Int] = sc.makeRDD(datas)
    dataRDD.collect().foreach(println)

    // 释放资源
    sc.stop()
  }
```

（2）**RDD的分区规则**

```scala
// 创建配置文件，并创建SparkContext()对象
    val conf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("Spark01_WordCount1")

// makeRDD中默认分区为defaultParallelism
  def makeRDD[T: ClassTag](
      seq: Seq[T],
      numSlices: Int = defaultParallelism): RDD[T] = withScope {
    parallelize(seq, numSlices)
  }
// defaultParallelism的实现如下：默认为cpu的核数
override def defaultParallelism(): Int =
    scheduler.conf.getInt("spark.default.parallelism", totalCores)

// getInt方法：如果参数"spark.default.parallelism"的值存在，返回它的Int值
// 			如果不存在，返回默认值totalCores
// 			而totalCores即为设置的setMaster("local[*]")的值
  def getInt(key: String, defaultValue: Int): Int = {
    getOption(key).map(_.toInt).getOrElse(defaultValue)
  }
```

（3）**分区之后数据的放置规则**

```scala
// 在 parallelize 下的 new ParallelCollectionRDD[T](this, seq, numSlices, Map[Int, Seq[String]]())   
// 方法中有如下方法：
// length：当前集合的长度
// numSlices：当前切片的数量
def positions(length: Long, numSlices: Int): Iterator[(Int, Int)] = {
    // until左闭右开
      (0 until numSlices).iterator.map { i =>
        val start = ((i * length) / numSlices).toInt
        val end = (((i + 1) * length) / numSlices).toInt
        (start, end)
      }
    }
/*
	RDD的读取数据规则和hadoop中读数据的方式一样，都是按行读取，而且每行都有偏移量的概念
	假设：length=5 numSlices=3    数据为：list(1,2,3,4,5)
	分区=0 => (0,1) => 0号分区放(1-0=1)个 => 1
	分区=1 => (1,3) => 1号分区放(3-1=2)个 => 2 3
	分区=2 => (3,5) => 2号分区放(5-3=2)个 => 4 5
*/
```



### 2. RDD从存储系统中创建

（1）`textFile`方法

```scala
    // 从存储系统中创建
    val dataRDD: RDD[String] = sc.textFile("input")
    dataRDD.collect().foreach(println)
```

（2）**RDD的分区规则**

```scala
// TODO 分区的数量：默认为当前核数与2取最小值
val dataRDD: RDD[String] = sc.textFile("input")

// textFile方法：minPartitions参数为最小分区
def textFile(
      path: String,
      minPartitions: Int = defaultMinPartitions): RDD[String] = withScope {
    assertNotStopped()
    hadoopFile(path, classOf[TextInputFormat], classOf[LongWritable], classOf[Text],
      minPartitions).map(pair => pair._2.toString).setName(path)
  }
// 其中默认最小分区：defaultMinPartitions如下
// defaultParallelism即为设置的cpu核数
def defaultMinPartitions: Int = math.min(defaultParallelism, 2)

```

（3）**分区之后数据的放置规则**

```scala
// 10 / 3 = 3 ... 1 三个分区，每个分区3个字节，余一个字节,所以最小三个分区，实际上需要四个分区
// 按行读取，一次读取一行
// 原始数据 => 数据偏移量
// 1xx => 012 => 0号分区放偏移量为0 ~ 3(0+3)的 => 1,2
// 2xx => 345 => 1号分区放偏移量为3 ~ 6(3+3)的 => 3
// 3xx => 678 => 2号分区放偏移量为6 ~ 9(6+3)的 => 4
// 4   => 9   => 3号分区放偏移量为9 ~ 10(9+1)的 => 空
val dataRDD: RDD[String] = sc.textFile("input/3.txt", 3)
```

## 二、RDD的转换 & 行动算子

### 1. 转换算子（方法）

根据RDD数据类型的不同，整体分为两种RDD：

* Value类型
* Key-Value类型（二元数组）

#### 1.1 Value类型

##### 1.1.1  算子 - 转换 - map(）：A => B

* 案例

```scala
// ×2
val datas: List[Int] = List(1,2,3,4)
val dataRDD: RDD[Int] = sc.makeRDD(datas)
val mapRDD: RDD[Int] = dataRDD.map(_*2)
mapRDD.collect().foreach(println)
```

* map实现原理

![](D:\MyWork\BigData\img\spark-map-实现原理.png)

```scala
/*
	map实现原理：分区不变，但类型发生改变
	从第一个RDD转换为第二个RDD，第二个RDD的分区和前一个RDD的分区一致
	并且实现相应的转换规则后，转换后的数据也存在和第一个RDD对应的分区中
	有一种从A=>B的感觉，A和B的类型是可以不一样的
*/

// map中new MapPartitionsRDD
  def map[U: ClassTag](f: T => U): RDD[U] = withScope {
    val cleanF = sc.clean(f)
    new MapPartitionsRDD[U, T](this, (context, pid, iter) => iter.map(cleanF))
  }
// MapPartitionsRDD 中有getPartitions方法
// firstParent[T].partitions 获取到第一个RDD的分区规则
  override def getPartitions: Array[Partition] = firstParent[T].partitions

// firstParent[T]方法返回第一个parent RDD
  /** Returns the first parent RDD */
  protected[spark] def firstParent[U: ClassTag]: RDD[U] = {
    dependencies.head.rdd.asInstanceOf[RDD[U]]
  }
```

##### 1.1.2 算子 - 转换 - mapPartitions(）：Iterator[T] => Iterator[U] 

* 案例

```scala
val datas: List[Int] = List(1,2,3,4)
val dataRDD: RDD[Int] = sc.makeRDD(datas)
// mapPartitions() 传入的是一整个分区的数据datas，然后对分区的数据做操作
// 这样可以把整个分区的数据都在第二个RDD的内存中操作，减少网络IO，提高效率
val mapPartitionsRDD: RDD[Int] = dataRDD.mapPartitions(datas => {
	datas.map(_ * 2)
})
mapPartitionsRDD.collect().foreach(println)
```

* mapPartitions(）实现原理

![](D:\MyWork\BigData\img\spark-mapPartitions-实现原理.png)

```scala
/*
	mapPartitions实现原理：一次性拉取一个分区的全部数据，将一个分区的数据拉取到下一个RDD的内存中再做处理，
	减少网络IO，提高效率
	
	存在问题：
	使用map时，当数据转换完成，会直接将原数据释放，但是mapPartitions不会
	mapPartitions将原数据拉取到内存中处理，但是处理完成后释放不掉（只有当一个分区内的数据全部处理完
	才能回收），所以一个分区内的数据会越积越多，当积累到一定程度之后会发生内存溢出(OOM)
*/
```

##### 1.1.3 算子 - 转换 - mapPartitionsWithIndex  ：（int，iterator[T]）=> iterator[U]

* 案例

```scala
    /*
    	需求：对每个分区的数据进行不同的操作
    */
	val datas: List[Int] = List(1,2,3,4)
    val dataRDD: RDD[Int] = sc.makeRDD(datas)
    val mapPartitionsWithIndexRDD: RDD[Int] = dataRDD.mapPartitionsWithIndex(
      // 传入的元组，第一个是分区编号，第二个是分区内的数据  
      (index, datas) => {
        // 将 分区内的数据 * (编号+2)
        datas.map(_ * (index + 2))
      }
    )
    mapPartitionsWithIndexRDD.collect().foreach(println)
```

* 改进

```scala
    /*
    	需求：对每个分区的数据进行不同的操作，并且将分区编号也打印输出
    */
	val datas: List[Int] = List(1,2,3,4)
    val dataRDD: RDD[Int] = sc.makeRDD(datas)
    val mapPartitionsWithIndexRDD: RDD[Int] = dataRDD.mapPartitionsWithIndex(
      // 传入的元组，第一个是分区编号，第二个是分区内的数据  
      (index, datas) => {
        // 将 分区内的数据 * (编号+2)，并将分区编号同时打印输出
        datas.map(data => (index, data * (index + 2)))
      }
    )
    mapPartitionsWithIndexRDD.collect().foreach(println)
```

##### 1.1.4 算子 - 转换 -flatMap

```scala
// flatMap只能解析最外层
//    1. val datas = List("hello world","hello spark")
//    2. val datas = List(List("hello world","hello spark"),List("hello world","hello spark"))
//    val dataRDD: RDD[List[String]] = sc.makeRDD(datas)
    val datas = List(1,List(2,3),List(4,5))
    val dataRDD: RDD[Any] = sc.makeRDD(datas)

    val flatMapRDD: RDD[Int] = dataRDD.flatMap(
      data => {
        data match {
          case i: Int => List(i)
          case list: List[Int] => list
          case _ => Nil
        }
      }
    )

//    1. val flatMapRDD: RDD[String] = dataRDD.flatMap(datas=>datas.split(" "))
//    2. val flatMapRDD: RDD[String] = dataRDD.flatMap(datas=>datas.flatMap(_.split(" ")))
    flatMapRDD.collect().foreach(println)
```

##### 1.1.5 算子 - 转换 -glom

```scala
    // 求每个分区的最大值，并求和
    val datas = List(1,3,2,5,4,6)
    val makeRDD: RDD[Int] = sc.makeRDD(datas,3)
  /*
    // 传统方法
    // (1,3) (2,5) (4,6)
    val maxRDD: RDD[Int] = makeRDD.mapPartitions(datas => {
      List(datas.max).iterator
    })
    println(maxRDD.collect().sum)
  */

    // 使用glom
    // glom会将每个分区的数据封装为数组集合，数组的所有方法就都可以用了
    val glomRDD: RDD[Array[Int]] = makeRDD.glom()
    val maxRDD: RDD[Int] = glomRDD.map(_.max)
    println(maxRDD.collect().sum)
```

##### 1.1.6 算子 - 转换 -groupBy(func)

```scala
//val datas = List( 1,2,3,4,1,2,3 )
//val dataRDD: RDD[Int] = sc.makeRDD(datas1)
val datas1 = List( "Hello", "Hive", "Hadoop", "Spark", "Scala" )
val dataRDD1: RDD[String] = sc.makeRDD(datas1)

// TODO 根据指定的算法规则（函数）进行数据分组
// 函数的返回结果就是用于分组的Key
//val groupRDD: RDD[(Int, Iterable[Int])] = dataRDD.groupBy(num=>num)
//val groupRDD: RDD[(Int, Iterable[Int])] = dataRDD.groupBy(num=>num%2)
val groupRDD: RDD[(String, Iterable[String])] = dataRDD1.groupBy(str=>str.substring(0,1))

groupRDD.collect.foreach(println)
```



##### 1.1.7 算子 - 转换 -filter(func)

```scala
// 算子 - 转换 - filter
val datas = List(1,2,3,4)
val dataRDD = sc.makeRDD(datas)

// 根据指定的规则对数据进行筛选过滤
val filterRDD: RDD[Int] = dataRDD.filter(num=>num%2==1)

filterRDD.collect().foreach(println)
```



##### 1.1.8 算子 - 转换 -sample(withReplacement, fraction, seed)

```scala
    val datas = List(1,2,3,4)
    val makeRDD: RDD[Int] = sc.makeRDD(datas)

    /*
      第一个参数：是否放回
      第二个参数：
         -当不放回时，fraction=[0,1]，表示抽取的概率
            * fraction=0,全不取
            * fraction=1,全取
            * fraction=(0,1),表示概率>=fraction时，抽取
         -当放回时，fraction表示选择每个元素的期望次数; 分数必须大于等于0
      第三个参数：seed：随机数种子，随机数种子固定之后，随机数也就变成了固定的一些数字。

    */
    val sampleRDD: RDD[Int] = makeRDD.sample(false, 0.7)
//    val sampleRDD: RDD[Int] = makeRDD.sample(true, 3)

    sampleRDD.collect().foreach(println)
```

##### 1.1.9 算子 - 转换 -distinct([numTasks]))

```scala
// 算子 - 转换 - distinct
val datas = List(1,2,3,4,1,2)
val dataRDD = sc.makeRDD(datas)

// 去掉重复数据（可以改变分区）
//val distinctRDD: RDD[Int] = dataRDD.distinct()
val distinctRDD: RDD[Int] = dataRDD.distinct(3)

distinctRDD.collect().foreach(println)
```

* **去重原理**

```scala
 /*
 	源码思想：map(x => (x, null)).reduceByKey((x, y) => x, numPartitions).map(_._1)
 	List(1,2,3,4,1,2)
 	=>map(x => (x, null))=>(1,null)，(2,null)，(3,null)，(4,null)，(1,null)，(2,null)
 	=>reduceByKey((x, y) => x, numPartitions)=>(1,(null,null)) ， (2,(null,null)) ， (3,null)(4,null)
 	=>map(_._1)=>1,2,3,4
 */
 def distinct(numPartitions: Int)(implicit ord: Ordering[T] = null): RDD[T] = withScope {
    map(x => (x, null)).reduceByKey((x, y) => x, numPartitions).map(_._1)
  }
```



##### 1.1.10 算子 - 转换 -coalesce(numPartitions) & repartition(numPartitions)

```scala
    val datas = List(1,2,3,4,5,6,7,8)
    val dataRDD = sc.makeRDD(datas,4)

    /*
      coalesce:
        * 缩减分区，合并分区
            -第一个参数：分区数量
            -第二个参数：shuffle，默认为false;
                        如果shuffle为false，则不会打乱重组，此时减少分区有效，而增加分区是无效的
        * shuffle：打乱重组
      repartition:
        * 重分区(打乱重组)，扩大分区
        * 可以增加分区也可以减少分区，因为内部调用coalesce(numPartitions, shuffle = true)
          def repartition(numPartitions: Int)(implicit ord: Ordering[T] = null): RDD[T] = withScope {
            coalesce(numPartitions, shuffle = true)
          }

    */

//    val coalesceRDD: RDD[Int] = dataRDD.coalesce(2)
    val repartitionRDD: RDD[Int] = dataRDD.repartition(2)

    repartitionRDD.mapPartitionsWithIndex{
      (index, datas)=>{
        datas.foreach(data=>{
            println(index + "=" + data )
        })
        datas
      }
    }.collect()

//    coalesceRDD.collect().foreach(println)
```

* coalesce缩减分区原理

![](D:\MyWork\BigData\img\coalesce缩减分区不打乱重组.png)

```scala
/*
	假设第一个RDD有三个分区，如上图，每个分区有对应的数据，
	此时若使用coalesce改变分区数为2时，数据该如何放呢？
		* 如上图所示，它会将第一个分区放在一个分区，其余的合并到另一个分区，
		  此时可能会发生严重的数据倾斜
	
*/
```

![](D:\MyWork\BigData\img\coalesce-shuffle.png)

```scala
/*
	既然有数据倾斜的问题，那么如何才能让数据比较均匀的分配到第二个RDD的两个分区呢？
    	此时就用到了shuffle，将coalesce方法的第二个参数设为true即可，这样数据就会打乱重组，
    	重新分配到这两个分区
*/
```

![](D:\MyWork\BigData\img\coalesce-shuffle-map&reduce.png)

```scala
/*
	shuffle原理：
		* shuffle不是简单的打乱重组，在这之间有一步落盘的操作
		* 落盘会将最终要分到一个分区的数据在硬盘中存储到一个分区中-->shuffle-read(map)
		* 当落盘完成时，后续操作会从硬盘中取对应分区的数据，加载到内存中做后续的处理-->shuffle-write(reduce)
*/
```



##### 1.1.11 算子 - 转换 -sortBy(func,[ascending], [numTasks])

```scala
//    val datas = List(1,2,3,4,7,8,5,6)
    val datas = List((1,2),(1,1),(2,2),(2,1))
    val dataRDD = sc.makeRDD(datas,4)

    /*
      sortBy:
        第一个参数：指定排序规则
        第二个参数：指定升序还是降序，默认升序
     */

//    val sortByRDD: RDD[Int] = dataRDD.sortBy(num=>num)
    
    // 若是对元组进行排序，默认的排序规则就是：
    // 先按照第一个元素排序，若第一个元素相等，则按照第一个元素排序
    val sortByRDD: RDD[(Int, Int)] = dataRDD.sortBy(t1=>t1)
```

##### 1.1.12 算子 - 转换 -pipe(command, [envVars])

```
作用: 
管道，针对每个分区，把 RDD 中的每个数据通过管道传递给shell命令或脚本，返回输出的RDD。一个分区执行一次这个命令. 如果只有一个分区, 则执行一次命令.

注意:脚本要放在 worker 节点可以访问到的位置

```



#### 1.2 双 Value 类型交互

##### 1.2.1 算子 - 转换 -union(otherDataset)，intersection，subtract，cartesian

```scala
val datas1 = List(1,2,1,4)
val datas2 = List(1,5,6,7)

val rdd1 = sc.makeRDD(datas1,2)
val rdd2 = sc.makeRDD(datas2,2)

// 并集
//println(rdd1.union(rdd2).collect().mkString(","))
// 交集
//println(rdd1.intersection(rdd2).collect().mkString(","))
// 差集
//println(rdd1.subtract(rdd2).collect().mkString(","))

// 拉链
// Can only zip RDDs with same number of elements in each partition
// Can't zip RDDs with unequal numbers of partitions: List(2, 3)
//println(rdd1.zip(rdd2).collect().mkString(","))

// 笛卡尔积
println(rdd1.cartesian(rdd2).collect().mkString(","))

sc.stop()
```



##### 1.2.2 算子 - 转换 -zip(otherDataset)

```scala
val datas1 = List(1,2,3,4)
val datas2 = List(1,5,6,7)

val rdd1 = sc.makeRDD(datas1,2)
val rdd2 = sc.makeRDD(datas2,2)

// 拉链
/*
	zip比Scala中的zip要更加严格：
		* Can only zip RDDs with same number of elements in each partition
		要求每个分区的元素个数相同
		* Can't zip RDDs with unequal numbers of partitions: List(2, 3)
		要求两个RDD的分区数必须相同
*/
println(rdd1.zip(rdd2).collect().mkString(","))
sc.stop()
```



#### 1.3 Key-Value 类型

```scala
/*
	RDD本身并不提供对Key-Value类数据的操作，而是需要进行隐式转换，转换成PairRDDFunctions进行操作.
	object RDD下有对隐式函数rddToPairRDDFunctions的定义
*/
  implicit def rddToPairRDDFunctions[K, V](rdd: RDD[(K, V)])
    (implicit kt: ClassTag[K], vt: ClassTag[V], ord: Ordering[K] = null): PairRDDFunctions[K, V] = {
    new PairRDDFunctions(rdd)
  }
```

##### 1.3.1 算子 - 转换 - partitionBy

```scala
    // 算子-转换-partitionBy
    val datas = List( ("a", 1), ("b", 1), ("c", 1) )

    val dataRDD: RDD[(String, Int)] = sc.makeRDD(datas,1)

    // 重分区：根据指定的分区规则对数据进行分区
	// 所谓分区规则就是分区器，可以自定义
    val partitionByRDD: RDD[(String, Int)] = dataRDD.partitionBy(new org.apache.spark.HashPartitioner(3))

    partitionByRDD.mapPartitionsWithIndex{
      (index, datas) =>{
        datas.foreach(
          data=>{println(index + "=" + data)}
        )
        datas
      }
    }.collect()
```

* 自定义分区器

```scala
// 自定义分区器

// val datas = List( ("cba", "xxxx"), ("nba", "yyyy"), ("ball", "zzzz"),(2, "tttt") )

/*
    1.继承Partitioner
    2.重写方法
*/
class MyPartitioner(num:Int) extends Partitioner{

  // 获取分区数量
  override def numPartitions: Int = {
    num
  }

  // 根据数据的key获取所在分区号码(从0开始)
  override def getPartition(key: Any): Int = {

    if (key.isInstanceOf[String]){
      val keyString: String = key.asInstanceOf[String]
      if(keyString == "nba"){
        0
      }else if (keyString == "cba"){
        1
      }else{
        2
      }
    }else{
      2
    }
  }
}
```



##### 1.3.2 算子 - 转换 - reduceByKey(func, [numTasks]) & groupByKey()

```scala

    // 算子 - 转换 - reduceByKey, groupByKey
    val datas = List( ("a", 1), ("b", 2), ("c", 3),("a", 4) )

    val dataRDD = sc.makeRDD(datas,1)

    // WordCount - 2
    // reduceByKey将相同key的value进行聚合
//    val reduceRDD: RDD[(String, Int)] = dataRDD.reduceByKey(_+_)
//
//    println(reduceRDD.collect().mkString(","))

    
    // WordCount - 3
    // groupByKey只按照key进行分组，不聚合
    val groupByRDD: RDD[(String, Iterable[Int])] = dataRDD.groupByKey()

    val sumRDD: RDD[(String, Int)] = groupByRDD.map {
      case (key, list) => {
        (key, list.sum)
      }
    }

    println(sumRDD.collect().mkString(","))
```

* **reduceByKey与groupByKey的区别**

![](D:\MyWork\BigData\img\groupByKey.png)

![](D:\MyWork\BigData\img\reduceByKey.png)

```scala
* groupByKey：按照key进行分组，直接进行shuffle
	- 需要将分区内的全部数据落盘
	- 只进行分组，不聚合
* reduceByKey：按照key进行聚合，在shuffle之前有combine（预聚合）操作，返回结果是RDD[k,v]
	- 在落盘之前先进行分区内Combine，落盘的数据较少
	- 减少磁盘IO的数据量，效率更高，性能更好
```



##### 1.3.3 算子 - 转换 - aggregateByKey(zeroValue)(seqOp, combOp, [numTasks]) & foldByKey

```scala
    // 算子 - 转换 - aggregateByKey
    val datas = List( ("a", 1), ("b", 2), ("b", 3), ("c", 3),("a", 4),("a", 2) )

    val dataRDD = sc.makeRDD(datas,2)

    // TODO 取出每个分区相同key对应值的最大值，然后相加
    /*
       aggregateByKey聚合数据，有两个参数列表
        * 第一个参数列表：只有一个参数zeroValue，表示初始值
              - 给每一个分区中的每一个key一个初始值
              - 因为要对相同key的value进行比较，如果没有初始值，那么取到的第一个值就没有比较对象
              
        * 第二个参数列表：有两个参数
              - 第一个参数：分区内计算规则
              - 第二个参数：分区间计算规则

       aggregateByKey 和 reduceByKey的区别：
          * reduceByKey 分区内和分区间计算规则相同
       foldByKey与aggregateByKey的区别：
          * 当aggregateByKey的分区内和分区间计算规则相同时，可以用foldByKey
    */
    val resultRDD: RDD[(String, Int)] = dataRDD.aggregateByKey(0)(
      // 分区内取相同key的最大值
      (v1, v2) => math.max(v1, v2),
      // 分区间求和
      (v1, v2) => v1 + v2
    )
    println(resultRDD.collect().mkString(","))
```

```scala
// 算子 - 转换 - foldByKey
val datas = List( ("a", 1), ("b", 2), ("b", 3), ("c", 3),("a", 4),("a", 2) )
val dataRDD = sc.makeRDD(datas,2)
// TODO wordcount -4
//    val wordToCountRDD: RDD[(String, Int)] = dataRDD.aggregateByKey(0)(_+_, _+_)
/*
      foldByKey与aggregateByKey的区别：
          * 当aggregateByKey的分区内和分区间计算规则相同时，可以用foldByKey
 */
val wordToCountRDD: RDD[(String, Int)] = dataRDD.foldByKey(0)(_+_)
println(wordToCountRDD.collect().mkString(","))
```

##### 1.3.4 算子 - 转换 -  combineByKey[C]

![](D:\MyWork\BigData\img\combineByKey.png)

```scala
    // 算子 - 转换 - combineByKey
    val datas = List( ("a", 100), ("b", 200), ("b", 300), ("c", 300),("a", 400),("a", 200) )

    val dataRDD : RDD[(String,Int)] = sc.makeRDD(datas,2)

    // TODO 需求：相同key求平均值
    // groupByKey可以完成需求，但是由于groupByKey没有预聚合的功能，效率较低，不建议使用
/*    val groupByKeyRDD: RDD[(String, Iterable[Int])] = dataRDD.groupByKey()
    val resultRDD: RDD[(String, Int)] = groupByKeyRDD.map {
      case (key, list) => {
        (key, list.sum / list.size)
      }
    }
    println(resultRDD.collect().mkString(","))*/

    /*
        combineByKey：只有一个参数列表，有三个参数
            * 第一个参数 ：将分区内的第一个值进行结构转换，以满足需求
            * 第二个参数 ：分区内计算规则
            * 第三个参数 ：分区间计算规则
     */
    val combineByKeyRDD: RDD[(String, (Int, Int))] = dataRDD.combineByKey(
      // 因为要求平均，所以必须要知道相同key对应的value个数
      num => (num, 1),
      // 分区内计算规则是：tuple 和 num聚合
      (t1: (Int, Int), num) => (t1._1 + num, t1._2 + 1),
      // 分区间计算规则是：两个tuple聚合
      (t1: (Int, Int), t2: (Int, Int)) => (t1._1 + t2._1, t1._2 + t2._2)
    )
    combineByKeyRDD.collect().foreach{
      case (key, (sum, count)) => println(key + "=" + sum/count)
    }
```

##### 1.3.5 reduceByKey & aggregateByKey & foldByKey & combineByKey 的底层实现

```scala
// reduceByKey
combineByKeyWithClassTag[V](
    (v: V) => v, 
    func, 
    func, 
    partitioner)

// aggregateByKey
combineByKeyWithClassTag[U](
    (v: V) => cleanedSeqOp(createZero(), v), // 初始值
    cleanedSeqOp,  // 分区内计算规则
    combOp, // 分区间计算规则
    partitioner)

// foldByKey
combineByKeyWithClassTag[V](
    (v: V) => cleanedFunc(createZero(), v), // 初始值
    cleanedFunc, // 分区内计算规则
    cleanedFunc, // 分区间计算规则
    partitioner)

// combineByKey 
combineByKeyWithClassTag(
    createCombiner, // 初始值
    mergeValue, // 分区内计算规则
    mergeCombiners, // 分区间计算规则
    defaultPartitioner(self))

/*
	这四个函数底层都调用combineByKeyWithClassTag，而combineByKeyWithClassTag内部都使用了预聚合
*/
  def combineByKeyWithClassTag[C](
      createCombiner: V => C,
      mergeValue: (C, V) => C,
      mergeCombiners: (C, C) => C,
      partitioner: Partitioner,
      mapSideCombine: Boolean = true, // 预聚合
```

##### 1.3.5 算子 - 转换 - sortByKey

```scala
    // 算子 - 转换 - sortByKey
    val datas = List( (1, "a"), (10, "b"), (11, "c"), (4, "d"), (20, "d"), (10, "e") )

    val dataRDD: RDD[(Int, String)] = sc.makeRDD(datas)

    /*
         sortByKey：
            按照key进行排序，默认为true，升序
    */
    dataRDD.sortByKey(false).collect().foreach(println)
```

##### 1.3.6 算子 - 转换 - mapValues

```scala
    // 算子 - 转换 - mapValues
    // TODO value 从大到小 top3
    val datas = List( (1,1),(1,2),(1,4),(1,6),(1,5),(1,3) )
    val dataRDD: RDD[(Int, Int)] = sc.makeRDD(datas)

    val groupRDD: RDD[(Int, Iterable[Int])] = dataRDD.groupByKey()

    /*
        mapValues:
            针对(K,V)形式的类型只对V进行操作
    */
    groupRDD.mapValues(
      nums => {
        nums.toList.sortWith(
          (left, right) => {
            left > right
          }
        ).take(3)
      }
    ).collect().foreach(println)
```



##### 1.3.7 算子 - 转换 - join(otherDataset, [numTasks]) & cogroup(otherDataset, [numTasks])

```scala
    // 算子 - 转换 - join & cogroup
    val datas1 = List((1, 1), (1, 2), (3, 3))
    val datas2 = List((1, 4), (1, 5), (4, 6))

    val rdd1: RDD[(Int, Int)] = sc.makeRDD(datas1)
    val rdd2: RDD[(Int, Int)] = sc.makeRDD(datas2)
    /*
        join 内连接:
        在类型为(K,V)和(K,W)的 RDD 上调用，返回一个相同 key 对应的所有元素对在一起的(K,(V,W))的RDD
    */
    val joinRDD: RDD[(Int, (Int, Int))] = rdd1.join(rdd2)
    joinRDD.collect().foreach(println)
    println("==================================")
    /*
        cogroup:
        在类型为(K,V)和(K,W)的 RDD 上调用，返回一个(K,(Iterable<V>,Iterable<W>))类型的 RDD
    */
    val cogroupRDD: RDD[(Int, (Iterable[Int], Iterable[Int]))] = rdd1.cogroup(rdd2)
    cogroupRDD.collect().foreach(println)
```



### 2. Action算子

##### 2.1 算子 - Action - reduce & count & collect & take & first & takeOrdered

```scala
    val datas = List(1,2,3,4)

    // 算子 - 行动 - reduce
    // 通过func函数聚集 RDD 中的所有元素，先聚合分区内数据，再聚合分区间数据
    val dataRDD: RDD[Int] = sc.makeRDD(datas, 2)
    println(dataRDD.reduce(_ + _))

    // 算子 - 行动 - collect
    val array: Array[Int] = dataRDD.collect()
    array.foreach(println)

    // 算子 - 行动 - count
    val cnt: Long = dataRDD.count()
    println(cnt)

    // 算子 - 行动 - take
    val array1: Array[Int] = dataRDD.take(3)
    array1.foreach(println)

    // 算子 - 行动 - first
    val i: Int = dataRDD.first()
    println(i)

    // 算子 - 行动 - takeOrdered
    // 返回排序后的前 n 个元素, 默认是升序排列（先排后取）
    val array2: Array[Int] = dataRDD.takeOrdered(3)
    array2.foreach(println)
```

##### 2.2 算子 - Action - aggregate & fold

```scala
    val datas = List(1, 2, 3, 4)

    // 算子 - 行动 - aggregate
    val dataRDD: RDD[Int] = sc.makeRDD(datas)
    // 10
    //    val i: Int = dataRDD.aggregate(0)(_+_, _+_)
    /*
        与aggregatebyKey不同：
            aggregate 的 zeroValue 分区内聚合和分区间聚合的时候各会使用一次；
            aggregatebyKey 只在分区内聚合使用一次
    */
    // 60
//    val i: Int = dataRDD.aggregate(10)(_ + _, _ + _)
//    println(i)

    // 算子 - 行动 - fold
    // 当分区内计算规则和分区间计算规则相同时可用fold
    println(dataRDD.fold(0)(_ + _))
```

##### 2.3 算子-Action- saveAsTextFile & saveAsSequenceFile & saveAsObjectFile

```scala
val rdd = sc.makeRDD(List(1,2,3,4),2)
// 算子 - 行动 - saveAsTextFile
rdd.saveAsTextFile("output")
// 算子 - 行动 - saveAsSequenceFile
// saveAsSequenceFile必须时k-v对
rdd.map((_,1)).saveAsSequenceFile("output1")
// 算子 - 行动 - saveAsObjectFile
rdd.saveAsObjectFile("output2")
```

##### 2.4 算子-Action- countBykey & countByvalue

```scala
    // 算子 - 行动 - countByKey
    // WordCount - 7
    val rdd = sc.makeRDD(List("Hello", "Hello", "scala", "scala"),2)

    val countByKeyRDD: collection.Map[String, Long] = rdd.map((_, 1)).countByKey()

    println(countByKeyRDD)

    // 算子 - 行动 - countByValue
    /*
        countByValue 的value不是key-value中的value，是指集合中的每一个元素 
    */
    // WordCount - 8
    println(rdd.countByValue())
```

##### 2.5 算子-Action- foreach()

```scala
作用: 针对 RDD 中的每个元素都执行一次func
每个函数是在 Executor 上执行的, 不是在 driver 端执行的.
```

```scala
    // 算子 - 行动 - foreach
    /*
        foreach:
          当有collect时，结果为：1，2，3，4
          当没有collect时，不是按照顺序打印的，可能时3，4，1，2等

        这是因为，foreach的每个函数是在 Executor 上执行的, 不是在 driver 端执行的，每个Executor单独打印
                 而collect会将Executor上的数据拉到driver上再打印
    */
    val rdd = sc.makeRDD(List(1, 2, 3, 4), 2)

    rdd.collect().foreach(println)

    rdd.foreach(println)
```

* 有collect时：

![](D:\MyWork\BigData\img\foreach-1.png)

* 无collect时

![](D:\MyWork\BigData\img\foreach-2.png)



## 三、RDD中函数的传递

```scala
object Spark35_RDD_Ser {
    def main(args: Array[String]): Unit = {

        val conf = new SparkConf().setMaster("local[*]").setAppName("Spark35_RDD_Ser")
        val sc: SparkContext = new SparkContext(conf)
    
        val rdd: RDD[String] = sc.parallelize(Array("hello world", "hello atguigu", "atguigu", "hahah"), 2)
        val searcher = new Searcher("hello")
        /*
        	调用getMatchedRDD1时，filter算子里边的代码都是在Executor端执行，
        	而里边间接调用了Searcher类的isMatch方法，所以需要将Searcher类的对象
        	传输到Executor端才能调用，所以需要将Searcher类实现序列化才能传输
        */
        val result: RDD[String] = searcher.getMatchedRDD1(rdd)
        /*
        	调用getMatchedRDD2时，同样使用了Searcher的属性query，所以需要序列化
        	但是将query转换为局部变量而非属性，如下
        */
        val result: RDD[String] = searcher.getMatchedRDD2(rdd)
        result.collect.foreach(println)
        
        sc.stop()
    }
}
// Driver Side : 算子以外的代码都是在Driver端执行
// Executor Side ： 算子里面的代码都是在Executor端执行

// 解决方案一 ：样例类自动实现序列化 case class Searcher(val query: String) {
// 解决方案二 ：实现序列化 class Searcher(val query: String) extends Serializable{
class Searcher(val query: String) {
    def isMatch(s : String) ={
        s.contains(query)
    }
    def getMatchedRDD1(rdd: RDD[String]) ={
        rdd.filter(isMatch)  //rdd.filter(this.isMatch)
    }
    def getMatchedRDD2(rdd: RDD[String]) ={
        // 解决方案三 ：这里将query转换为纯string类型，不属于Searcher类，所以这样就可以执行
        // val q = query 
        rdd.filter(_.contains(query))
    }
}
```

* 总结：

```
解决方案：
	传递函数：
        1. 将类实现序列化
        2. 声明为样例类
    传递变量：
    	1. 将类实现序列化
    	2. 声明为样例类
	    3. 属性转换为局部变量
```

## 四、RDD依赖关系

### 4.1  查看RDD的血缘关系

```scala
scala> rdd1.toDebugString
res1: String =
(2) ./words.txt MapPartitionsRDD[1] at textFile at <console>:24 []
| ./words.txt HadoopRDD[0] at textFile at <console>:24 []

// 圆括号中的数字表示 RDD 的并行度. 也就是有几个分区
```



### 4.2 查看RDD的依赖关系

```scala
// class OneToOneDependency[T](rdd: RDD[T]) extends NarrowDependency[T](rdd) 窄依赖
scala> rdd2.dependencies
res29: Seq[org.apache.spark.Dependency[_]] = List(org.apache.spark.OneToOneDependency@21a87972)

// class ShuffleDependency[K: ClassTag, V: ClassTag, C: ClassTag] extends Dependency 不是窄依赖就是宽依赖
scala> rdd4.dependencies
res31: Seq[org.apache.spark.Dependency[_]] = List(org.apache.spark.ShuffleDependency@4809035f)
```



### 4.3 窄依赖

```scala
// class OneToOneDependency[T](rdd: RDD[T]) extends NarrowDependency[T](rdd) 窄依赖
```

* 父 RDD 的每个分区最多被一个 RDD 的分区使用

![](D:\MyWork\BigData\img\窄依赖.png)

### 4.4 宽依赖

```scala
// class ShuffleDependency[K: ClassTag, V: ClassTag, C: ClassTag] extends Dependency 不是窄依赖就是宽依赖
```

* 父 RDD 的分区被不止一个子 RDD 的分区依赖, 就是宽依赖.

![](D:\MyWork\BigData\img\宽依赖.png)

## 五、Spark Job 划分（源码）

![](D:\MyWork\BigData\img\spark-job.png)

```
Application : 用户自己开发的应用程序
Job ： 调用一个action算子，就会产生一个Job，一个Application中存在多个Job
Stage ： Spark依赖与宽依赖来划分阶段，所以阶段的数量 = 1 + shuffle的个数
Task ： 一个阶段会计算其中最后一个RDD的分区数量，然后转换为对应Task对象

一个job中的Stage是由一个DAG有向无环图维护，一个Stage结束，下一个Stage才能执行
```

* **源码跟踪**

```scala
// 调用collect()方法，开始执行Application
val wordToCountArray: Array[(String, Int)] = wordToSum.collect()
// 每个Action算子里边都会有runJob()方法，runJob方法会一直循环调用，点runJob一直点下去
  def collect(): Array[T] = withScope {
    val results = sc.runJob(this, (iter: Iterator[T]) => iter.toArray)
    Array.concat(results: _*)
  }
// 直到看到dagScheduler调用runJob，dagScheduler就是有向无环图的调度器，用来调度Stage来执行每个Stage的任务
dagScheduler.runJob(rdd, cleanedFunc, partitions, callSite, resultHandler, localProperties.get)
// 继续点runJob，进去之后就会有submitJob提交job的方法
val waiter = submitJob(rdd, func, partitions, callSite, resultHandler, properties)

// 在submitJob中有下面的方法，调用post方法
eventProcessLoop.post(JobSubmitted(
      jobId, rdd, func2, partitions.toArray, callSite, waiter,
      SerializationUtils.clone(properties)))
// post方法会将提交的job放到一个eventQueue事件队列中，等待执行
  def post(event: E): Unit = {
    eventQueue.put(event)
  }
// 点进eventQueue，里边有run方法
    override def run(): Unit = {
      try {
        while (!stopped.get) {
          // 从队列中将事件取出
          val event = eventQueue.take()
          try {
            // 接收取到的事件
            onReceive(event)
          } catch {
            case NonFatal(e) =>
              try {
                onError(e)
              } catch {
                case NonFatal(e) => logError("Unexpected error in " + name, e)
              }
          }
        }
      }
   
  /**
   * The main event loop of the DAG scheduler.
   		onReceive方法将事件传递给doOnReceive处理
   */
  override def onReceive(event: DAGSchedulerEvent): Unit = {
    val timerContext = timer.time()
    try {
      doOnReceive(event)
    } finally {
      timerContext.stop()
    }
  }
   // doOnReceive使用模式匹配，匹配到哪个就执行哪个的job处理程序handleJobSubmitted
   private def doOnReceive(event: DAGSchedulerEvent): Unit = event match {
    case JobSubmitted(jobId, rdd, func, partitions, callSite, listener, properties) =>
      dagScheduler.handleJobSubmitted(jobId, rdd, func, partitions, callSite, listener, properties)

    case MapStageSubmitted(jobId, dependency, callSite, listener, properties) =>
      dagScheduler.handleMapStageSubmitted(jobId, dependency, callSite, listener, properties)
       。。。。。。
//================================handleJobSubmitted==========================================
 /*
 		下边这部分代码是根据提交的job进行阶段的划分
 */
       
 // 在handleJobSubmitted中开始对job进行stage的切分
// 首先不管job中有没有shuffle，都先创建一个ResultStage，这是所有job中必有的阶段       
 var finalStage: ResultStage = null
 finalStage = createResultStage(finalRDD, func, partitions, jobId, callSite)
// 在createResultStage中会先判断有没有上级阶段       
val parents = getOrCreateParentStages(rdd, jobId)
//================================createResultStage==========================================    
// 在getOrCreateParentStages会获取最后一个RDD的shuffle依赖，也就是最后一个RDD和它前面的RDD之间有没有shuffle
  private def getOrCreateParentStages(rdd: RDD[_], firstJobId: Int): List[Stage] = {
    // 如果有shuffle会将shuffle依赖返回，进入map
    getShuffleDependencies(rdd).map { shuffleDep =>
      // 获取或创建ShuffleMapStage
      getOrCreateShuffleMapStage(shuffleDep, firstJobId)
    }.toList
  }       
// 在getOrCreateShuffleMapStage中创建ShuffleMapStage
createShuffleMapStage(dep, firstJobId) 
// 创建好ShuffleMapStage之后开始 new ResultStage()
// 在创建ResultStage时，将parents作为参数传入
// 所以 ResultStage和ShuffleMapStage可以理解为包含的关系      
val stage = new ResultStage(id, rdd, func, partitions, parents, jobId, callSite)         
//=====================================createResultStage======================================
/*
		阶段划分完成之后，进行阶段的提交
*/
// 在 handleJobSubmitted 函数的最后进行提交stage
// 可能一个job有很多stage，但是只提交最后一个，因为最后一个包含里边所有阶段
// 最后一个阶段实际上就是上图中的ResultStage       
 submitStage(finalStage)
//=======================================handleJobSubmitted======================================

       
//=======================================submitStage======================================
// 在submitStage中会先判断有没有上一个阶段
val missing = getMissingParentStages(stage).sortBy(_.id) 
       // 如果没有上一级阶段，则提交当前阶段
       if (missing.isEmpty) {
           logInfo("Submitting " + stage + " (" + stage.rdd + "), which has no missing parents")
           // 知道没有上一级阶段，执行下面的提交代码
           submitMissingTasks(stage, jobId.get)
       } else {
           // 否则遍历missing(所有阶段的集合)，提交所有阶段
           for (parent <- missing) {
               // 迭代
               submitStage(parent)
           }
//=======================================submitStage====================================== 

// 在submitMissingTasks中首先会做一个模式匹配，确认提交的是哪种阶段           
//=======================================submitMissingTasks======================================
/*
		根据阶段，划分任务
*/
    val tasks: Seq[Task[_]] = try {
      stage match {
        case stage: ShuffleMapStage =>
          // 如果是ShuffleMapStage，执行partitionsToCompute计算分区
          // 这里会遍历最后ShuffleMapStage的最后一个RDD的所有分区，有几个分区就创建几个Task
          partitionsToCompute.map { id =>
            val locs = taskIdToLocations(id)
            val part = stage.rdd.partitions(id)
            // 遍历分区，创建对应的Task
            new ShuffleMapTask(stage.id, stage.latestInfo.attemptId,
              taskBinary, part, locs, stage.latestInfo.taskMetrics, properties, Option(jobId),
              Option(sc.applicationId), sc.applicationAttemptId)
          }

        case stage: ResultStage =>
          partitionsToCompute.map { id =>
            val p: Int = stage.partitions(id)
            val part = stage.rdd.partitions(p)
            val locs = taskIdToLocations(id)
            new ResultTask(stage.id, stage.latestInfo.attemptId,
              taskBinary, part, locs, id, properties, stage.latestInfo.taskMetrics,
              Option(jobId), Option(sc.applicationId), sc.applicationAttemptId)
          }
      }
    } 
  // 最后由任务调度器进行任务的提交         
  taskScheduler.submitTasks
//=======================================submitMissingTasks======================================           
```



## 六、 RDD的持久化和设置检查点

### 6.1 RDD数据的持久化

```scala
        val fileRDD = sc.makeRDD(List(1,2,3,4))
        
        val mapRDD = fileRDD.map(num=>{
            println("xxxxx")
            (num,1)
        })
        // TODO 数据持久化
        // cache操作会增加血缘关系，不改变原有的血缘关系
        println(mapRDD.toDebugString)
        println("*******************")
		// 持久化到内存
        mapRDD.cache()
        mapRDD.collect()
        println(mapRDD.toDebugString)
        mapRDD.collect()
```

```scala
def cache(): this.type = persist()
=> def persist(): this.type = persist(StorageLevel.MEMORY_ONLY)
// 持久化的级别
=> object StorageLevel：
      val NONE = new StorageLevel(false, false, false, false)
      val DISK_ONLY = new StorageLevel(true, false, false, false)
      val DISK_ONLY_2 = new StorageLevel(true, false, false, false, 2)
      val MEMORY_ONLY = new StorageLevel(false, true, false, true)
      val MEMORY_ONLY_2 = new StorageLevel(false, true, false, true, 2)
      val MEMORY_ONLY_SER = new StorageLevel(false, true, false, false)
      val MEMORY_ONLY_SER_2 = new StorageLevel(false, true, false, false, 2)
      val MEMORY_AND_DISK = new StorageLevel(true, true, false, true)
      val MEMORY_AND_DISK_2 = new StorageLevel(true, true, false, true, 2)
      val MEMORY_AND_DISK_SER = new StorageLevel(true, true, false, false)
      val MEMORY_AND_DISK_SER_2 = new StorageLevel(true, true, false, false, 2)
      val OFF_HEAP = new StorageLevel(true, true, true, false, 1)

```

```scala
有一点需要说明的是, 即使我们不手动设置持久化, Spark 也会自动的对一些 shuffle 操作的中间数据做持久化操作(比如: reduceByKey)
```

### 6.2 检查点

```scala
        // TODO 设定检查点路径
        sc.setCheckpointDir("cp")
        val fileRDD = sc.makeRDD(List(1,2),2)
        
        val mapRDD = fileRDD.map(num=>{
            //println("aaaaaaa")
            (num,1)
        })
        // TODO 检查点，可以将计算结果保存到检查点中长时间保存
        // Checkpoint directory has not been set in the SparkContext
        // 检查点操作一般会重头再执行一遍完整的流程，所以会和cache联合使用
        // cache方法和checkpoint方法没有关联性，可以随意放置
        // 检查点会切断血缘关系
        // 检查点路径一般设定为分布式存储中 ： HDFS
        println(mapRDD.toDebugString)
        mapRDD.checkpoint()
        //mapRDD.cache()
        mapRDD.collect()
        println("*********************")
        println(mapRDD.toDebugString)
        mapRDD.collect()
```



## 七、key-value类型RDD的数据分区器

```
对于只存储 value的 RDD, 不需要分区器.
只有存储Key-Value类型的才会需要分区器.
Spark 目前支持 Hash 分区和 Range 分区，用户也可以自定义分区.
Hash 分区为当前的默认分区，Spark 中分区器直接决定了 RDD 中分区的个数、RDD 中每条数据经过 Shuffle 过程后属于哪个分区和 Reduce 的个数.
```

### 7.1 HashPartitioner

```
分区的原理：
	* 对于给定的key，计算其hashCode，并除以分区的个数取余，如果余数小于 0，则用余数+分区的个数（否则加0），最后返回的值就是这个key所属的分区ID。
	
分区弊端： 
	* 可能导致每个分区中数据量的不均匀，极端情况下会导致某些分区拥有 RDD 的全部数据。比如我们前面的例子就是一个极端, 他们都进入了 0 分区.
```

### 7.2 RangePartitioner 

```
分区的原理：
	* 将一定范围内的数映射到某一个分区内，尽量保证每个分区中数据量的均匀，而且分区与分区之间是有序的，一个分区中的元素肯定都是比另一个分区内的元素小或者大，但是分区内的元素是不能保证顺序的。简单的说就是将一定范围内的数映射到某一个分区内。
```

### 7.3 自定义分区器 => 1.3.1 算子 - 转换 - partitionBy

## 八、 文件中数据的读取和保存

###  8.1 读取Json文件

```scala
{"username": "zhangsan", "age": 20}
{"username": "lis", "age": 20}
{"username": "wangwu", "age": 20}
```

```scala
/*
	读取json文件是按照hadoop的读取规则：按行读取
		* json文件中必须每一行都表示一个json对象，否则spark不能解析
*/
val jsonRDD: RDD[String] = sc.textFile("input/user.json")
// 导入 scala 提供的可以解析 json 的工具类
import scala.util.parsing.json.JSON
// 使用 map 来解析 Json, 需要传入 JSON.parseFull
// 解析到的结果其实就是 Option 组成的数组, Option 存储的就是 Map 对象
val jsonRDD1: RDD[Option[Any]] = jsonRDD.map(JSON.parseFull)

jsonRDD1.collect().foreach(println)
```



### 8.2 从MySQL中读写文件

```scala
        // TODO 从Mysql中读取数据
		//定义连接mysql的参数
        val driver = "com.mysql.jdbc.Driver"
        val url = "jdbc:mysql://linux1:3306/rdd"
        val userName = "root"
        val passWd = "000000"
        val rdd = new JdbcRDD(
            sc,
            // 获取驱动类和连接对象
            ()=>{
                Class.forName(driver)
                DriverManager.getConnection(url, userName, passWd)
            },
            // 写sql，必须要有占位符 ？
            //"select * from user",   // error
            // 因为是分布式的，所以sql需要发到不同的Executor执行
            // 根据上下边界和分区数确定每个Executor查询的范围
            "select * from user where id >= ? and id <= ?",
            1, // lowerBound 下边界
            3, // upperBound 上边界
            3, // numPartitions 分区数
            result => (result.getInt(1), result.getString(2))
        )
        rdd.collect.foreach(println)
```

```scala
		// TODO 从Mysql中读取数据
        val driver = "com.mysql.jdbc.Driver"
        val url = "jdbc:mysql://linux1:3306/rdd"
        val userName = "root"
        val passWd = "000000"
        
        val dataRDD: RDD[(Int, String, Int)] = sc.makeRDD( List( (1, "zhangsan", 30), (2, "lisi", 40), (3, "wangwu", 50) ) )
        /*
        这种方式是可以实现写数据的，但是每条数据的写入都需要重新获取连接，性能不好
        dataRDD.foreach{
            case (id, name, age) => {
                Class.forName(driver)
                val connection = DriverManager.getConnection(url,userName,passWd)
                val pstat = connection.prepareStatement("insert into user(id, name, age) values (?, ?, ?)")
    
                pstat.setInt(1, id)
                pstat.setString(2, name)
                pstat.setInt(3, age)
                
                pstat.executeUpdate()
                
                pstat.close()
                connection.close()
            }
        }
        
         */
        
/*
	foreachPartition():
		* 每个分区单独获取连接，只需要获取分区数量的连接；
		* 插入的逻辑在分区内单独执行
*/
        dataRDD.foreachPartition(
            datas => {
                Class.forName(driver)
                val connection = DriverManager.getConnection(url,userName,passWd)
                val pstat = connection.prepareStatement("insert into user(id, name, age) values (?, ?, ?)")
    
                datas.foreach{
                    case (id, name, age) => {
                        pstat.setInt(1, id)
                        pstat.setString(2, name)
                        pstat.setInt(3, age)
    
                        pstat.executeUpdate()
                    }
                }
                
                pstat.close()
                connection.close()
            }
        )
        
```



### 8.3 从Hbase读写文件

```scala
        val hbaseConf: Configuration = HBaseConfiguration.create()
		// 配置zookeeper节点信息
        hbaseConf.set("hbase.zookeeper.quorum", "linux1,linux2,linux3")
		// 配置需要读取的表
        hbaseConf.set(TableInputFormat.INPUT_TABLE, "student")
        
        // TODO 从Hbase中读取数据
		// newAPIHadoopRDD
        val rdd: RDD[(ImmutableBytesWritable, Result)] = sc.newAPIHadoopRDD(
            hbaseConf,
            classOf[TableInputFormat],
            classOf[ImmutableBytesWritable], // rowkey类型
            classOf[Result])
    
        val rdd2: RDD[String] = rdd.map {
            case (_, result) => Bytes.toString(result.getRow)
        }
        rdd2.collect.foreach(println)
```



```scala
        // hbase配置
        val hbaseConf: Configuration = HBaseConfiguration.create()
        hbaseConf.set("hbase.zookeeper.quorum", "linux1,linux2,linux3")
        hbaseConf.set(TableOutputFormat.OUTPUT_TABLE, "student")
        
        // job配置
        val job = Job.getInstance(hbaseConf)
        job.setOutputFormatClass(classOf[TableOutputFormat[ImmutableBytesWritable]])
        job.setOutputKeyClass(classOf[ImmutableBytesWritable])
        job.setOutputValueClass(classOf[Put])
        
        // TODO 向Hbase中写入数据
        // 数据的配置
        val rdd = sc.makeRDD(List(("2001","zhangsan"),("2002", "lisi"), ("2003", "wangwu")))
        
        // Put
        val putRDD: RDD[(ImmutableBytesWritable, Put)] = rdd.map {
            case (rowkey, name) => {
                val put = new Put(Bytes.toBytes(rowkey))
                put.addColumn(Bytes.toBytes("info"), Bytes.toBytes("name"), Bytes.toBytes(name))
                ( new ImmutableBytesWritable(),  put)
            }
        }
    
        putRDD.saveAsNewAPIHadoopDataset(job.getConfiguration)
```



## 九、 RDD编程进阶（三大数据结构）

```
Spark 三大数据结构
    RDD:弹性分布式数据集
    广播变量：分布式共享只读变量
    累加器：分布式共享只写变量
```

### 9.1 累加器

* **累加器实现聚合可以不用shuffle，一般用累加器实现数据的聚合**

#### 9.1.1 累加器实现聚合案例

```scala
    val rdd = sc.makeRDD(List(("a",1),("a",2),("a",3),("a",4)),2)

    // 使用reduceByKey聚合时，有shuffle的过程，可以使用累加器避免shuffle，提高效率
    // rdd.reduceByKey(_+_).collect().foreach(println)

    // 使用累加器实现数据聚合功能
    // Spark自带常用累加器
    // 声明累加器
    val sum: LongAccumulator = sc.longAccumulator("sum")

    rdd.foreach{
      case ( a, count ) => {
        // 使用累加器
        sum.add(count)
      }
    }

    // 获取累加器的值
    println(sum.value)
```

#### 9.1.2 累加器原理

![](D:\MyWork\BigData\img\累加器原理.png)

```
结合上面案例和图片理解累加器原理：
	* 上面foreach里边的代码是要在Executor中执行，而且代码中用到了累加器sum
	* 所以，Executor中的Task用到累加器，Executor向Driver请求accu，于是将accu=0向Executor拷贝一份
	* 假设在上面的Executor执行完成时，accu=3，此时需要将最新的accu返回到Driver，并与Driver中的accu=0合并，生成最新的accu=3
	* 此时下面的Executor同样用到累加器，和上面步骤一样，将最初的accu=0（一定是Driver中最初的accu，而不是前面的Executor返回的）拷贝到Executor，并将累加之后的accu返回，最后与Driver中的accu=3合并，生成最新的accu=10
```

#### 9.1.3 自定义累加器

```scala
object Spark31_RDD_Accu1 {

  def main(args: Array[String]): Unit = {


    // 创建配置文件，并创建SparkContext()对象
    val conf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("Spark31_RDD_Accu1")
    val sc: SparkContext = new SparkContext(conf)

    	/*
            聚合list，统计以H开头的单词及次数
        */
    val rdd = sc.makeRDD(List("Hello","Hello","Hello","Hello","Hbase","Hbase","Hbase","Scala","Spark"))

    // 创建累加器
    val accu = new MyAccumulator()
    // 注册累加器
    sc.register(accu, "MyAccumulator")

    rdd.foreach(
      str => {
        accu.add(str)
      }
    )

    println(accu.value)

    sc.stop()
  }
}

// 自定义累加器
// 1. 继承AccumulatorV2, 声明泛型
// 2. 实现抽象方法
class MyAccumulator extends AccumulatorV2[String, mutable.Map[String, Int]] {

  private var map = mutable.Map[String, Int]()

  // 累加器是否为初始状态

  // copyAndReset must return a zero value copy
  override def isZero: Boolean = {
    map.isEmpty
  }

  // 复制累加器
  override def copy(): AccumulatorV2[String, mutable.Map[String, Int]] = {
    new MyAccumulator
  }

  // 重置累加器
  override def reset(): Unit = {
    map.clear()
  }

  // 向累加器中输入数据(In)
  override def add(v: String): Unit = {
    if ( v.startsWith("H") ) {
      map(v) = map.getOrElse(v, 0) + 1
      //map.update(v, map.getOrElse(v, 0) + 1)
    }
  }

  // 合并累加器
  override def merge(other: AccumulatorV2[String, mutable.Map[String, Int]]): Unit = {

    val map1 = map // (a, 1)
    val map2 = other.value // (a,2) => (a,3)

    map = map1.foldLeft(map2)(
      ( innerMap, kv ) => {
        innerMap(kv._1) = innerMap.getOrElse(kv._1, 0) + kv._2
        innerMap
      }
    )
  }

  // 累加器的值（Out）
  override def value: mutable.Map[String, Int] = {
    map
  }
}

```



### 9.2 广播变量

#### 9.2.1 广播变量案例

```scala
	   // 使用广播变量完成类似RDD join的操作
		val rdd1 = sc.makeRDD(List((1,1),(2,2)))
        val list = List((1,3),(2,4))
        // 广播变量
        val list1: Broadcast[List[(Int, Int)]] = sc.broadcast(list)
        //val rdd3: RDD[(Int, (Int, Int))] = rdd1.join(rdd2)
        // (1, (1,3)), (2, (2,4))

		// 由于map算子在Executor中执行，且用到了Driver中的list，
		// 如果不用广播变量，会将list随着task发送到Executor，这样会导致一个Executor中有很多重复的数据list
        val mapRDD: RDD[(Int, (Int, Int))] = rdd1.map {
            case (k, v) => {
                var v1: Int = 0
            	// 遍历广播变量
                for ((k2, v2) <- list1.value) {
                    if (k == k2) {
                        v1 = v2
                    }
                }
            
                (k, (v, v1))
            }
        }
        mapRDD.collect().foreach(println)
```



#### 9.2.2 广播变量原理

![](D:\MyWork\BigData\img\广播变量原理.png)

```
根据上边案例和图片理解广播变量原理：
	* 首先明确Driver中的list是随着task发送给Executor的，也就是有几个task就有几份list
	* 当一个Executor并行度较高，同时执行多个task时就会有多个list冗余，占用内存
	* 所以可以将list只在Executor的内存中存一份，供所以task共享，而不是每个task中存一份
	* list只有在task用到的时候才会传输给Executor，没用到的时候是不传的
```



## 十、WordCount案例

### WordCount - 1 

```scala
/*
	使用groupBy实现
*/
object Spark10_RDD_WordCount {
    def main(args: Array[String]): Unit = {

        val conf = new SparkConf().setMaster("local[*]").setAppName("Spark10_RDD_WordCount")
        val sc: SparkContext = new SparkContext(conf)

        // WordCount - 1
        
        val strList = List("Hello Scala", "Hello Spark", "Hello World")
        val strRDD: RDD[String] = sc.makeRDD(strList)
        
        // TODO 1. 将字符串拆分成一个一个的单词
        val wordRDD: RDD[String] = strRDD.flatMap(str=>str.split(" "))
        
        // TODO 2. 将单词结构进行转换 ： word => (word, 1)
        val wordToOneRDD: RDD[(String, Int)] = wordRDD.map(word=>(word, 1))
        
        // TODO 3. 将转换结构后的数据按照单词进行分组
        // (Hello, 1), (Hello,1)
        // (Hello, 1)
        val groupRDD: RDD[(String, Iterable[(String, Int)])] = wordToOneRDD.groupBy(t=>t._1)
        
        // TODO 4. 将分组后的数据进行结构的转换
        val wordToSumRDD: RDD[(String, Int)] = groupRDD.map {
            case (word, list) => {
                // 因为分组返回的元组(Hello, 1)中，第二个都是1，所以返回的集合的大小即为这个单词的个数
                (word, list.size)
            }
        }
        wordToSumRDD.collect().foreach(println)
        sc.stop()
    }
}
```

### WordCount - 2 & 3

```scala
/*
	使用reduceByKey & groupByKey实现
*/
    val datas = List( ("a", 1), ("b", 2), ("c", 3),("a", 4) )

    val dataRDD = sc.makeRDD(datas,1)

    // WordCount - 2
    // reduceByKey将相同key的value进行聚合
//    val reduceRDD: RDD[(String, Int)] = dataRDD.reduceByKey(_+_)
//
//    println(reduceRDD.collect().mkString(","))

    
    // WordCount - 3
    // groupByKey只按照key进行分组，不聚合
    val groupByRDD: RDD[(String, Iterable[Int])] = dataRDD.groupByKey()

    val sumRDD: RDD[(String, Int)] = groupByRDD.map {
      case (key, list) => {
        (key, list.sum)
      }
    }

    println(sumRDD.collect().mkString(","))
```

### WordCount - 4 & 5

```scala
/*
	使用aggregateByKey & foldByKey实现
*/
val datas = List( ("a", 1), ("b", 2), ("b", 3), ("c", 3),("a", 4),("a", 2) )
val dataRDD = sc.makeRDD(datas,2)
// TODO wordcount -4
//    val wordToCountRDD: RDD[(String, Int)] = dataRDD.aggregateByKey(0)(_+_, _+_)
/*
      foldByKey与aggregateByKey的区别：
          * 当aggregateByKey的分区内和分区间计算规则相同时，可以用foldByKey
 */
val wordToCountRDD: RDD[(String, Int)] = dataRDD.foldByKey(0)(_+_)
println(wordToCountRDD.collect().mkString(","))
```

### WordCount - 6

```scala
/*
	使用combineByKey实现
*/
    val datas = List( ("a", 100), ("b", 200), ("b", 300), ("c", 300),("a", 400),("a", 200) )
    val dataRDD : RDD[(String,Int)] = sc.makeRDD(datas,2)
    // TODO wordcount - 5
    val combineByKeyRDD: RDD[(String, Int)] = dataRDD.combineByKey(
      num => num,
      (v1: Int, v2: Int) => v1 + v2,
      (v1: Int, v2: Int) => v1 + v2
    )
    combineByKeyRDD.collect().foreach(println)c
```

### WordCount -7 & 8

```scala
/*
	使用countByKey & countByValue实现
*/
	// 算子 - 行动 - countByKey
    // WordCount - 7
    val rdd = sc.makeRDD(List("Hello", "Hello", "scala", "scala"),2)

    val countByKeyRDD: collection.Map[String, Long] = rdd.map((_, 1)).countByKey()

    println(countByKeyRDD)

    // 算子 - 行动 - countByValue
    /*
        countByValue 的value不是key-value中的value，是指集合中的每一个元素 
    */
    // WordCount - 8
    println(rdd.countByValue())
```

### WordCount - 9 & 10

```scala
// 只用countByKey实现如下rdd的wordcount
val rdd = sc.makeRDD(List(("a",1), ("a",2), ("a",3)))
// 思路：
// ("a",1)=>("a",1)
// ("a",2)=>("a",2),("a",2)
// ("a",3)=>("a",3)，("a",3)，("a",3)
        val flatMapRDD: RDD[(String, Int)] = rdd.flatMap {
            case (word, num) => {
                val list = new ListBuffer[(String, Int)]()
                for (i <- (1 to num)) {
                    list.append((word, num))
                }
                list
            }
        }
println(flatMapRDD.countByKey())

// 只用 countByValue 实现如下rdd的wordcount
// 思路：
// ("a",1)=>("a",1)
// ("a",2)=>("a",1),("a",1)
// ("a",3)=>("a",1)，("a",1)，("a",1)
        val flatMapRDD: RDD[(String, Int)] = rdd.flatMap {
            case (word, num) => {
                val list = new ListBuffer[(String, Int)]()
                for (i <- (1 to num)) {
                    // 这里的num需要注意
                    list.append((word, 1))
                }
                list
            }
        }
// countByValue的value表示的含义要清楚
println(flatMapRDD.countByValue())
```



## 十一、 Demo

### Demo - 1 : 统计出每一个省份广告被点击次数的 TOP3

* 思路

![](D:\MyWork\BigData\img\demo1-top3.png)

```scala
object Spark26_RDD_Demo {
    def main(args: Array[String]): Unit = {
    
        val conf = new SparkConf().setMaster("local[*]").setAppName("Spark26_RDD_Demo")
        val sc: SparkContext = new SparkContext(conf)
    
        // TODO 统计出每一个省份广告被点击次数的 TOP3
        //    时间戳 省份  城市   用户 广告
        //    1516609143867 6 7 64 16
        //    1516609143869 9 4 75 18
        
        // TODO 1. 读取日志文件，获取原始数据
        val dataRDD: RDD[String] = sc.textFile("input/agent.log")
        
        // TODO 2. 将原始数据进行结构的转换：string => ( prv-adv, 1 )
        val prvAndAdvToOneRDD: RDD[(String, Int)] = dataRDD.map(
            line => {
                val datas: Array[String] = line.split(" ")
                (datas(1) + "-" + datas(4), 1)
            }
        )
        
        // TODO 3. 将转换结构后的数据进行聚合统计 ( prv-adv, 1 ) => ( prv-adv, sum )
        val prvAndAdvToSumRDD: RDD[(String, Int)] = prvAndAdvToOneRDD.reduceByKey(_+_)
        
        // TODO 4. 将统计的结果进行结构的转换：( prv-adv, sum ) => ( prv, (adv, sum) )
//        prvAndAdvToSumRDD.map(t => {
//            val ks = t._1.split("-")
//            (ks(0), (ks(1), t._2))
//        })
        val prvToAdvAndSumRDD: RDD[(String, (String, Int))] = prvAndAdvToSumRDD.map {
            case (prvAndAdv, sum) => {
                val ks = prvAndAdv.split("-")
                (ks(0), (ks(1), sum))
            }
        }
        
        // TODO 5. 根据省份对数据进行分组：( prv, (adv, sum) ) => (prv, Iterator[ (adv, sum) ])
        val groupRDD: RDD[(String, Iterable[(String, Int)])] = prvToAdvAndSumRDD.groupByKey()
        
        // TODO 6. 对相同省份中的广告进行排序（降序），取前三名
        val mapValuesRDD: RDD[(String, List[(String, Int)])] = groupRDD.mapValues(
            datas => {
                datas.toList.sortWith(
                    (left, right) => {
                        left._2 > right._2
                    }
                ).take(3)
            }
        )
        
        // TODO 7. 将结果打印到控制台
        mapValuesRDD.collect().foreach(println)
    
        sc.stop()
    }
}
```


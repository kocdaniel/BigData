# 运算符

## ==	equals	eq

### Java

```
==比较的是对象的内存地址
equals默认也是比较的地址，如果需要比较值的话，需要对equals进行重写
```

### Scala

```
==的效果和equals效果相同
eq近似于java中的==
```

## ++	--

* 在scala中没有++ 和 --

# 流程控制

## 分支控制if-else

* Scala的分支是有返回值的，返回的是满足条件分支的最后一行代码
* 如果每一个分支返回类型都一致，那么接收的结果就是该种类型

```scala
println("请输入您的年龄")
var age: Int = StdIn.readInt()
var res: String = if (age < 18) {
    "童年"
} else if (age >= 18 && age <= 40) {
    "青壮年"
} else {
    "暮年"
}
println(res)
```

* 如果分支返回的类型不一致，那么是各分支类型的上层父类

```scala
println("请输入您的年龄")
var age: Any = StdIn.readInt()
var res = if (age < 18) {
    "童年"
} else if (age >= 18 && age <= 40) {
    "青壮年"
} else {
    100
}
println(res)
```

* 在scala中没有三元运算符，但是可以通过分支实现类似效果；
* **if分支中，如果分支体中只有一行代码，那么大括号可以省略**
* 如果省略大括号，那么if相关关键字只对最近一行代码起作用
* 条件表达式?值1:值2

```scala
# java
int result = flag ? 1 : 0
# scala
var age = 18
if(age < 20) "少年" else "成年"
```

## For循环控制

1. 范围数据循环TO(前后闭合) 循环打印三次数据

```scala
for (i <- 1 to 3){
	println(i)
}
```

2. 范围数据循环until (前闭合后开)

```scala
for (i <- 1 until 3){
	println(i)
}
```

3.

* java：
  * continue：跳出本次循环，继续下一次循环
  * break：跳出循环
* scala
  * 没有continue和break
  * Scala中使用breakable控制结构来实现break和continue功能。

**案例1**：采用异常的方式实现break

```scala
try {
        for (elem <- 1 to 10) {
            println(elem)
            if (elem == 5) throw new RuntimeException
        }
    }catch {
        case e =>
    }
    println("正常结束循环")

```

**案例2**：采用Scala自带的函数，退出循环

```scala
import scala.util.control.Breaks

def main(args: Array[String]): Unit = {

    Breaks.breakable(
        for (elem <- 1 to 10) {
            println(elem)
            if (elem == 5) 
            Breaks.break()
        }
    )

    println("正常结束循环")
}

```

**案例3**：对break进行省略

```
import scala.util.control.Breaks._

object TestBreak {

    def main(args: Array[String]): Unit = {
    
        breakable {
            for (elem <- 1 to 10) {
                println(elem)
                if (elem == 5) break
            }
        }
    
        println("正常结束循环")
    }
}

```

**案例4**：循环遍历10以内的所有数据，奇数打印，偶数跳过（**continue**）

```scala
object TestBreak {

    def main(args: Array[String]): Unit = {

        for (elem <- 1 to 10) {
            if (elem % 2 == 1) {
                println(elem)
            } else {
                println("continue")
            }
        }
    }
}

```



4. 循环守卫  在循环的过程中，可以进行判断（**类似于continue**）

```scala
for(i <- 1 to 3 if i != 2){
	println(i)
}
```

5. 循环步长：循环遍历1~10中所有的奇数

```scala
for (i <- 1 to 10 by 2){
	println(i)
}
```

6. 循环嵌套

```scala
for (i <- 1 to 3;j <- 1 to 5){
	println("i=" + i + ",j=" + j)
}
```

7. 循环返回值 yield

```scala
val res = for (i <- 1 to 10) yield i*2
println(res)
```

8. 倒序打印

```scala
for (i <- 1 to 5 reverse){
	println(i)
}
```

# 函数式编程

## 至简原则

```scala
/**
  * Scala至简原则：能省就省
  * （1）return可以省略，Scala会使用函数体的最后一行代码作为返回值
  * （2）如果函数体只有一行代码，可以省略花括号
  * （3）返回值类型如果能够推断出来，那么可以省略（:和返回值类型一起省略）
  * （4）如果有return，则不能省略返回值类型，必须指定
  * （5）如果函数明确声明unit，那么即使函数体中使用return关键字也不起作用
  * （6）Scala如果期望是无返回值类型，可以省略等号
  * （7）如果函数的参数列表中没有参数，没有省略小括号,在调用函数的时候参数列表括号可加可不加
  * （8）如果函数的参数列表中没有参数，那么参数列表的小括号可以省略,调用函数的时候也不能加()
  * （9）如果不关心名称，只关心逻辑处理，那么函数名（def）可以省略
  */
object Scala06_TestFunction_middle {
  def main(args: Array[String]): Unit = {
    //函数的标准写法
    def f1(s:String): String ={
      return "hello" + s
    }
    //return可以省略，Scala会使用函数体的最后一行代码作为返回值
    def f2(s:String): String ={
      "hello " + s
    }
    //如果函数体中只有一行代码，花括号可以省略
    def f3(s:String): String = "hello " + s


    //如果函数的返回值类型可以推导出来，那么返回值类型的声明可以省略（:String）
    def f4(s:String) = "hello " + s

    //如果有return关键字，那么返回值类型不能省
    /*def f5(s:String) ={
      return "hello" + s
    }*/
    //如果方法的返回值类型声明为Unit，就算在函数体中有return关键字，也返回的Unit
    def f6(s:String): Unit ={
      return "hello" + s
    }

    //如果函数期望返回值为Unit，那么可以省略等号，这样的函数叫做过程
    def f7(s:String){
      return "hello" + s
    }
    //println(f7("atguigu"))

    //如果函数的参数列表中没有参数，那么参数列表的小括号可以省略
    // 调用函数的时候也不能加()
    def f8 = println("hello")
    //f8
    //f8()  报错

    //如果函数的参数列表中没有参数，没有省略小括号
    //在调用函数的时候参数列表括号可加可不加
    def f9() = println("hello")
    //f9
    //f9()

    //如果不关心函数的名称，那么函数名可以省略掉

   /* def f11(s:String):Unit={
      println(s)
    }*/

    //(f:String=>Unit)  代表当前f10函数的形参
    //形参的名字f
    //形参的类型函数（输入=>函数=>输出）
    // String=>Unit　表示函数的参数为String，没有返回值
    def f10(f:String =>Unit): Unit ={
      f("zhangjunyi")
    }

    //f10(f11)
    //如果不关心函数的名称，那么函数名可以省略掉
    //f10((s:String)=>{println(s)})
    //在匿名函数中，如果函数体只有一行代码，大括号省
    //f10((s:String)=>println(s))
    //如果能够推断出参数类型，那么参数类型可以省
    //f10((s)=>println(s))
    //如果参数在函数体中，只被使用了一次，那么参数可以省，在函数体中用_替代
    f10(println(_))
  }
```

## 高阶函数

```scala
/* 高阶函数
    -在Scala中，函数作为一等公民
    *函数可以作为值赋值给变量
    *函数可以作为返回值
    *函数可以作为参数传递
*/
```



```scala
//函数可以作为值赋值给变量
    def foo(): Int ={
      println("----foo----")
      1
    }
    //将函数的执行结果赋值给n
    //var n = foo()
    //println(n)
    //var n = foo
    //println(n)

    //将函数作为整体传递给n
    var n = foo _
    println(n)
    n()
```

```scala
//函数可以作为返回值
    def f1()={
      def f2()={
        def f3()={
          println("f3被调用了")
        }
        f3 _
      }
      f2 _
    }

    f1()()()
```

```scala
// 函数可以作为参数传递

// 传递的函数只有一个参数
    def f1(a:Int): Int ={
      a + 10
    }

    //println(f1(1))

    def f2(f:Int=>Int): Int ={
      f(8)
    }
    //简化
    //println(f2((a:Int)=>{a + 20}))
    //println(f2((a:Int)=>a + 20))
    //println(f2((a)=>a + 20))
    //println(f2(_ + 20))


// 传递的函数有两个参数
    def f3(a:Int,b:Int): Int ={
      return a + b
    }

    def f4(f:(Int,Int)=>Int): Int ={
      f(10 ,20)
    }

    //println(f4(f3))
    //println(f4((a:Int,b:Int)=>{a + b}))
    //省略花括号
    //println(f4((a:Int,b:Int)=>a + b))
    //省略参数类型
    //println(f4((a,b)=>a + b))
    //省略参数  如果在函数体中参数只用一次 ，省略参数，用_代替
    println(f4(_ + _))
```


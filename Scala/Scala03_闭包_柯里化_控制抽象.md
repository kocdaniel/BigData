# 函数式编程

## 闭包

### 定义

为了让当前函数能够访问到外部函数的局部变量，改变了外部局部变量的生命周期，与当前函数形成了一个闭合的环境，简称闭包。

### 案例

```scala
// 实际上就是函数的嵌套，m2可以访问到m1的变量a
// 
def m1(a:Int)={
    def m2()={
        println(a)
    }
    // 这里m1执行完毕后，弹栈，直接返回m2函数，而m2并没有执行，也就是没有压栈
    // 也就是在此处，变量a并没有被释放，而是包含在m2内部，形成了闭合的效果
    m2 _  
}

m1(10)()
```



## 柯里化

### 定义

Scala为了简化闭包函数的生命及调用，使用柯里化，其实就是将复杂的参数逻辑变得简单化,函数柯里化一定存在闭包

```scala
def m1()(): Unit ={
	println("aaaa")
}

m1()()
```



## 递归

### 案例

```scala
/**
  * 求阶乘
  * 递归
  *   -方法调用方法本身
  *   -找规律
  *   -收敛条件
  */

def jc(n:Int): Int ={
    //在Scala语言中，if分支也有返回值，如果不加return，最后一行表示if的返回值
    //加return之后，才表示的是方法的返回值
    if(n == 1){
      return 1  // 这里的return不能省略，否则会死循环
    }
    n * jc(n-1)
  }
```



## 控制抽象

### 值调用：把计算后的值传递过去

```scala
    def main(args: Array[String]): Unit = {

        def f = ()=>{
            println("f...")
            10
        }

        // 输出结果：
        // f...
        // 10
        // 10
        foo(f())  // 将计算后的值传递过去
    }

    def foo(a: Int):Unit = { // foo(a: Int)
        println(a)
        println(a)
    }

```



### 名调用：把代码传递过去

```scala
def main(args: Array[String]): Unit = {

        def f = ()=>{
            println("f...")
            10
        }

        foo(f()) // 传递的是代码块
    }

	//def foo(a: Int):Unit = {  对比
    def foo(a: =>Int):Unit = {
        println(a)
        println(a)
    }
// 输出结果：
// f...
// 10
// f...
// 10 


```

### 案例实操

```scala
  /**
    * 自定义while函数
    * 这里使用控制抽象，传递的参数一定是代码块，否则会死循环
    * @param condition  循环条件代码块
    * @param op 循环体
    */
  def myWhile(condition: =>Boolean)(op: =>Unit): Unit ={
    //如果满足循环条件执行循环体
    if(condition){
      op
      //再次判断,执行下一次循环
      myWhile(condition)(op)
    }

  }
```


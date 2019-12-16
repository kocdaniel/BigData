## HelloWorld案例

```scala
object HelloScala{
  def main(args: Array[String]):Unit = {
    println("hello scala")
  }
}
```

![](D:\MyWork\BigData\img\scala_helloworld案例.png)

## 变量和常量

### 基本语法

```scala
var 变量名 [: 变量类型] = 初始值		var i:Int = 10
val 常量名 [: 常量类型] = 初始值		val j:Int = 20
// 注意：能用常量的地方不用变量
```

### 案例实操

```
（1）声明变量时，类型可以省略，编译器自动推导，即类型推导
（2）类型确定后，就不能修改，说明Scala是强数据类型语言。
（3）变量声明时，必须要有初始值
（4）在声明/定义一个变量时，可以使用var或者val来修饰，var修饰的变量可改变，val修饰的变量不可改。
（5）var修饰的对象引用可以改变，val修饰的对象则不可改变，但对象的状态/属性（值）却是可以改变的。（比如：自定义对象、数组、集合等等）
```

```scala
object Scala01_TestVar {

  def main(args:Array[String]):Unit = {
    // 声明变量时类型可以省略，类型推导
    var a1 = 10
   // println(a1)

    // 类型确定后就不可修改，强数据类型语言
    var a2 = 10
    // a2 = "10"
    // println(a2)
    // 变量声明时，必须要有初始值
    // var a3

    // var声明变量可以改变， val不可改变
//    a1 = 20
//    println(a1)
    val a4 = 10
    // a4 = 20

    // val修饰的对象不可变，但对象的属性可以改变
    val man:Person = new Person
    man.name = "ls"
  }

}

class Person{
  var name:String = "zs"
}
```

## 标识符的命名规范

### 命名规则

```
Scala中的标识符声明，基本和Java是一致的，但是细节上会有所变化，有以下四种规则：
（1）以字母或者下划线开头，后接字母、数字、下划线
（2）以操作符开头，且只包含操作符（+ - * / # !等）
（3）用反引号`....`包括的任意字符串，即使是Scala关键字（39个）也可以
```

### 案例实操

```scala
object TestName {

    def main(args: Array[String]): Unit = {

        // （1）以字母或者下划线开头，后接字母、数字、下划线
        var hello: String = "" // ok
        var Hello12: String = "" // ok
        var 1hello: String = "" // error 数字不能开头

        var h-b: String = "" // error   不能用-
        var x h: String = "" // error   不能有空格
        var h_4: String = "" // ok
        var _ab: String = "" // ok
        var Int: String = "" // ok 因为在Scala中Int是预定义的字符,不是关键字，但不推荐

        var _: String = "hello" // ok 单独一个下划线不可以作为标识符，因为_被认为是一个方法
        println(_)

        //（2）以操作符开头，且只包含操作符（+ - * / # !等）
        var +*-/#! : String = "" // ok
        var +*-/#!1 : String = "" // error 以操作符开头，必须都是操作符

        //（3）用反引号`....`包括的任意字符串，即使是Scala关键字（39个）也可以
        var if : String = "" // error 不能用关键字
        var `if` : String = "" // ok 用反引号`....`包括的任意字符串,包括关键字
    }
}

```

## 字符串输出

### 基本语法

```
（1）字符串，通过+号连接
（2）printf用法：字符串，通过%传值。
（3）字符串模板（插值字符串）：通过$获取变量值
```

### 案例实操

```scala
object Scala03_TestString {
  def main(args:Array[String]):Unit = {
    // 1. 字符串拼接
    var name:String = "zs"
    var age:Int = 19
//    println(name + " : " + age)

    // 2. printf用法字符串，通过%传值
//    printf("name=%s : age=%d", name, age)
    // 3. 字符串，通过$引用, 引号外边加s，如果需要对变量进行计算后输出，则加{}
//    println(s"name: $name, age: ${age+1}")

    // 4. 多行字符串，在Scala中，利用三个双引号包围多行字符串就可以实现
    // 输入的内容，带有空格、\t之类，导致每一行的开始位置不能整洁对齐。
    // 应用scala的stripMargin方法，在scala中stripMargin默认是“|”作为出来连接符，
    // 在多行换行的行头前面加一个“|”符号即可。
    println(
      """aaaaa
        |aaa
        |a
        |a
        |a
        |aa
        |aaa
      """.stripMargin)
  }
}
```

## 键盘输入

### 基本语法

```scala
StdIn.readLine()、StdIn.readShort()、StdIn.readDouble()等
```

### 案例实操

```scala
object Scala_TestInput {
  def main(args: Array[String]): Unit = {
    // 提示用户输入用户名
    println("请输入用户名：")
    var username: String = StdIn.readLine()
    println("请输入年龄：")
    var age: Int = StdIn.readInt()
    println(s"欢迎${age}岁的${username}来atguigu")
  }
}
```

## 数据类型

### 回顾：Java数据类型

![](D:\MyWork\BigData\img\java数据类型回顾.png)

### scala数据类型

![](D:\MyWork\BigData\img\scala数据类型.png)

## Unit类型、Null类型和Nothing类型（重点）

### 基本说明

| **数据 类型** | **描述**                                                     |
| ------------- | :----------------------------------------------------------- |
| **Unit**      | 表示无值，和其他语言中void等同。用作不返回任何结果的方法的结果类型。Unit只有一个实例值，写成()。 |
| **Null**      | null , Null 类型只有一个实例值null                           |
| **Nothing**   | Nothing类型在Scala的类层级最低端；它是任何其他类型的子类型。   当一个函数，我们确定没有正常的返回值，可以用Nothing来指定返回类型，这样有一个好处，就是我们可以把返回的值（异常）赋给其它的函数或者变量（兼容性） |

### 案例实操

1. Unit类型用来标识过程，也就是没有明确返回值的函数。

```scala
object TestSpecialType {

    def main(args: Array[String]): Unit = {

        def sayOk : Unit = {// unit表示没有返回值，即void
            
        }
        println(sayOk)
    }
}

```

2. Null类只有一个实例对象，Null类似于Java中的**null**引用。**Null可以赋值给任意引用类型（AnyRef），但是不能赋值给值类型（AnyVal）**

```scala
object TestDataType {

    def main(args: Array[String]): Unit = {

        //null可以赋值给任意引用类型（AnyRef），但是不能赋值给值类型（AnyVal）
        var cat = new Cat();
        cat = null	// 正确

        var n1: Int = null // 错误
        println("n1:" + n1)

    }
}

class Cat {

}

```

3. Nothing，可以作为没有正常返回值的方法的返回类型，非常直观的告诉你这个方法不会正常返回，而且由于Nothing是其他任意类型的子类，他还能跟要求返回值的方法兼容。

```scala
object TestSpecialType {

    def main(args: Array[String]): Unit = {

        def test() : Nothing={
            throw new Exception() // 异常，非正常返回值
        }
        test
    }
}

```

## 类型转换

### 数值类型自动转换

当Scala程序在进行赋值或者运算时，**精度小的类型自动转换为精度大的数值类型**，这个就是自动类型转换（隐式转换）。数据类型按精度（容量）大小排序为：

![](D:\MyWork\BigData\img\scala类型转换.png)

#### 基本说明

1. **自动提升原则**：有多种类型的数据混合运算时，系统首先自动将所有数据转换成精度大的那种数据类型，然后再进行计算。
2. 把精度大的数值类型赋值给精度小的数值类型时，就会报错，反之就会进行自动类型转换。
3. （byte，short）和char之间不会相互自动转换。
4. byte，short，char他们三者可以计算，**在计算时首先转换为int类型**

#### 案例实操

```scala
object TestValueTransfer {
    def main(args: Array[String]): Unit = {

        //（1）自动提升原则：有多种类型的数据混合运算时，系统首先自动将所有数据转换成精度大的那种数值类型，然后再进行计算。
        var n = 1 + 2.0
        println(n)  // n 就是Double

        //（2）把精度大的数值类型赋值给精度小的数值类型时，就会报错，反之就会进行自动类型转换。
        var n2 : Double= 1.0
        //var n3 : Int = n2 //错误，原因不能把高精度的数据直接赋值和低精度。

        //（3）（byte，short）和char之间不会相互自动转换。
        var n4 : Byte = 1
        //var c1 : Char = n4  //错误
        var n5:Int = n4

        //（4）byte，short，char他们三者可以计算，在计算时首先转换为int类型。
        var n6 : Byte = 1
        var c2 : Char = 1
        // var n : Short = n6 + c2 //当n6 + c2 结果类型就是int
        // var n7 : Short = 10 + 90 //错误，精度大的不能转换为小的
    }
}

```



### 强制类型转换

#### 基本说明

* 自动类型转换的逆过程，将精度大的数值类型转换为精度小的数值类型。使用时要加上强制转函数，但可能造成精度降低或溢出，格外要注意。

```scala
Java  :  int num = (int)2.5
Scala :  var num : Int = 2.7.toInt
```

#### 案例实操

1. 将数据由高精度转换为低精度，就需要使用到强制转换
2. 强转符号只针对于最近的操作数有效，往往会使用小括号提升优先级

```scala
object TestForceTransfer {

    def main(args: Array[String]): Unit = {

        //（1）将数据由高精度转换为低精度，就需要使用到强制转换
        var n1: Int = 2.5.toInt // 这个存在精度损失
        
        //（2）强转符号只针对于最近的操作数有效，往往会使用小括号提升优先级
        var r1: Int = 10 * 3.5.toInt + 6 * 1.5.toInt  // 10 *3 + 6*1 = 36
        var r2: Int = (10 * 3.5 + 6 * 1.5).toInt  // 44.0.toInt = 44

        println("r1=" + r1 + " r2=" + r2)
    }
}
```



### 数值类型和String类型间的转换

#### 案例实操

1. 基本类型转String类型（语法：将基本类型的值+" " 即可）
2. String类型转基本数值类型（语法：s1.toInt、s1.toFloat、s1.toDouble、s1.toByte、s1.toLong、s1.toShort）

```scala
object TestStringTransfer {

    def main(args: Array[String]): Unit = {

        //（1）基本类型转String类型（语法：将基本类型的值+"" 即可）
        var str1 : String = true + ""
        var str2 : String = 4.5 + ""
        var str3 : String = 100 +""

        //（2）String类型转基本数值类型（语法：调用相关API）
        var s1 : String = "12"

        var n1 : Byte = s1.toByte
        var n2 : Short = s1.toShort
        var n3 : Int = s1.toInt
        var n4 : Long = s1.toLong
    }
}
```

#### 注意事项

* 在将String类型转成基本数值类型时，要确保String类型能够转成有效的数据，比如我们可以把"123"，转成一个整数，但是不能把"hello"转成一个整数。

* var n5:Int = "12.6".toInt会出现异常，因为"."无法转换

## 扩展面试题

![](D:\MyWork\BigData\img\scala类型转换扩展面试题.png)


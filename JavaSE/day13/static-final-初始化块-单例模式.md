# static关键字

静态：类属性和类方法

非静态：对象属性和对象方法

## 一、类属性和类方法的设计思想

- 类属性作为该类各个对象之间共享的变量
- 如果方法与调用者无关，则这样的方法通常定义为类方法，可以不创建对象，直接用类调用

## 二、被修饰的成员具有如下特点：

在java类中，可用static修饰**属性、方法、代码块、内部类**

- 优先于对象存在
- 类变量（类属性）修饰的成员，被所有对象所共享

```
public class Employee{
	//静态属性，类属性
	public static String company = "阿里";
	//静态方法，类方法
	public static void statictest1(){
		//静态方法可以直接访问静态属性
		System.out.println("公司：" + company);
	}
	
	//对象属性，对象方法
	private int id;
	private String name;
	private int age;
	private double salary;
}
```

- 访问权限允许时，可不创建对象，**直接被类调用**

```
public class EmployeeTest {

	public static void main(String[] args) {
		System.out.println(Employee.company);
		//可不创建对象，直接被类调用
		Employee.company = "尚硅谷";
		System.out.println(Employee.company);
		
		//可不创建对象，直接被类调用
		Employee.staticTest1();
	}
}
```

* 静态成员随着类的加载而加载，所以非静态成员可以访问静态成员，非静态环境中可以直接访问静态成员；
* 构造器是最典型的非静态成员

```
//构造器：最典型的非静态成员
public Employee(String name, int age, double salary) {
		super();
		this.id = count++; // 非静态成员访问静态成员.
		staticTest1(); // 非静态环境中可以直接访问静态成员
		this.name = name;
		this.age = age;
		this.salary = salary;
	}
```



* 但是在静态环境中不可以直接访问非静态成员，必须通过对象间接访问

```
	//静态方法
	public static void staticTest2() {
		// 在静态环境中不可以直接访问非静态成员
		//this.name = "某员工";
		//this.age = 20;
		//this.salary = 5000;
		// 必须通过对象间接访问
		Employee emp = new Employee(); 
		
		emp.name = "某员工";
		emp.age = 20;
		emp.salary = 5000;
		System.out.println(emp);
	}
```

* 由于不需要实例就可以访问static方法，所以static内部不能使用this
* 静态属性和方法不能继承，因为java是面向对象编程，如果可以继承就变成面向类编程了；
* 但是子类（的对象）是可以调用父类的静态方法的，因为有extends关键字，在调用时会去类模板中找，在类模板中可以定位到父类的静态方法，从而实现调用；如果子类中有同名的方法，仍然调用父类的方法，而不会覆盖 （即：静态方法不具备继承和多态）

```
public class Employee {
	public static void staticTest1() {
		System.out.println("Employee..."); 
	}
}

//如果子类中有同名的方法，仍然调用父类的方法，而不会覆盖 
//会输出：Employee...
public class MyEmployee extends Employee {
	public static void staticTest1() {
		System.out.println("MyEmployee staticTest...");
	}
}
```

# 单例（Singleton）模式

**设计模式**是在大量的实践中总结和理论化之后优选的代码结构、编程风格、以及**解决问题的思考方式**。设计模式就像是经典的棋谱，不同的棋局，我们用不同的棋谱，免去我们自己再思考和摸索。

所谓类的**单例设计模式**，就是采取一定的方法保证在整个的软件系统中，**对某个类只能存在一个对象实例**，并且该类只提供一个取得其对象实例的方法。

## 饿汉式单例

```java
class Singleton1{
	Singleton(){};
}
public static void main(String[] args) {
		Singleton1 s1 = new Singleton1();
		Singleton1 s2 = new Singleton1();
		System.out.println(s1 == s2);
}
```

上面的s1和s2是两个对象，不是单例，那么如何创建创建单例呢？

1. 封装构造器，防止外部创建对象
2. 声明一个**私有的静态的**指向本类对象的引用变量, 并创建唯一对象
3. 声明一个**公共的静态方法**, 用以获取唯一对象的地址

```java
// 饿汉式单例
class Singleton1 {
	
	// 2) 声明一个私有的静态的指向本类对象的引用变量, 并创建唯一对象
	private static Singleton1 only = new Singleton1();
	
	// 3) 声明一个公共的静态方法, 用以获取唯一对象的地址
	public static Singleton1 getInstance() {
		return only;
	}
	
	// 1) 封装构造器, 防止外部创建对象
	private Singleton1() {}
}

public static void main2(String[] args) {
		//2)
		//这样就实现只有一个only了
		//Singleton1 s1 = Singleton1.only;
		//Singleton1 s2 = Singleton1.only;
		//加上静态之后，only仍然暴露在外边，可以被修改，例如被改为		
    	//null，所以还需要加一个private
		//Singleton1.only = null;
		//3)
		Singleton1 s1 = Singleton1.getInstance();
		Singleton1 s2 = Singleton1.getInstance();
		System.out.println(s1 == s2);
		
	}
```

## 懒汉式单例

1. 封装构造器
2. 声明一个**私有的静态的**指向本类对象的引用属性. 
3. 提供一个**公共的静态**方法用以获取对象

```
// 懒汉式单例
class Singleton2 {
	
	// 1) 封装构造器
	private Singleton2() {}
	
	// 2) 声明一个私有的静态的指向本类对象的引用属性. 
	private static Singleton2 only = null;
	
	// 3) 提供一个公共的静态方法用以获取对象
	public static Singleton2 getInstance() {
		if (only == null) {
			only = new Singleton2();
		}
		return only;
	}
}
```

* 注：暂时懒汉式还存在线程安全问题，讲到多线程时，可修复
* 典型的单例：java.lang.Runtime

![https://github.com/kocdaniel/BigData/blob/master/img/%E5%85%B8%E5%9E%8B%E7%9A%84%E5%8D%95%E4%BE%8B.png](https://github.com/kocdaniel/BigData/blob/master/img/典型的单例.png)

# 初始化块

1. 静态初始化块`static{}`：
   * 初始化块, 对类进行初始化工作, **在类加载时执行仅有的一次**, 在class文件中方法名为<cinit> 
   * 类加载时就执行
   * 可以有输出语句。
   * 可以对类的属性、类的声明进行初始化操作。
   * 不可以对非静态的属性初始化。即：不可以调用非静态的属性和方法。
   * 若有多个静态的代码块，那么按照从上到下的顺序依次执行。
   * 静态代码块的执行要先于非静态代码块。
   * 静态代码块只执行一次
2. 非静态初始化块`{}`：
   * 非静态语句块, 和对象相关, 它会在创建对象时执行, 无论调用哪个构造器都要执行.
   * 每次创建对象的时候，都会执行一次，且先于构造器执行
   * 可以有输出语句。
   * 可以对类的属性、类的声明进行初始化操作。
   * 可以调用静态的变量或方法。
   * 若有多个非静态的代码块，那么按照从上到下的顺序依次执行。

# final

* final表示最终的, 终极的, 可以修饰类, 方法和变量
*  final修饰类 表明这个类是终极类, 意味着它是完美的, 不允许子类扩展
* final修饰方法, 表明这个方法是终极方法, 意味着它是完美, 不允许子类重写
* final修饰变量, 表明这个量是常量, **只能必须**赋值一次，空final量 很危险，必须尽快完成一次赋值，一般在非静态初始化块中完成赋值
* public static final 修饰的量称为**全局常量**












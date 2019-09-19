# Calender

* Calendar是一个抽象基类，主用用于完成日期字段之间相互操作的功能。

```
@Test
	public void testName2() throws Exception {
		// 声明对象
		Calendar calendar = Calendar.getInstance();
		System.out.println(calendar);
		// 获取年月日，但是没有getYear()方法，只有get方法，然后可以选择参数
		//int year = calendar.getYear();
		int year = calendar.get(Calendar.YEAR); // getYear()
		int month = calendar.get(Calendar.MONTH); // 比实际要小1 , return values[2]
		int day = calendar.get(Calendar.DAY_OF_MONTH);
		
		System.out.println(year);
		System.out.println(month);
		System.out.println(day);
		
		// 设置成奥运会2008-08-09
		// 设置年月日，和get一样，没有单独的方法，设置年月日时需要传入参数
		//calendar.setYear(2008);
		calendar.set(Calendar.YEAR, 2008); // values[1] = 2008
		calendar.set(Calendar.MONTH, 7);
		calendar.set(Calendar.DAY_OF_MONTH, 9);
		
		// 获取设置好的时间
		Date date = calendar.getTime();
		System.out.println(date);
		
		// 增加时间
		calendar.add(Calendar.DAY_OF_MONTH, -400); // 奥运会400以前
		date = calendar.getTime();
		System.out.println(date);
		
		
	}
```



# LocalDate / LocalTime / LocalDateTime

* Java的日期与时间 API 问题由来已久，Java 8 之前的版本中关于时间、日期及其他时间日期格式化类由于线程安全、重量级、序列化成本高等问题而饱受批评。Java 8 吸收了 Joda-Time 的精华，以一个新的开始为 Java 创建优秀的API。
* 新的java.time 中包含了所有关于时钟（Clock），本地日期（LocalDate）、本地时间（LocalTime）、本地日期时间（LocalDateTime）、时区（ZonedDateTime）和持续时间（Duration）的类。
* LocalDate、LocalTime、LocalDateTime 类的**实例是不可变的对象**，分别表示使用ISO-8601日历系统的日期、时间、日期和时间。

```
@Test
	public void test3() {
		// 获取当前时间now()方法
		LocalDate localDate = LocalDate.now(); //new LocalDate(2019, 8 , 10);
		System.out.println(localDate);
		// 有单独的获取年月日的方法
		System.out.println(localDate.getYear());
		System.out.println(localDate.getMonthValue());
		System.out.println(localDate.getDayOfMonth());
		
		// 使用with来设置年月日
		LocalDate aoyun = localDate.withYear(2008).withMonth(8).withDayOfMonth(9);
		System.out.println(aoyun);
		
		LocalDate plusDays = localDate.plusDays(-500); 
		LocalDate minusDays = localDate.minusDays(300);
		
		System.out.println(plusDays);
		System.out.println(minusDays);
		
		LocalTime localTime = LocalTime.now();
		System.out.println(localTime);
		
		LocalDateTime localDateTime = LocalDateTime.now();
		System.out.println(localDateTime);
		// 获取当前日期, 设置为你的生日, 再获取百岁.
	}
```

# DateTimeFormatter 类

```
@Test
	public void test4() {
		// 1997,7,1
		LocalDate of = LocalDate.of(1997, 7, 1);
		System.out.println(of);
		LocalDateTime of2 = LocalDateTime.of(1998, 2, 5, 10, 20, 30);
		System.out.println(of2.toString());
		
		// Date类的格式化方法
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		//System.out.println(sdf.format(of2));
		
		//new DateTimeFormatter("yyyy-MM-dd HH:mm:ss");
		// DateTimeFormatter 类，新的格式化方法
		DateTimeFormatter ofPattern = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
		System.out.println(ofPattern.format(of2));
		
		//System.out.println(ofPattern.format(new Date()));
	}
```



# Math

* java.lang.Math提供了一系列静态方法用于科学计算；其方法的参数和返回值类型一般为double型。

```
abs     绝对值
acos,asin,atan,cos,sin,tan  三角函数
sqrt     平方根
pow(double a,doble b)     a的b次幂
log    自然对数
exp    e为底指数
max(double a,double b)
min(double a,double b)
random()      返回0.0到1.0的随机数
long round(double a)     double型数据a转换为long型（四舍五入）
toDegrees(double angrad)     弧度—>角度
toRadians(double angdeg)     角度—>弧度
```



# 集合

## Collection

* Collection 接口, 表示是一个容器, 用于保存对象

### 特点 

* 一个一个地保存,  无序可重复

### 方法

* `boolean add(Object obj)` 添加元素, 如果成功返回true, 失败返回false
* `int size()` 返回集合中的元素个数
* `boolean remove(Object obj)` 从集合中删除某个元素

### 子接口

* **Set** 子接口, **无序不可重复**(序是添加顺序)

  * **HashSet 具体类** : 使用哈希算法实现的Set集合，**无序不可重复**(序是添加顺序)

     * 				**对象重复的标准**是两个对象的equals为true, 并且两个对象hashCode值也相同

  * **TreeSet 具体类** : 基于二叉树实现的Set实现，**无序不可重复**(序是添加顺序)，**内部作自然排序**

    * 添加的对象必须是可比较的，否则会抛出异常
    
    - **对象重复的标准**是两个对象调用compareTo方法, 返回值为0
  - 如果以类自身的compareTo排序, 称为自然排序
    - 如果是以比较器进行排序, 称为定制排序.
    
    

* **List 子接口**, **有序可重复**, 最像数组

  * `void add(int index, Object ele)`, 在指定index下标位置处插入新对象
  * `Object get(int index)` 获取指定index下标位置处的对象
  * `Object remove(int index)` 删除指定index下标位置处的元素
  * `Object set(int index, Object ele)` 把指定index下标位置处的元素替换为新元素ele, 返回老元素
  * **ArrayList 具体类** : 使用数组实现List集合
  * **LinkedList 具体类** : 使用链表实现List集合



## Map

 * Map 接口, 表示的也是一个容器 

### 特点 : 

* 一对一对地保存

### 定义

- **Map接口** : 保存一对一对的具有映射关系的对象
- 从内部来看, 它里面有两个子集合, 一个Set用于保存所有的key对象, 另一个是Collection用于保存所有的value对象
- 或者也可以看成是一个Set集合, 只不过它的元素是Entry对象, Entry对象内部有两个对象, 一个是key对象, 一个是value对象

### 方法

- `Object put(Object key, Object value)` // 写入词条, 返回老值，**添加元素时, 键相同, 新值会替换老值**
- `Object remove(Object key)` // 删除词条
- `Object get(Object key)` // 查词典
- `int size()` 获取词条数
- `Set keySet()` 返回保存所有键对象的Set子集合
- `Set entrySet()`; 返回保存所有Entry对象的Set集合

# 迭代器 iterator

* lIterator对象称为迭代器(设计模式的一种)，主要用于遍历Collection集合中的元素。
* 所有实现了Collection接口的集合类都有一个iterator()方法，用以返回一个实现了Iterator接口的对象。
* **Iterator** **仅用于遍历集合**，Iterator 本身并不提供承装对象的能力。如果需要创建
  Iterator 对象，则必须有一个被迭代的集合。
* 在调用**it.next()**方法之前必须要调用**it.hasNext()**进行检测。若不调用，且下一条记录无效，直接调用it.next()会抛出NoSuchElementException异常。
* **注意点**
  * 注意点1 : 迭代器拿到以后, 必须马上使用, 使用新鲜的.
  * 注意点2: next方法的调用, 在循环中只能调一次.

```
		Set set = new TreeSet()
		// 迭代器 : 1) 拿到迭代器, 向集合对象要, 
		// 注意点1 : 迭代器拿到以后, 必须马上使用, 使用新鲜的.
		Iterator iterator = set.iterator();
		//set.add(new Person("某某", 20, "男"));
		// 2) 循环询问迭代器有没有下一个
		while (iterator.hasNext()) {
			// 3) 如果有下一个, 真的拿到下一个
			Object object = iterator.next(); // 注意点2: next方法的调用, 在循环中只能调一次.
			System.out.println(object);
		}
```




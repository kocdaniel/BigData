# 泛型

## 为什么要有泛型

* 解决元素存储的安全性问题
* 解决获取数据元素时，需要类型强转的问题

![https://github.com/kocdaniel/BigData/blob/master/img/%E6%B3%9B%E5%9E%8B.png](https://github.com/kocdaniel/BigData/blob/master/img/泛型.png)

## 核心思想

**把一个集合中的内容限制为一个特定的数据类型，这就是generics背后的核心思想。**

## 使用泛型

1. **泛型的声明**

  `interface List<T> 和 class TestGen<K,V>` 

 其中，T,K,V不代表值，而是表示类型。这里使用任意字母都可以。常用T表示，是Type的缩写。

2. **泛型的实例化：**

​     一定要在**类名后面**指定类型参数的值（类型）。如：

​    `List<String> strList = new ArrayList<String>();`

   `Iterator<Customer> iterator =customers.iterator();`

​	T只能是类，不能用基本数据类型填充。

## 泛型的几个重要应用

### 在集合中使用泛型

1. 对象实例化时不指定泛型，默认为：Object

2. 泛型不同的引用不能相互赋值。

3. 加入集合中的对象类型必须与指定的泛型类型一致
4. **静态方法中不能使用类的泛型**。
5. 如果泛型类是一个接口或抽象类，则不可创建泛型类的对象。
6. 不能在catch中使用泛型
7. 从泛型类派生子类，泛型类型可以具体化
8. 泛型不能直接多态，如` List<Number> list = new ArrayList<Integer>();`，不可以这样写

* **代码示例**

```
	@Test
	public void test2() {
		Person<Integer> person1 = new Person<Integer>("张三", 30);
		Integer info1 = person1.getInfo();
		System.out.println(info1);
		
		Person<Boolean> person2 = new Person<Boolean>("李四", true);
		Boolean info2 = person2.getInfo();
		System.out.println(info2);
		
		Person person3 = new Person("王五", 3.22); // 没有指定泛型, 只能是Object类型
		Object info3 = person3.getInfo();
		System.out.println(info3);
		
	}
```



### 自定义泛型类与泛型方法

* **自定义类与泛型方法**

```
// 格式：类名<泛型类型>
// Q在这个类中就是代表某种类型的, Q是泛型类型的形参, 在创建对象时由调用者指定实际的类型, 
// 如果调用者没有指定实际类型, 就是Object类型
class Person<Q> { 

	private String name;
	private Q info;
	
	public Person(String name, Q info) {
		this.name = name;
		this.info = info;
	}
	
	public String getName() {
		return name;
	}
	
	public void setName(String name) {
		this.name = name;
	}
	
	public Q getInfo() {
		return info;
	}
	
	public void setInfo(Q info) {
		this.info = info;
		Q q = null;
	}

	@Override
	public String toString() {
		return "Person [name=" + name + ", info=" + info + "]";
	}
	
	public static void test() {
		// 在静态方法中, 不可以使用泛型类型, 因为泛型类型隶属于对象
		//Q q = null;(×) 
	}
	
	// 泛型方法, 在返回值之前加<泛型类型>, P在方法中有效, 代表某种类型.
	// 泛型方法必须传参, 并且是泛型类型, 在某次调用时,通过实参的对象来确定类型. 
	// 如果实参是null, P类型只能是Object
	public <P> P test2(P p) { 
		P p1 = null;
		return p1;
	}
	
	public static <R> R test4(R r2) {
		R r = null;
		return r;
	}
	
	
	
```

* **使用示例**

```
	@Test
	public void test4() {
		Person<Integer> person = new Person<Integer>("张三", 30);
		// 返回值是由传入的参数类型决定的
		String test2 = person.test2("abc");
		
		Integer test22 = person.test2(300);
		
		Boolean test4 = Person.test4(false);
		Double test42 = Person.test4(3.22);
		
		Object test43 = Person.test4(null);
	}
```

### 泛型与继承的关系

```
class A<T> {
	protected T t;
	public T getT() {
		return t;
	}
}

// 子类无视泛型 , 导致泛型类型永远是Object, 类型模糊
class B1 extends A {} 

// 子类直接把泛型父类的泛型类写死, 子类中继承的T类型永远是固定的
class B2 extends A<String> {} 
class B3 extends A<Boolean> {}

// 子类也泛型, 在子类对象创建时再动态决定泛型类型, 这是最灵活的做法.
class C<T> extends A<T> {} 
```

### 通配符？

* ？

```
	// 对于集合只读访问, 可以兼容所有泛型类型的List集合
	public void printList(List<?> list) { 
		for (Object object : list) {
			System.out.println(object);
		}
		System.out.println("*******************************");
	}
	
	@Test
	public void test6() {
		//泛型不能直接多态
		//List<Number> list = new ArrayList<Integer>();
		List<Integer> list = new ArrayList<Integer>();
		for (int i = 0; i < 10; i++) {
			list.add((int)(Math.random() * 20));
		}
		
		
		List<?> list2 = list; // ? 表示类型完全未知
		// 可以获取, 但是只能获取类型模糊的Object,因为list2类型未知
		Object object = list2.get(0); 
		
		printList(list);
		
		//list2.add(500); // 不能添加元素, 原因是类型未知
		list2.add(null); // 可以添加null，原因是null也是类型未知
		
		List<Object> list3 = new ArrayList<Object>();
		// 可以添加，list3类型为Object
		list3.add(400); 
		list3.add("abc"); 
		
		printList(list3);
	}
```

* **extends及super**

````
	@Test
	public void test7() {
		List<Integer> list1 = new ArrayList<Integer>();
		for (int i = 0; i < 10; i++) {
			list1.add((int)(Math.random() * 20));
		}
		
		List<Double> list2 = new ArrayList<Double>();
		for (int i = 0; i < 10; i++) {
			list2.add((Math.random() * 20));
		}
		
		// list3集合中保存的是Number及其未知子类的对象
		List<? extends Number> list3 = list1;
		list3 = list2;
		
		//list3.add(10); // list3集合中保存的是Number的未知子类, 所以不能添加元素
		Number number = list3.get(0); // 可以获取, 并且是Number父类类型引用指向的.
		
		// list4集合中保存的是Number及其未知父类类型的对象
		List<? super Number> list4 = new ArrayList<Number>();
		
		list4.add(300); // 可以添加Number及其任意子类对象, 集合中保存的元素类型是Number的父类类型, 
		list4.add(3.22); 
		
		Object object = list4.get(0); // 不适合获取, 因为未知父类, 只能用Object表示.
	}
````





# Map

## 定义

 * **Map接口** : 保存一对一对的具有映射关系的对象
 * 从内部来看, 它里面有两个子集合, 一个Set用于保存所有的key对象（**不允许重复**）, 另一个是Collection用于保存所有的value对象
 * 或者也可以看成是一个Set集合, 只不过它的元素是Entry对象, Entry对象内部有两个对象, 一个是key对象, 一个是value对象
 * key 与 value 之间存在**单向的一对一关系**，即：通过指定的 key 总能找到唯一确定的 value 。

![Map](https://github.com/kocdaniel/BigData/blob/master/img/Map.png)

## 方法

 * `Object put(Object key, Object value)` // 写入词条, 返回老值，**添加元素时, 键相同, 新值会替换老值**
 * `Object remove(Object key)` // 删除词条
 * `Object get(Object key)` // 查词典
 * `int size()` 获取词条数
 * `Set keySet()` 返回保存所有键对象的Set子集合
 * `Set entrySet()`; 返回保存所有Entry对象的Set集合

## Map实现类

* **Map接口的常用实现类**：**HashMap**, **TreeMap** 和 **Properties**

### HashMap

* **HashMap**是Map**使用频率最高**的实现类
* HashMap **判断两个** **key** **相等的标准**是：两个 key 通过 equals() 方法返回 true，hashCode 值也相等。
* HashMap **判断两个** **value相等的标准**是：两个 value 通过 equals() 方法返回 true。

### TreeMap

* TreeMap存储 Key-Value对时，需要根据 key-value对进行排序。TreeMap 可以保证所有的Key-Value对处于有序状态。
* **TreeMap 的 Key 的排序：**
  * **自然排序**：TreeMap 的所有的 Key 必须实现 Comparable接口，而且所有的Key应该是同一个类的对象，否则将会抛出ClasssCastException
  * **定制排序**：创建 TreeMap 时，传入一个Comparator对象，该对象负责对TreeMap 中的所有 key 进行排序。此时不需要Map的 Key 实现 Comparable 接口
  * TreeMap判断**两个key相等的标准**：两个key通过compareTo()方法或者compare()方法返回0。

# 工具类（Collections）

## 定义

* Collections 是一个操作 Set、List 和 Map 等集合的工具类

* Collections 中提供了一系列**静态**的方法对集合元素进行**排序、查询和修改**等操作，还提供了**对集合对象设置不可变、对集合对象实现同步控制**等方法

## 静态方法

* `reverse(List)`：反转 List 中元素的顺序
* `shuffle(List)`：对 List 集合元素进行随机排序
* `sort(List)`：根据元素的自然顺序对指定 List 集合元素按升序排序
* `sort(List，Comparator)`：根据指定的 Comparator 产生的顺序对 List 集合元素进行排序
* `swap(List，int， int)`：将指定 list 集合中的 i 处元素和 j 处元素进行交换

# Properities

## 定义

* **Properties** 类是 **Hashtable** 的子类，该对象用于处理属性文件
* 由于属性文件里的 key、value 都是字符串类型，所以 Properties 里的 **key 和 value 都是字符串类型**
* 存取数据时，建议使用`setProperty(String key,String value)`方法和`getProperty(String key)`方法

## 代码示例

```
	@Test
	public void test4() throws FileNotFoundException, IOException {
	// 保存属性, 有属性名和属性值, 属性名作为键, 属性值作为值, 本质上就是Map集合
		Properties properties = new Properties(); 
		// 自动处理文本文件中的属性信息
		properties.load(new FileInputStream("test.properties")); 
		
		/*
		Object object = properties.get("user");
		System.out.println(object); 
		*/
		String property = properties.getProperty("user");
		System.out.println(property);
		
		System.out.println(properties.getProperty("url"));
	}
```



# ArrayList源码(debug追踪)

```
public class ArrayList<E> extends AbstractList<E> implements List<E>, RandomAccess, Cloneable, java.io.Serializable {
    
	// 数组的缺省容量
    private static final int DEFAULT_CAPACITY = 10;

    private static final Object[] EMPTY_ELEMENTDATA = {};

	// 这是一个空的对象数组
    private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};
	
	// 从父类继承的属性, 记录集合的修改次数的.
	protected transient int modCount = 0;

	// 最核心的内部存储的数组, Object类型
    transient Object[] elementData; // non-private to simplify nested class access
	
	// 计数器, 用于控制数组插入和删除
    private int size;
	
	// 通过无参构造器, 内部数组是长度为0的, 不能插入元素
	public ArrayList() {
        this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
    }
	
	// 真正的添加
	public boolean add(E e) {
        ensureCapacityInternal(size + 1);  // 确保添加元素得有空间, 如果是第一次,直接数组长度就是10, 如果没有空间会扩容, 扩容是1.5倍
        elementData[size++] = e; // 真正插入的代码
        return true;
    }
	
	private static int calculateCapacity(Object[] elementData, int minCapacity) {
        if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) { // 判断是第一次插入元素
            return Math.max(DEFAULT_CAPACITY, minCapacity);
        }
        return minCapacity;
    }

    private void ensureCapacityInternal(int minCapacity) {
        ensureExplicitCapacity(calculateCapacity(elementData, minCapacity));
    }

    private void ensureExplicitCapacity(int minCapacity) {
        modCount++;

        // overflow-conscious code
        if (minCapacity - elementData.length > 0)
            grow(minCapacity); // 扩容
    }
	
	// 扩容
	private void grow(int minCapacity) {
        // overflow-conscious code
        int oldCapacity = elementData.length;
        int newCapacity = oldCapacity + (oldCapacity >> 1); // 老容量*1.5
        if (newCapacity - minCapacity < 0)
            newCapacity = minCapacity;
        if (newCapacity - MAX_ARRAY_SIZE > 0)
            newCapacity = hugeCapacity(minCapacity);
        // minCapacity is usually close to size, so this is a win:
        elementData = Arrays.copyOf(elementData, newCapacity); // 扩容
    }
	
	// [30, 20, 40, 10, 50, 80]
	public E remove(int index) { // 3
        rangeCheck(index);

        modCount++;
        E oldValue = elementData(index); // 10

        int numMoved = size - index - 1; // 计算要移动的元素个数 
        if (numMoved > 0)
            System.arraycopy(elementData, index+1, elementData, index,
                             numMoved);
        elementData[--size] = null; // clear to let GC do its work

        return oldValue;
    }
	
	// 插入操作
	// [30, 20, 40, 10, 50, 80, 100, 200, 300, 400, 500]
	public void add(int index, E element) { // 2, 600
        rangeCheckForAdd(index);

        ensureCapacityInternal(size + 1);  // Increments modCount!!
		// 把添加下标右面所有元素右移
        System.arraycopy(elementData, index, elementData, index + 1, size - index);
		// [30, 20, 40, 40, 10, 50, 80, 100, 200, 300, 400, 500]
        elementData[index] = element; // 把新元素插入到指定下标处
		// [30, 20, 600, 40, 10, 50, 80, 100, 200, 300, 400, 500]
        size++;
    }
	
}
```


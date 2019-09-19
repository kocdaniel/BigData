# 集合的优缺点

## List 

- ​         **ArrayList :** 基于**数组**实现 **缺点** : 对内存要求高, 要求内存连续.

​                                     末端数据的插入删除性能: 最快

​                                     非末端数据的插入删除性能 : 最慢

​                                     检索性能 : 较快

 

- ​         **LinkedList:** 基于**链表**实现 **优点** : 对内存要求低, 只要够一个结点对象的空间.

​                                     末端数据的插入删除性能: 极快

​                                     非末端数据的插入删除性能 : 极快

​                                     检索性能 : 最慢

## Set 

- ​         **TreeSet :** 基于**二叉树搜索树(红黑树)**实现 对内存要求不高

​                                     插入删除性能: 很慢

​                                     检索性能 : 极快

 

- ​         **HashSet :** 基于**数组的Set**集合

​                                     几近完美, **唯一缺点**就是对内存要求高.

# LinkedList源码剖析

```java
public class LinkedList<E> extends AbstractSequentialList<E> implements List<E>, Deque<E>, Cloneable, java.io.Serializable{
    
	private static class Node<E> { // 构成链表的结点类
        E item; 		// 数据域
        Node<E> next;   // 下一个结点对象的指针
        Node<E> prev;	// 上一个结点对象的指针

        Node(Node<E> prev, E element, Node<E> next) { // 前一个结点地址, 数据, 下一个结点地址
            this.item = element;
            this.next = next;
            this.prev = prev;
        }
    }
	
	// 从父类继承的控制同步的属性
	protected transient int modCount = 0;
	
	// 计数器
	transient int size = 0;
    
	// 头结点
	transient Node<E> first;

    // 尾结点
    transient Node<E> last;

    public LinkedList() {
    }
	
	public boolean add(E e) {
        linkLast(e); // 尾部插入
        return true;
    }
	
	void linkLast(E e) {
        final Node<E> l = last; // l:null, l是老尾结点
        final Node<E> newNode = new Node<>(l, e, null); // 新结点, l是前一个结点
        last = newNode; // 刷新尾, 尾指向最新插入的新结点
        if (l == null) // 第一次插入元素时会进入
            first = newNode; // 头引用指向第一个新结点
        else
            l.next = newNode; // 老尾结点的下一个指针指向新结点
        size++; // 调整计数器
        modCount++; // 修改次数累加
    }
	
	public E remove(int index) {
        checkElementIndex(index);
        return unlink(node(index));
    }
	
	// 定位index位置处的结点对象
	Node<E> node(int index) {
        // assert isElementIndex(index);

		// 二分法查找index结点处的对象
        if (index < (size >> 1)) {// 从前往后
            Node<E> x = first;
            for (int i = 0; i < index; i++)
                x = x.next;
            return x;
        } else { // 从后往前
            Node<E> x = last;
            for (int i = size - 1; i > index; i--)
                x = x.prev;
            return x;
        }
    }
	
	E unlink(Node<E> x) { // x结点是删除目标结点对象
        // assert x != null;
        final E element = x.item; // 保存老值
        final Node<E> next = x.next; // 保存要删除的结点的下一个结点的指针
        final Node<E> prev = x.prev; // 保存要删除的结点的前一个结点的指针

        if (prev == null) { // 删除头结点
            first = next;
        } else {
            prev.next = next;
            x.prev = null;
        }

        if (next == null) { // 删除尾结点
            last = prev;
        } else {
            next.prev = prev;
            x.next = null;
        }

        x.item = null;
        size--;
        modCount++;
        return element; // 返回删除的老值
    }
	
	public void add(int index, E element) {
        checkPositionIndex(index); // 检查index坐标是否越界，越界则抛出异常

        if (index == size) // 如果插入坐标为链表长度，则尾部插入
            linkLast(element); // 尾部插入
        else
            linkBefore(element, node(index)); // 在index结点前插入
    }
	
	void linkBefore(E e, Node<E> succ) {
        // assert succ != null;
        final Node<E> pred = succ.prev; // succ为index结点，pred保存index前结点
        final Node<E> newNode = new Node<>(pred, e, succ); // e插入到index之前，pred之后
        succ.prev = newNode; // 刷新index的前结点为新节点
        if (pred == null) // 前结点为null，则为头部插入
            first = newNode; // 刷新头结点
        else
            pred.next = newNode; // 刷新index的前结点的next为新结点
        size++;
        modCount++;
    }

	
}
```





# IO

## 文件流

* 按操作**数据单位**不同分为：字节流(8bit)，字符流(16bit)
* 根据**数据的流向**不同：输入流，输出流

|            | **字节流**            | **字符流**          |
| ---------- | --------------------- | ------------------- |
| 输入流     | InputStream（基类）   | Reader（基类）      |
| 输出流     | OutputStream （基类） | Writer（基类）      |
| 流中的数据 | 二进制字节（8位）     | Unicode字符（16位） |

### 读写文件步骤

 1. 创建流对象(建立流通道)
 2.  通过流对象处理数据
 3.  关闭流对象.
 4. 如下：

```java
@Test
	public void testReader3() {
		int line = 1;
		System.out.print(line++ + " ");
		// 1)声明流引用变量, 并赋值为null
		FileReader fileReader = null;
		// 2)try catch finally
		try {
			// 5)在try中创建流对象
			fileReader = new FileReader("一个文件");
			// 6)处理数据 
			int ch = fileReader.read();
			while (ch != -1) {
				// 处理已经读到的数据
				System.out.print((char)ch);
				if (ch == 10) {
					System.out.print(line++ + " ");
				}
				// 继续读后面的数据
				ch = fileReader.read();
			}
		} catch (Exception e) {
			// 4)在catch中处理异常
			e.printStackTrace();
		} finally {
			// 3)在finally中关闭流
			if (fileReader != null) {
				try {
					fileReader.close();
				} catch (Exception e2) {
				}
			}
		}
		
	}
```

### Reader & InputStream

1. **Reader**（典型实现：**FileReader**）
   * `int read()` // 读取一个字符，**返回读取到的字符（ASCLL码）**
   * `int read(char [] c)` // **最重要的，一次性读多个字符到缓冲区数组，需要先定义一个char数组,返回读取到的字符个数**
   * `int read(char [] c, int off, int len)`// c 要读取的数组，从off位置开始读取， len 代表要读取的数组长度，**返回读取到的字符个数**

2. **InputStream**（典型实现：**FileInputStream**）
   * `int read()`// 读取一个字节，**返回读取到的字符（ASCLL码）**
   * `int read(byte[] b)`// **一次性读取多个字节到缓冲区数组，需要先定义一个byte数组**，**返回读取到的字节个数**
   * `int read(byte[] b, int off, int len)`// c 要读取的数组，从off位置开始读取， len 代表要读取的数组长度，**返回读取到的字节个数**

### Write & OutputStream

1. `void write(int b / int c) `// 写入一个字节/字符
2. `void write(byte[] b / char[] c)`// 向流中写入一个字节/字符数组
3. `void write(byte[] b / char[] c, int offset, int length)`// 讲数组写入到offset开始的位置，写入长度为length

## 缓冲流

* 为了提高数据读写的速度，Java API提供了带缓冲功能的流类，在使用这些流类时，会创建一个内部缓冲区数组

* 根据**数据操作单位**可以把缓冲流分为：
  1. **BufferedReader** **和** **BufferedWriter**  ： 处理文本文件，操作字符
     * `readLine()`方法，读取一行
     * `newLine()`方法，写入新行，实现跨平台
  2. **BufferedInputStream** **和** **BufferedOutputStream** ： 处理二进制文件，操作字节

## 转换流

* 转换流提供了在**字节流和字符流**之间的转换

### InputStreamReader

* 用于将字节流中读取到的字节按指定字符集解码成字符。需要和InputStream“套接”。

```java
// 声明
FileInputStream fis = null;
InputStreamReader isr = null;
BufferedReader bufferedReader = null;
// 实例化
fis = new FileInputStream("文本测试UTF8.txt");// 按照字节流方式读出
isr = new InputStreamReader(fis, "utf8");// 将读出的字节流按照UTF8格式解码为字符流
bufferedReader = new BufferedReader(isr); // 包装为缓存流
```

### OutputStreamWriter

* 用于将要写入到字节流中的字符按指定字符集编码成字节。需要和OutputStream“套接”。

```java
// 声明
FileOutputStream fos = null;
OutputStreamWriter osw = null;
BufferedWriter bufferedWriter = null;
// 实例化
fos = new FileOutputStream("文本测试GBK.txt"); 
osw = new OutputStreamWriter(fos, "gbk"); // 将要写入字节流中的字符按照GBK的方式编码为字节流
bufferedWriter = new BufferedWriter(osw);
```

### 图示

![1565780149744](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1565780149744.png)

## 对象流

* **ObjectInputStream和OjbectOutputSteam** ：用于存储和读取**对象**的处理流。它的强大之处就是可以把Java中的对象写入到数据源中，也能把对象从数据源中还原回来。

### 序列化（Serialize）

用`ObjectOutputStream`类将一个Java对象写入IO流中

**注意**： 

1. `ObjectOutputStream`和`ObjectInputStream`不能序列化**static和transient**修饰的成员变量
2. 如果想要让某个对象支持序列化机制，必须让其类是可序列化的，要让其类可序列化，需要让其类实现**Serializable**和**Externalizable**接口之一

* **序列化示例**

```java
	@Test
	public void testSerilized() {
		FileOutputStream fos = null;
		BufferedOutputStream bos = null;
		ObjectOutputStream oos = null;
		
		try {
			fos = new FileOutputStream("对象序列化文件");
			bos = new BufferedOutputStream(fos);
			oos = new ObjectOutputStream(bos);
			
			Person person1 = new Person("小明", 30, "男");
			Person person2 = new Person("李明", 40, "男");
			Person person3 = new Person("小丽", 20, "女");
			
			List<Person> perArr = new ArrayList<Person>();
			perArr.add(person1);
			perArr.add(person2);
			perArr.add(person3);
			
			oos.writeObject(perArr);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if(oos != null) {
				try {
					oos.close();
				} catch (Exception e2) {
				}
			}
		}
	}
```



### 反序列化（Deserialize）

用`ObjectInputStream`类从IO流中恢复该Java对象

* **反序列化示例**

```java
@Test
	public void testUnSerilized() {
		FileInputStream fis = null;
		BufferedInputStream bis = null;
		ObjectInputStream ois = null;
		
		try {
			fis = new FileInputStream("对象序列化文件");
			bis = new BufferedInputStream(fis);
			ois = new ObjectInputStream(bis);
			
			List<Person> readObject = (List<Person>)ois.readObject();
			Iterator<Person> iterator = readObject.iterator();
			while(iterator.hasNext()) {
				System.out.println(iterator.next());
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if(ois != null) {
				try {
					ois.close();
				} catch (Exception e2) {
					// TODO: handle exception
				}
			}
		}
 	}
```



## 标准输入输出流

* `System.in和System.out`分别代表了系统标准的输入和输出设备
* 默认输入设备是键盘，输出设备是显示器

```java
	@Test
	public void test5() {
		InputStream is = System.in;
		InputStreamReader isr = null;
		BufferedReader bufferedReader = null;
		try {
			isr = new InputStreamReader(is);
			bufferedReader = new BufferedReader(isr);
			
			String line = bufferedReader.readLine();
			while (line != null) {
				System.out.println(line);
				line = bufferedReader.readLine(); // 如果接收到ctrl+z, 就返回null
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (bufferedReader != null) {
				try {
					bufferedReader.close(); // 键盘流一旦关闭, 就打不开了.
				} catch (Exception e2) {
				}
			}
		}
	}
```

## Scanner

```java
	@Test
	public void test6() {
		Scanner scanner = new Scanner(System.in);
		while (scanner.hasNext()) {
			if (scanner.hasNextInt()) {
				int nextInt = scanner.nextInt();
				System.out.println("整数 : " + nextInt);
			} else if (scanner.hasNextDouble()) {
				double nextDouble = scanner.nextDouble();
				System.out.println("浮点数:" + nextDouble);
			} else {
				String next = scanner.next();
				System.out.println(next);
			}
		}
		
		scanner.close();
	}
```

## 重点

![1565957078073](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1565957078073.png)

![1565957216102](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1565957216102.png)

# 字符编码

1. 编码：字符串 -> 字节数组 

   `byte[] = 字符串.getBytes(“编码方式名”);`

2. 解码：字节数组 -> 字符串 

   `String str = new String(byte[],”编码方式名”);`

# Collection与Map的总结

## 两道作业题

1. **给定一个字符串, 统计每个字符出现的次数**(谷歌面试题)

* **最经典解法**：
  * **核心思想：**将char字符存入其ascll码对应的位置，每次存入时，对应位置处的值加一，即为计数值

```java
	@Test
	public void test5() {
		//给定一个字符串, 统计每个字符出现的次数
		String string = "asdkjf我和你我喜欢你大家好才是真的好alkjflajdsfljasdf234234234";
		int[] array = new int[60000];
		for (int i = 0; i < string.length(); i++) {
			char ch = string.charAt(i);
			// System.out.println(ch);
			array[ch]++; // 这里的ch为其ascll码值
		}
		
		for (int i = 0; i < array.length; i++) {
			if (array[i] != 0) {
				System.out.println((char)i + " : " +  array[i]);
			}
		}
	}
```

* **使用map：将字符-个数按照key-value的关系存入map中**

```
	@Test
	public void test4() {
		//给定一个字符串, 统计每个字符出现的次数
		String string = "asdkjf我和你我喜欢你大家好才是真的好alkjflajdsfljasdf234234234";
		Map<Character, Integer> map = new HashMap<Character, Integer>();
		for (int i = 0; i < string.length(); i++) {
			char ch = string.charAt(i);
			Integer count = map.get(ch); // 每个字符第一次get时都为空，以后每次get都在之前的基础上加一
			if (count == null) {
				count = 0;
			}
			count++;  // 如果为null，则先置零再加一
			map.put(ch, count);
		}
		
		System.out.println(map);
	}
```

2. **请把学生名与考试分数录入到Map中，并按分数显示前三名成绩学员的名字。**

* 面向对象的思想，将学生对象当作参数传入set中，自定义比较器

```java
@Test
	public void test2() {
		Map<String, Integer> map = new HashMap<String, Integer>();
		map.put("小明", 70);
		map.put("小花", 20);
		map.put("小刚", 90);
		map.put("小丽", 100);
		map.put("小伟", 98);
		map.put("小黑", 100);
		map.put("小方1", 80);
		map.put("小方2", 80);
		map.put("小方3", 80);
		Set<Student> set = new TreeSet<Student>(new Comparator<Student>() {
			@Override
			public int compare(Student o1, Student o2) {
				int n =  o2.getScore() - o1.getScore();
				if (n == 0) {
					n = 1;
				}
				return n;
			}
		}); 
		Set<Entry<String, Integer>> entrySet = map.entrySet();
		Iterator<Entry<String, Integer>> iterator = entrySet.iterator();
		while (iterator.hasNext()) {
			Entry<String, Integer> next = iterator.next();
			Student student = new Student(next.getKey(), next.getValue());
			set.add(student);// student对象作为参数传入
		}
		int count = 0;
		for (Student student : set) {
			System.out.println(student);
			if (++count == 3) {
				break;
			}
		}
	}
```

* **将map.entrySet()的set集合转换为list集合，使用Collections工具类的sort()方法排序，自定义比较器**

```java
	@Test
	public void test3() {
		Map<String, Integer> map = new HashMap<String, Integer>();
		map.put("小明", 70);
		map.put("小花", 20);
		map.put("小刚", 90);
		map.put("小丽", 100);
		map.put("小伟", 98);
		map.put("小黑", 100);
		map.put("小方1", 80);
		map.put("小方2", 80);
		map.put("小方3", 80);
		
		// 将map.entrySet()的set集合转换为list集合
		ArrayList<Entry<String, Integer>> list = new ArrayList<Entry<String, Integer>>(map.entrySet());
		// 使用Collections工具类的sort()方法排序，自定义比较器
		Collections.sort(list, new Comparator<Entry<String, Integer>>() {
			@Override
			public int compare(Entry<String, Integer> o1, Entry<String, Integer> o2) {
				return o2.getValue() - o1.getValue();
			}
		});
		
		for (int i = 0; i < list.size(); i++) {
			System.out.println(list.get(i));
			if (i == 2) {
				break;
			}
		}
	}
```


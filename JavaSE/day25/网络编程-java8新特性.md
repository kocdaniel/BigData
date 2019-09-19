# 网络编程

## 基于Socket的TCP编程

### 客户端Socket的工作过程

1. **创建Socket**：根据指定服务端的 IP 地址或端口号构造 Socket类对象。若服务器端响应，则建立客户端到服务器的通信线路。若连接失败，会出现异常。
2. **打开连接到Socket的输入 / 出流**：使用 `getInputStream()`方法获得输入流，使用 `getOutputStream()`方法获得输出流，进行数据传输
3. **按照一定的协议对Socket进行读写操作**：通过输入流读取服务器放入线路的信息（但不能读取自己放入线路的信息），通过输出流将信息写入线程。
4. **关闭Socket**：断开客户端到服务器的连接，释放线路 

```
	@Test
	public void client() {
		Socket socket2 = null;
		BufferedWriter bufferedWriter = null;
		try {
			socket2 = new Socket("127.0.0.1", 9999); // 客户端主动发起了连接请求, 如果成功,则返回socket对象
			System.out.println(socket2); // 客户端的socket对象
			OutputStream outputStream = socket2.getOutputStream();
			bufferedWriter = new BufferedWriter(new OutputStreamWriter(outputStream));
			bufferedWriter.write("你好, 服务器, 俺是客户端, 收到请回答!!");
			bufferedWriter.newLine();
			bufferedWriter.flush(); // 把数据刷入网线
		} catch (Exception e) {
			e.printStackTrace();
		} finally {// 注意关闭顺序
			if (bufferedWriter != null) {
				try {
					bufferedWriter.close();
				} catch (Exception e2) {
				}
			}
			
			if (socket2 != null) {
				try {
					socket2.close();
				} catch (Exception e2) {
				}
			}
		}
	}
```

### 服务器端Socket的工作过程

1. **调用SeverSocket（int port）**：创建一个服务器端套接字，并绑定到指定端口上。用于监听客户端的请求。
2. **调用accept():**监听连接请求，如果客户端请求连接，则接受连接，返回通信套接字对象(此方法会引起阻塞, 服务器进入等待状态, 一旦有客户端连接, 此方法就返回)
3. 调用该Socket类对象的`getOutputStream()和getInputStream()`获取输出流和输入流，开始网络数据的发送和接收。
4. **关闭ServerSocket和Socket对象**：客户端访问结束，关闭通信套接字。

```
	@Test
	public void server() {
		ServerSocket server = null;
		Socket socket1 = null;
		BufferedReader bufferedReader = null;
		try {
			server = new ServerSocket(9999); // 本进程绑定了端口9999
			socket1 = server.accept(); // 此方法才会引起阻塞, 服务器进入等待状态, 一旦有客户端连接, 此方法就返回
			System.out.println(socket1); // 服务器端的socket对象
			InputStream inputStream = socket1.getInputStream();
			bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
			String readLine = bufferedReader.readLine();
			System.out.println("服务器 : " + readLine);
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (bufferedReader != null) {
				try {
					bufferedReader.close();
				} catch (Exception e2) {
				}
			}
			if (socket1 != null) {
				try {
					socket1.close();
				} catch (Exception e2) {
				}
			}
			
			if (server != null) {
				try {
					server.close();
				} catch (Exception e2) {
				}
			}
		}
	}
```

# java8新特性

## lambda（类型推断）

1. lambda用于代替匿名内部类对象
2. 省略new Xxx() {}, 方法的修饰符和返回值,方法名, **只保留形参列表和方法体, 中间用转向符 -> 隔开**
3. Lambda表达式只适用于接口中只有一个抽象方法, 并且方法体就是一句话的情况.
4. 参数只有一个时, 可以省略(), 方法体中如果只有一个语句时, { }也可以省略
5. 如果返回值就是一行时, return也省略

```
	@Test
	public void test6() {
		// 使用Lambda表达式 完成比较器, 比较两个字符串的长度
		// 使用匿名内部类
		Comparator<String> comparator = new Comparator<String>() {
			@Override
			public int compare(String o1, String o2) {
				return o1.length() - o2.length();
			}
		};
		
		// 使用lambda
		Comparator<String> comparator2 = (o1, o2) -> o1.length() - o2.length();
		System.out.println(comparator2.compare("abcd", "yyy322"));
	}
```

## 函数式接口

### 定义

* 函数式接口 : 只有一个抽象方法的接口
* 使用 `@FunctionalInterface` 注解，这样做可以检查它是否是一个函数式接口
* 在`java.util.function`包下定义了java 8 的丰富的函数式接口

### 作用

* 是对方法的行为模式进行抽象, 有参无参? 有返回还是无返回, 返回什么?

### Java内置四大核心函数式接口

1. `Consumer<T>` : **消费器** 通过它可以消费一个T类型的对象, 并没有返回

   ​		`void accept(T t)` => 有参无返回.  有1个输入没有输出

2. `Supplier<T>` : **供给器** 通过它可以获取一个T类型的对象

   ​		`T get()` => 无参有返回. 没有输入有输出

3. `Function<T, R>` : **转换器** 把T类型的对象转换为R类型的对象

   ​		`R apply(T t)` => 有参有返回, 既有输入也有输出

4. `Predicate<T>` : **判定器** 判定T类型对象是否满足某种条件

   ​		`boolean test(T t)` => 有参有返回, 有输入有输出(输出固定是布尔) 

### 方法引用

 * 接口中的方法模式和lambda体中的方法的模式完全一致时, 就可以使用方法引用
 * 类::方法名 

## 强大的Stream API

* 使用Stream API 对集合数据进行操作，就类似于使用 SQL 执行的数据库查询。
* 

### 特点

1. Stream 不是集合，自己不会存储元素。
2. Stream是数据的处理，并不保存数据，**Stream只能用一次**
3. Stream 不会改变源对象。相反，他们会返回一个持有结果的新Stream。
4. **Stream 操作是延迟执行的**。必须搞清楚有哪些数据才能往下执行，这意味着他们会等到需要结果的时候才执行。
5. Stream只能“消费”一次，如果想继续做其他操作，需要重新获取stream对象
6. 更像一个高级的iterator，单向，不可往复，数据只能遍历一次，遍历过一次后即用尽了，但是可以并行化数据！

### Stream的操作三个步骤

![https://github.com/kocdaniel/BigData/blob/master/img/%E6%B5%81%E6%93%8D%E4%BD%9C%E7%9A%84%E4%B8%89%E4%B8%AA%E6%AD%A5%E9%AA%A4.png](https://github.com/kocdaniel/BigData/blob/master/img/流操作的三个步骤.png)

1. **创建Stream**： 一个数据源（如：集合、数组），获取一个流
   * 1) 基于集合获取流 ：集合对象.stream()
   * 2) 基本数组获取流 ： Arrays.stream(数组对象)
   * 3) 基于散列数据 ： Stream.of(T... 对象列表)
   * 4) 其他 ： Stream.generate(Supplier sup); 无限流

```
	@Test
	public void test4() {
		// 无限流
		Stream<Double> generate = Stream.generate(Math::random);
		generate.forEach(System.out::println);
	}
	
	// 基于散列数据
	@Test
	public void test3() {
		Stream<String> of = Stream.of("ac", "xx", "293", "alksj");
		of.forEach(System.out::println);
	}
	
	// 基于数组获取流
	@Test
	public void test2() {
		Integer[] arr = {3, 2, 1, 0, 9, 8};
		Stream<Integer> stream = Arrays.stream(arr);
		stream.forEach(System.out::println);
	}
	
	// 基于集合获取流
	@Test
	public void test1() {
		List<Student> list = StudentData.getList();
		Stream<Student> stream = list.stream();
		
		stream.forEach(System.out::println);
	}
```



2. **中间操作**： 一个中间操作链，对数据源的数据进行处理（(可以有多个, 一系列的操作)）
   * `filter(判定器)` ： 把流中的所有对象都经过判定器, 如果判定结果为true, 留下.
   * `distinct()` ： 去重, 依据是equals和hashCode
   * `limit(long maxSize)` ： 截断流
   * `skip(long n)`：  略过n个元素, 通常会和limit配合.
   * `map(转换器)` ：把流中的所有对象都经过转换器转换成另外的对象.
3. **终止操作**： **一旦执行终止操作，就执行中间操作链，并产生结果**；之后，不会再被使用
   * `forEach(消费器)` ： 把流中的所有对象都经过消费器.
   * `reduce(二元运算)` ： 把流中的对象两两处理产生新对象,依次再和后面的对象两两处理. 最终的结果就一个.
   * `collect(整理器)` 

* **备注：**map 和 reduce 的连接通常称为map-reduce 模式，因 Google 用它来进行网络搜索而出名。

### Optional 

 * Optional 避免空指针 , 内部使用属性保存一个引用
 * 调用`orElse`方法可以避免空指针 
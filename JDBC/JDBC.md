# JDBC（面向接口编程）

* **JDBC(Java Database Connectivity)**是一个独立于特定数据库管理系统**、**通用的SQL数据库存取和操作的**公共接口**（一组API），定义了用来访问数据库的标准Java类库，（java.sql,javax.sql）使用这个类库可以以一种标准的方法、方便地访问数据库资源

![1566557385616](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1566557385616.png)

![1566557418439](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1566557418439.png)

![1566557519703](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1566557519703.png)

## 加载mysql的driver

1. 在项目中创建目录lib，里面准备保存一些jar文件
2. 把mysql-connector-java-5.1.7-bin.jar文件复制到lib目录下
3. 右击.jar文件，在弹出的菜单中选择build-path -> add to build path, jar文件变为小奶瓶
4. 加入build-path的目的是可以直接使用jar文件中的所有类

## 建立连接

```java
jdbc:mysql://127.0.0.1:3306/test
// jdbc是主协议，
// mysql是子协议，
// localhost是mysql服务器主机名称，
// 3306是mysql服务器的端口，
// test是默认的登录的数据库名
```



### 硬编码方式

```java
@Test
public void test1() throws SQLException { // 硬编码
	Driver driver = new com.mysql.jdbc.Driver();
	String url = "jdbc:mysql://127.0.0.1:3306/jdbc";
	Properties info = new Properties(); // 可将user和password放到属性文件中
	info.setProperty("user", "root");
	info.setProperty("password", "123456");
	Connection connect = driver.connect(url, info);
	System.out.println(connect);
	connect.close(); // 关闭资源
}
```
### 软编码方式

```java
@Test
public void test3() throws SQLException, Exception {// 软编码
	Class<Driver> clazz = (Class<Driver>) Class.forName("com.mysql.jdbc.Driver");
	Driver driver = clazz.newInstance();
	
	DriverManager.registerDriver(driver);// 注册
	String url = "jdbc:mysql://127.0.0.1:3306/jdbc";
    // DriverManager的getConnection方法建立到数据库的连接
	Connection connection = DriverManager.getConnection(url, "root", "123456");
	System.out.println(connection);
}
```
但是Driver类中已经静态注册过了

```java
// public class Driver
static {
	try {
        // 所以在类加载的时候就注册好了，所以不需要我们手动加载了
		java.sql.DriverManager.registerDriver(new Driver());
	} catch (SQLException E) {
		throw new RuntimeException("Can't register driver!");
	}
}
```
### 封装连接

```java
// url等都放到jdbc.properties的属性文件中
// driverClass = com.mysql.jdbc.Driver
// jdbcUrl = jdbc:mysql://127.0.0.1:3306/jdbc
// user = root
// password = 123456
public class JdbcUtil {

	public static Connection getConnection() throws IOException, ClassNotFoundException, SQLException {
		InputStream inputStream = JdbcUtil.class.getClassLoader().getResourceAsStream("jdbc.properties");
		Properties properties = new Properties();
		properties.load(inputStream);
		inputStream.close();
		
		String driverClass = properties.getProperty("driverClass");
		Class.forName(driverClass);
		String jdbcUrl = properties.getProperty("jdbcUrl");
		String user = properties.getProperty("user");
		String password = properties.getProperty("password");
		
		Connection connection = DriverManager.getConnection(jdbcUrl, user, password);
		return connection;
	}
	
	public static void close(Connection connection) {
		if(connection != null) {
			try {
				connection.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
    
    public static void close(Connection connection, Statement prepareStatement) {
        if(prepareStatement != null) { // prepareStatement也需要关闭
            try {
                prepareStatement.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        if(connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
```



### Statement

* 一旦获取了连接对象Connection, 还不可以执行SQL, 必须要从Connection连接对象获取执行体对象Statement才能执行SQL

```java
// 调用createStatement()
Statement state = connection.createStatement();
// 调用executeUpdate()，返回执行增删改后对表产生的影响的记录数
int n = state.executeUpdate(“insert,update,delete…”);
```

### SQL注入攻击

* SQL 注入是利用某些系统没有对用户输入的数据进行充分的检查，而在用户输入数据中注入非法的SQL 语句段或命令``(如：SELECT user, password FROM user_table WHERE user='a' OR 1 = ' AND password = ' OR '1' = '1')` ，从而利用系统的SQL 引擎完成恶意行为的做法

### PreparedStatement

* 要防范 SQL 注入，只要用 PreparedStatement(从Statement扩展而来) 就可以了取代Statement 
* 效率高

```java
	// preparedStatement
	@Test
	public void test6() {
		Connection connection = null;
		try {
			connection = JdbcUtil.getConnection();
			System.out.println(connection);
			String sql = "inset into user (username, password) values (?, ?)";
			PreparedStatement prepareStatement = connection.prepareStatement(sql);
			// 替换?
			prepareStatement.setString(1, "zhangsan"); // 把第一个问号替换为zhangsan
			prepareStatement.setString(2, "123456");
			int rows = prepareStatement.executeUpdate();
			System.out.println(rows + "rows");
			
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			JdbcUtil.close(connection, prepareStatement);
		}
	}
```


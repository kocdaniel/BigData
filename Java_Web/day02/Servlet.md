# Servlet

## 什么是Servlet

* **宏观**：Servlet是Sun公司制定的一套技术标准，包含与Web应用相关的一系列**接口**，是Web应用实现方式的宏观解决方案，而具体的Servlet容器负责提供标准的实现。
* **微观**：Servlet作为服务器端的一个组件，它的本意是“服务器端的小程序”。**Servlet的实例对象由Servlet容器负责创建；Servlet的方法由容器在特定情况下调用；Servlet容器会在Web应用卸载时销毁Servlet对象的实例。**
* **简单来说**： Servlet就是用来处理客户端的请求的

## Servlet开发规则

* 实际编码通过继承HttpServlet来完成Servlet的开发（**最终创建Servlet的方式**）

```java
public class AutoServlet extends HttpServlet {
	// 处理get请求
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws 																			ServletException, IOException {
		System.out.println("get方法被调用");
	}

	// 处理post请求
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws 																			ServletException, IOException {
		System.out.println("post方法被调用");
	}
}
```

## Servlet类的相关方法

1. `doGet`   Servlet中用于处理get请求的方法

2. `doPost`  Servlet中用于处理post请求的方法

   注意：①      在Servlet的顶层实现中，在service方法中调用的具体的doGet或者是doPost

   ​		   ②      在实际开发Servlet的过程中，可以选择重写doGet以及doPost  或者 直接重写service方法来处理请求。

## Servlet在web.xml中的配置

```xml
  <!-- 注册ervlet -->
  <servlet>
  	<!-- 给Servlet起一个名称，作为唯一的标识，可以任意指定，通常以实现类的类名作为Servlet的名字 -->
    <servlet-name>HelloServlet</servlet-name>
    <!-- 配置Servlet实现类的全类名，Servlet容器会利用反射帮我们创建对象 -->
    <servlet-class>com.atguigu.servlet.HellowServlet</servlet-class>
  </servlet>
  
  <!-- 映射Servlet -->
  <servlet-mapping>
    <servlet-name>HelloServlet</servlet-name>
    <!-- 映射请求地址，请求地址可以任意指定，指定的是什么，将来在浏览器地址栏输入的就是什么 
    例如配置的请求是/HelloServlet，那么处理的请求就是:http://localhost:8080/Web_Servlet/HelloServlet
    	"/":不要丢
    -->
    <url-pattern>/HelloServlet</url-pattern>
  </servlet-mapping>
```

## request的作用

1. 获取请求参数

```java
	String username = request.getParameter("username");
	String password = request.getParameter("password");
	System.out.println(username);
	System.out.println(password);
```
2. 获取项目的虚拟路径

```java
String contextPath = request.getContextPath();
System.out.println(contextPath);
```

3. 转发

```java
// 获取转发器
RequestDispatcher requestDispatcher = request.getRequestDispatcher("beautiful.html");
// 进行请求的转发
requestDispatcher.forward(request, response);
```

## response的作用

1. 给浏览器响应一个字符串或一个页面

```java
PrintWriter writer = response.getWriter();
// 响应一个字符串
writer.write("响应成功！");
// 响应一个页面
writer.write("<!DOCTYPE html>");
writer.write("<html>");
writer.write("<head>");
writer.write("<meta charset=\"UTF-8\">");
writer.write("<title>Insert title here</title>");
writer.write("</head>");
writer.write("<body>");
writer.write("<h1>我是一个非常漂亮的页面！</h1>");
writer.write("</body>");
writer.write("</html>");
```

2. 重定向

```java
// 响应beautiful.html页面
response.sendRedirect("WEB-INF/beautiful.html");
```



## 请求和响应中文乱码的解决方案

## 请求中文乱码的解决方案

### GET请求

* 在Tomcat的配置文件`server.xml`中的第一个`Connector`标签中添加属性`URIEncoding="UTF-8"`

### POST请求

* 在**第一次获取请求参数之前**设置字符集为UTF-8

```java
request.setCharacterEncoding("UTF-8");
```

## 响应中文乱码的解决方案

* 在**获取流之前**设置响应内容的类型及字符集

```java
response.setContentType("text/html;charset=UTF-8");
```

## 转发和重定向的区别

1. 本质区别：**转发发送一次请求；重定向发送两次请求**
2. 转发浏览器地址栏地址无变化；重定向浏览器地址栏地址有变化
3. 转发可以访问WEB-INF目录下的资源；重定向不可以访问WEB-INF目录下的资源
4. 转发可以共享request域中的数据；重定向不可以共享request域中的数据

## 服务器端的绝对路径

### 什么是绝对路径

* 以 / 开头的为绝对路径

### / 代表的意义

* 如果路径由浏览器解析，那么 / 代表 http://localhost:8080/
  * 以下路径由浏览器解析：
    1. HTML标签中的路径，如超链接a标签和link标签中的href属性中的路径，form标签中action属性中的路径等
    2. 重定向中的路径

* 如果路径由服务器解析，那么 / 代表 http://localhost:8080/项目名称/
  * 以下路径由服务器解析：
    1. web.xml 配置文件中url-pattern标签中的路径
    2. 转发中的路径

### 相对路径变为绝对路径

* base标签中的href属性可以让当前页面中所用的相对路径变为绝对路径




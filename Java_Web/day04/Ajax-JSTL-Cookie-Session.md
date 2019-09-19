# Ajax

## 定义

* AJAX 是Asynchronous JavaScript And XML 的简称。直译为，异步的JS和XML
* AJAX的实际意义是，**不发生页面跳转、异步载入内容并改写页面内容**的技术
* AJAX也可以简单的理解为通过JS向服务器发送请求

## 通过$.ajax()方法发送Ajax请求

```JSP
$.ajax(url,[settings])

url：必须的。用来设置请求地址
settings中的选项
type：可选的。用来设置请求方式，默认是GET
data：可选的。用来设置请求参数
success：可选的。用来设置一个回调函数，当响应成功之后，系统会自动调用该函数，
响应数据会以参数的形式传入到该函数中
dataType：可选的。用来设置响应数据的类型，如：text、json等		
```

```JSP
$.ajax({
    url:"${pageContext.request.contextPath }/AjaxServlet",
    type:"get",
    data:"username=admin&password=123456",
    success:function(res){
    //将响应信息设置到span标签中
    $("#msg").text(res);
    },
    dataType:"text"
});
```

## 通过$.get()/post()方法发送Ajax请求

```java
$.get/post(url, [data], [callback], [type])

url：必须的。用来设置请求地址
data：可选的。用来设置请求参数
callback：可选的。用来设置一个回调函数，当响应成功之后，系统会自动调用该函数，
响应数据会以参数的形式传入到该函数中
type：可选的。用来设置响应数据的类型	
```

```java
//设置请求地址
var url = "${pageContext.request.contextPath }/AjaxServlet";
//设置请求参数
var params = "username=zhangsan&password=111111";
$.get(url,params,function(res){
	//设置到span标签中
	$("#msg2").html(res);
},"text");
```



# JSTL

## 定义

* JSTL全称：JSP Standard Tag Library，JSP的标准标签库

## 导包

```
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"  %>
```



## if标签

* 相当于Java中的if条件判断语句
* **test属性**：接收一个布尔类型的值，当值是true时才执行标签体中的内容，通过该值通过一个EL表达式获取

### 示例

```java
<%
    int age = 87;
    pageContext.setAttribute("age", age);
%>
<c:if test="${age < 18 }">
    少儿不宜！
</c:if>
<c:if test="${age > 18 }">
    请尽情浏览，注意身体！！！
</c:if>
```

### empty运算符

* 主要用来判断一个字符串或一个集合是否为空 

* 非空的表示方式：!empty 或者 not empty

## forEach标签

* 相当于Java中的for循环 
* **items属性**：接收一个要遍历的集合
* **var属性**：指定一个变量接收遍历到的值，并以变量值为key放到**page域**中

### 示例

```java
<%
    List<String> list = new ArrayList();
    list.add("苍井空");
    list.add("小泽玛利亚");
    list.add("波多野结衣");
    list.add("武藤兰");
    list.add("吉泽明步");
    list.add("泷泽萝拉");
    list.add("马蓉");
    list.add("白百何");
    list.add("李小璐");
    //将list放到page域中
    pageContext.setAttribute("stars", list);
%>

<c:forEach items="${stars }" var="star">
	<a href="#">${pageScope.star }</a><br>
</c:forEach>

<c:if test="${empty stars }">
	世界很美好！
</c:if>
<c:if test="${!empty stars }">
	世界不美好，明星胡乱搞！
</c:if>
```



# Cookie

## Cookie的运行原理

1. 第一次向服务器发送请求时在服务器端创建一个Cookie对象
2. 将Cookie对象发送给浏览器
3. 以后再发送请求就会携带着该Cookie对象
4. 服务器根据不同的Cookie对象区分不同的用户

## 创建Cookie对象

* `Cookie cookie = new Cookie("user", "admin");`
* `setMaxAge(Int age)`：通过setMapAge设置Cookie对象的有效时间
  * age > 0 ：Cookie对象在age秒后失效
  * age = 0：Cookie对象立即失效
  * age < 0：默认，**会话级别**的Cookie对象
* `setPath(path)`：设置Cookie对象的有效路径，默认的有效路径是当前项目的根目录；有效路径是指访问哪些页面时浏览器会携带cookie
* `addCookie(cookie)`：将Cookie对象发送给浏览器

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		//1.创建Cookie对象
		//Cookie的名字不能使用中文，Cookie的值可以使用中文，但是需要指定字符集进行编码，获取Cookie时还需要指定字符集进行解码，所以不建议使用中文
		Cookie cookie = new Cookie("user", "admin");
		//创建Cookie对象
		Cookie cookie2 = new Cookie("user2", "persistCookie");
		/*
		 * 可以通过setMapAge设置Cookie对象的有效时间
		 * 	setMaxAge(Int age)
		 * 
		 * age > 0 ：Cookie对象在age秒后失效
		 * age = 0：Cookie对象立即失效
		 * age < 0：默认，会话级别的Cookie对象
		 */
		cookie2.setMaxAge(-1);
		//创建Cookie对象
		Cookie cookie3 = new Cookie("user3", "pathCookie");
		//设置Cookie对象的有效路径，默认的有效路径是当前项目的根目录
		cookie3.setPath(request.getContextPath()+"/hello");
		//2.将Cookie对象发送给浏览器
		response.addCookie(cookie);
		response.addCookie(cookie2);
		response.addCookie(cookie3);
	}
```

## 获取cookie对象

* `getCookies()`：返回一个包含cookie对象的数组
* `cookie.getName()`：获取cookie的名字
* `cookie.getValue()`：获取cookie的值

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response)
														throws ServletException, IOException {
    //获取所有的Cookie对象
    Cookie[] cookies = request.getCookies();
    if(cookies != null) {
    //遍历得到每一个Cookie对象
        for (Cookie cookie : cookies) {
            //获取Cookie的名字
            String name = cookie.getName();
            //获取Cookie的值
            String value = cookie.getValue();
            System.out.println("Cookie对象的名字是："+name);
            System.out.println("Cookie对象的值是："+value);
        }
    }
}
```



# Session

## Session的运行原理

1. 第一次向服务器发送请求时在服务器端创建一个Session对象，该对象有一个全球唯一的ID
2. 在创建Session对象的同时会创建一个特殊的Cookie对象，该Cookie对象的名字是一个固定值：JSESSIONID，该Cookie对象的值就是那个Session对象的ID值，并将该Cookie对象发送给浏览器
3. 以后浏览器再发送请求就会携带着这个特殊的Cookie对象
4. 服务器获取Cookie对象的值后，寻找与之对应的Session对象，以此来区分不同的用户

* **JSP文件有一个默认的session**

## 创建或获取session对象

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws 																				ServletException, IOException {
    //创建或获取Session对象
    HttpSession session = request.getSession();
    //获取Session对象的ID	
    String id = session.getId();
    System.out.println("Session对象的ID值是："+id);
    //创建一个用户
    User user = new User(1, "admin");
    //向session域中添加一个用户
    session.setAttribute("user", user);
}
```

## 设置名字为JSESSIONID的Cookie对象的有效时间

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws 																				ServletException, IOException {
    //获取Cookie对象
    Cookie[] cookies = request.getCookies();
    if(cookies != null) {
        for (Cookie cookie : cookies) {
            //获取Cookie的名字
            String name = cookie.getName();
            if("JSESSIONID".equals(name)) {
                //设置该Cookie对象的有效时间
                cookie.setMaxAge(60);
                //将该Cookie对象发送给浏览器
                response.addCookie(cookie);
            }
        }
    }
}
```


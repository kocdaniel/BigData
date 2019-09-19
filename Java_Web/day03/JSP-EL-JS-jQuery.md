# JSP页面

## 定义

* JSP全称Java Server Pages，顾名思义就是运行在java服务器中的页面，也就是在我们JavaWeb中的动态页面，其**本质就是一个Servlet**。
* 其本身是一个动态网页技术标准，它的主要构成有HTML网页代码、Java代码片段、JSP标签几部分组成，后缀是.jsp
* 相比于Servlet，JSP更加善于处理显示页面，而Servlet跟擅长处理业务逻辑，两种技术各有专长，所以一般我们会将Servlet和JSP结合使用，Servlet负责业务，JSP负责显示。
* 一般情况下， 都是Servlet处理完的数据，转发到JSP，JSP负责显示数据的工作

## JSP脚本片段

### 作用

* 在里面写Java代码

### 格式

```JSP
<%
	System.out.println("hello world!");
%>
```

## JSP表达式

### 作用

* 用来输出对象

### 格式

```JSP
<%="我是通过JSP表达式输出的"%>
```

## JSP注释

```JSP
<%-- "我是JSP注释" --%>
```

## JSP隐含对象

```JSP
out（JspWriter）：相当于response.getWriter()获取的对象，用于在页面中显示信息。
config（ServletConfig）：对应Servlet中的ServletConfig对象。
page（Object）：对应当前Servlet对象，实际上就是this。
* pageContext（PageContext）：当前页面的上下文，也是一个域对象。
exception（Throwable）：错误页面中异常对象（在错误页面中才有）
* request（HttpServletRequest）：HttpServletRequest对象
response（HttpServletResponse）：HttpServletResponse对象
* application（ServletContext）：ServletContext对象
* session（HttpSession）：HttpSession对象
```

* JSP有一个比较特殊的隐含对象：**pageContext**，它一个顶九个，通过它可以获取其他八个隐含对象

## 四个域

### page域

1. 范围：当前页面
2. 对应的域对象：pageContext
3. 域对象类型：pageContext

### request域

1. 范围：当前请求（一次请求）
2. 对应的域对象：request
3. 域对象类型：HttpServletRequest

### session域

1. 范围：当前会话（一次会话）
2. 对应的域对象：session
3. 域对象类型：HttpSession

### application域

1. 范围：当前web应用
2. 对应的域对象：application
3. 域对象类型：ServletContext

### 四个域对象都有的三个方法

```
1. void setAttribute(String key, Object value);
2. Object getAttribute(String key);
3. void removeAttribute(String key);
```

### 四个域的使用规则

* 能用小的就不用大的

### 向四个域中分别添加四个属性

```JSP
<!-- scope.jsp页面 -->
<!-- 向四个域中分别添加四个属性 -->
<%
    pageContext.setAttribute("pageKey", "pageValue");
    request.setAttribute("reqKey", "reqValue");
    session.setAttribute("sessKey", "sessValue");
    application.setAttribute("appKey", "appValue");
%>
<h1>在当前页面中获取四个域中的属性值</h1>
page域中的属性值是：<%=pageContext.getAttribute("pageKey") %><br>
request域中的属性值是：<%=request.getAttribute("reqKey") %><br>
session域中的属性值是：<%=session.getAttribute("sessKey") %><br>
application域中的属性值是：<%=application.getAttribute("appKey") %><br>

<!-- 转发到scope2.jsp页面 -->
<!-- 转发到scope2.jsp页面， page属性值不可以获取-->
<%-- 	 <jsp:forward page="/scope2.jsp"></jsp:forward> --%>

<!-- 跳转到scope2.jsp页面 -->
<!-- 跳转到scope2.jsp页面， request属性值不可以获取，因为不是一次请求-->
<a href="/Web_JSP/scope2.jsp">去scope2.jsp</a>

<!-- 关闭浏览器再次进入（即结束一次会话）， session属性值不可以获取 -->
<!-- 重启服务器（即结束一次web应用，application属性值不可以获取） -->
```

```JSP
 <!-- scope.jsp页面 -->
 <h1>在scope2.jsp页面中获取四个域中的属性值</h1>
 page域中的属性值是：<%=pageContext.getAttribute("pageKey") %><br>
 request域中的属性值是：<%=request.getAttribute("reqKey") %><br>
 session域中的属性值是：<%=session.getAttribute("sessKey") %><br>
 application域中的属性值是：<%=application.getAttribute("appKey") %><br>
```
# EL表达式（Expression Language）

## 定义

* 表达式语言

1. EL是JSP内置的表达式语言，用以访问页面的上下文以及不同作用域中的对象 ，取得对象属性的值，或执行简单的运算或判断操作。EL在得到某个数据时，会自动进行数据类型的转换。
2. **EL表达式用于代替JSP表达式(<%= %>)在页面中做输出操作。**
3. EL表达式仅仅用来读取数据，而不能对数据进行修改。
4. 使用EL表达式输出数据时，**如果有则输出数据，如果为null则什么也不输出**。

## 作用

* 用来获取域对象中的属性值

## 格式

```EL
${表达式}
```

## EL表达式查找的规则

* 先从page域中开始查找，找到后直接返回，不再向其他域中查找，如果page域中找不到再去request域中查找，以此类推...如果最后在application域中也找不到，则什么也不输出

## 四个Scope对象

* 用来精确获取指定域中的属性值

1. pageScope : 获取page域中的属性值
2. requestScope : 获取request域中的属性值
3. sessionScope : 获取session域中的属性值
4. applicationScope : 获取application域中的属性值

## 通过EL表达式获取JavaBean对象的属性值

* 通过**对象.属性名**的方式获取，**调用的是属性对应的get方法**
* **注意**：pageContext对象既是EL隐含对象，也是JSP的隐含对象		

```JSP
<%
    Date date = new Date();
    //将当前时间放到域对象中
    pageContext.setAttribute("time", date+"-");
    request.setAttribute("time", date+"--");
    session.setAttribute("time", date+"---");
    application.setAttribute("time", date+"----");
    //创建Employee对象
    Employee employee = new Employee(1,"佟刚",new Department(1001,"指挥部"));
    //将Employee对象放到page域中
    pageContext.setAttribute("emp", employee);
%>
通过JSP表达式输出当前时间：<%=date %><br>
<-- 获取的是page域中的对象：date- -->
通过EL表达式输出当前时间：${time }<br>
<-- 获取特定域中的对象：使用特定的域对象 -->
通过EL表达式获取request域中的时间：${requestScope.time }<br>
通过El表达式获取Employee对象的lastName属性值：${emp.lastName }<br>
通过El表达式获取Employee对象的dept属性的name属性值：${emp.dept.name }<br>
通过EL表达式获取Employee类中getTime方法的返回值：${emp.time }<br>
通过JSP表达式获取项目的虚拟路径：<%=request.getContextPath() %><br>
通过EL表达式获取项目的虚拟路径：${pageContext.request.contextPath }
```

# JavaScript & jQuery

## 定义

* 脚本语言
* 弱类型
* 基于对象
* 动态性
* 跨平台：不依赖操作系统，仅需要浏览器的支持

## 编写位置

1. 编写到HTML中的<script>标签中
2. 写在外部的.js文件中，然后通过<script>标签的src属性引入

## JavaScript的事件驱动

1. 用户事件：用户操作，例如单机，鼠标移入，鼠标移出等

2. 系统事件：由系统触发的事件，例如文档加载完成

3. 常用的事件：

   ```
   onload 加载
   
   onclick 点击
   
   onblur 失去焦点
   
   onfocus 获得焦点
   
   onmouseover 鼠标移入
   
   onmouseout 鼠标移出
   ```

## 元素查询

| **功能**           | **API**                                 | **返回值**         |
| ------------------ | --------------------------------------- | ------------------ |
| 根据id值查询       | document.getElementById(“id值”)         | 一个具体的元素节点 |
| 根据标签名查询     | document.getElementsByTagName(“标签名”) | 元素节点数组       |
| 根据name属性值查询 | document.getElementsByName(“name值”)    | 元素节点数组       |

## JavaScript代码示例

```HTML
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<!-- JavaScript代码需要写在script标签中 -->
<script type="text/javascript">
	//当文档加载完成之后再执行函数中的内容
	window.onload = function(){
		//获取按钮对象
		var btnEle = document.getElementById("btnId");
		//给按钮绑定单击事件
		btnEle.onclick = function(){
			//弹出提示框
			alert("Hello JavaScript!");
		};
	};
</script>
</head>
<body>
	<button id="btnId">Say Hello</button>
</body>
</html>
```

## jQuery代码示例

```html
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<!-- 使用jQuery需要引入jQuery的库 -->
<script type="text/javascript" src="js/jquery-1.7.2.js"></script>
<script type="text/javascript">
	//当文档加载完成之后再执行函数中的内容
	//相当于window.onload = function(){};
	$(function(){
		//获取按钮对象并给它绑定单击事件
        //根据id选择器获取id名
		$("#btnId").click(function(){
			//弹出提示框
			alert("Hello jQuery!");
		});
	});
</script>
</head>
<body>
	<button id="btnId">Say Hello</button>
</body>
</html>
```


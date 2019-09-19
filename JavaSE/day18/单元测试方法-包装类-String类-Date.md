# 单元测试方法

* **@Test**

  注解 , 是第三方库的功能, 所以必须要引入才可以

* **注意点 :** 

  * 测试方法所在的类必须是公共类
  * 类中不允许有构造器
  * 测试方法必须是公共无返回值无参的实例方法
  * 要执行哪个测试方法, 需要让光标定位在方法名上. 然后再运行





# 包装类（Wrapper）

* **作用**：就是把基本型数据包装为对象类型.

* **如何包装：** 使用构造器

  ```
  Integer obj1 = new Integer(100); // 手工装箱
  // 自动装箱 , 编译器改造成 new Integer(200) 
  Integer obj2 = 200; 
  		
  int n1 = obj1.intValue(); // 手工拆箱
  // obj2本身是引用,  编译器改造成 int n2 = obj2.intValue();
  int n2 = obj2; 
  ```


* **一些方法**

  * **把字符串变成相应的基本值的方法**:  `Xxx.parseXxx("xxx") -> xxx` 

    如：

    ```
    String string = "234.23";
    double parseDouble = Double.parseDouble(string);
    ```

    

  * **装箱** ： `new Xxx(xxx), new Xxx("xxx"), Xxx.valueOf("xxx"), Xxx.valuedOf(xxx)`

    ```
    String s2 = "890";
    // Integer.decode(s2);//new Integer(s2);
    Integer obj2 = Integer.valueOf(s2);
    ```

  * **拆箱** : `xxx.xxxValue()`

    ```
    // intValue()
    String s1 = "234";
    int n = Integer.parseInt(s1);
    Integer obj1 = new Integer(n);
    System.out.println(obj1.intValue());
    ```

    



# 字符串（最重要的类）

 * **字符串 :** 

   * 内容不可改变的Unicode字符序列, 可以看作是一个字符数组.
   * 里面的方法不会修改内容,  任何的修改的方法都会产生新的对象, 而不是修改原内容

* **重要方法：**

* ```
   有如下字符串：
    *                 2  5    10   15      20       26       32      40 42
   String string = "  abcQQyy 1234 我喜欢你,你喜欢我吗?我不喜欢你 QQQYYYzzz  ";
   
   // 获取字符串长度, 字符个数, string.length() -> 43
   *public int length() 
   
   // 获取参数中指定的下标位置处的字符 string.charAt(7) -> 'y', string.charAt(25)
   *public char charAt(int index) 
   
   // 返回一个字符数组, 是内部字符数组的副本
   *public char[] toCharArray() 
   
   // 字符串比较内容
    public boolean equals(Object anObject) 
    
   // 字符串比大小 
    public int compareTo(String anotherString) 
    
   // 获取参数中的子串在本串中首次出现的下标值, 如果返回-1表示不包含子串  
   // string.indexOf("喜欢") -> 16
    **public int indexOf(String s)
    
   // 第二个参数作用是控制开始搜索的下标
   // string.indexOf("喜欢", 17) -> 21
   // string.indexOf("喜欢", 22) -> 28
    public int indexOf(String s ,int startpoint) 
    					
   // 获取参数中的子串在本串中首次出现的下标值, 是从右向左搜索的.
   // string.lastIndex("喜欢") -> 28  					
    public int lastIndexOf(String s) 
    
   // string.lastIndexOf("喜欢", 27) -> 21
   // string.lastIndexOf("喜欢", 20) -> 16 					
    public int lastIndexOf(String s ,int startpoint)
   
   // 判断当前串是否以子串为开始 string.startsWith("abcQQ") -> true
    public boolean startsWith(String prefix) 
    
   // 判断当前串是否以子串为结束, 检查文件名,作类型判断.  
    public boolean endsWith(String suffix) 
    
   // 截取子串, start是开始下标(包含), end是结束下标(不包含) 
   // string.substring(15, 19) -> "我喜欢你" 
    **public String substring(int start,int end) 
    
   // 截取子串, 从start开始到最后 
    public String substring(int startpoint) 
    
   // 把字符串中的所有oldChar替换为newChar
    public String replace(char oldChar,char newChar) 
    
   // 把字符串中的所有old子串替换为new子串 
    *public String replaceAll(String old,String new) 
    
   // 修剪字符串首尾的空白字符(码值小于等于32的字符)
    *public String trim() 
    
    public String concat(String str)
    
    public String toUpperCase() 全部变大写
    
    public String toLowerCase() 全部变小写
    
   // 以参数中的字符串为切割器, 把字符串切割成多个部分 
    public String[] split(String regex) 
    
   // 第一个参数是源数组, 第二个参数是源数组的开始下标
   // 第三个参数是目标数组, 第四个参数是目标数组的要复制的开始下标, 第五个参数是要复制的元素个数
    System.arraycopy(value, 0, result, 0, value.length); 
  ```

  

# StringBuilder 和 StringBuffer

```
- StringBuffer是内容可以改变的Unicode字符序列
- StringBuffer append(...) 可以追加任意数据到字符串末尾 
- StringBuffer insert(int index, ...) 可以把任意数据插入到指定下标处, 
- StringBuffer delete(int begin, int end) 删除区间 StringBuffer
- setCharAt(int index, char newChar) 替换指定下标处的字符
- StringBuilder默认内部数组长度是16, 扩容规则 : 老长度 * 2 + 2
- StringBuffer 效率低, 线程安全
- StringBuilder 效率高, 线程不安全
```



# Date

* **currentTimeMillis()**

```
// 获取当前ms数，从1970年1月1日00:00:00 GMT 开始记
long millis = System.currentTimeMillis();
System.out.println(millis);
```

* **SimpleDateFormat()**

```
Date date = new Date();
System.out.println(date);

// 模式,  "yyyy-MM-dd HH:mm:ss" 为要格式化为的格式，可以自己设置
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss"); 
// 将date格式化为"yyyy-MM-dd HH:mm:ss"格式
String string = sdf.format(date);
System.out.println(string2);

long millis = System.currentTimeMillis();
System.out.println(millis);

// 可以支持格式化毫秒.
String string3 = sdf.format(millis); // new Long(millis)
System.out.println(string3);

String string2 = "1998-08-02 11:22:58"; // 字符串的格式和模式必须匹配
// 把字符串解析为日期对象
date2 = sdf.parse(string2);
System.out.println(date2);
```

打印输出为：

```
Fri Aug 09 20:21:46 CST 2019
2019-08-09 20:21:46
1565353306785
2019-08-09 20:21:46
Sun Aug 02 11:22:58 CST 1998
```




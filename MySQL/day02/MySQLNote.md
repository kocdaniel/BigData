# MySQL

* 所有SQL都必须以;结尾
* 数据库在服务器以目录的形式保存,目录在 data 
* **数据库结构**

```mysql
服务器(Tcp) :
	数据库1(目录)
		表1(文件)
			列(字段)1
			列(字段)2
			.....
				数据(记录)
				记录2.....
		
		表2 
		表3
		....
	数据库2(目录)
	
客户端通过socket连接服务器
必须具备ip和端口
```

## DML (数据操纵语言)

* 数据的CRUD操作, 这些语句统称为DML (数据操纵语言)

* ```mysql
  select 
  insert 
  update 
  delete 
  ```

## DDL (数据定义语言)

* 数据库对象的相关操作, 创建, 修改, 丢弃, 这些语句统称为DDL (数据定义语言)

* ```mysql
  create 
  alter 
  drop
  ```

## DCL(数据控制语言)

```mysql
commit
rollback
```



## 登录

* 短选项:
  cmd > mysql -h服务器主机 -P端口号 -u用户名 -p密码

```mysql
cmd> mysql -uroot -p123456
```

* 长选项:
  cmd > mysql --host=服务器主机 --port=端口号 --user=用户名 --password=密码 默认工作数据库

* 必须使用TCP/IP方式 **-h host, -P port -p password -u user**

```
cmd> mysql -h127.0.0.1 -P3306 -uroot -p123456 
```

## 常用命令

### 跨库显示表名

```mysql
show tables from 库名;
```

### 查看服务器中有哪些数据库

```mysql
mysql> show databases;
```

### 创建新数据库

```mysql
mysql> create database company;
```

### 切换工作数据库

```mysql
mysql> use 新数据库名;
```

### 查看当前工作数据库

```mysql
select database();
```

### 查看当前工作数据库中的所有表

```mysql
show tables;
```

### 查看表结构

```mysql
desc 表名;
```

### 查看表的最详细的信息

```mysql
show create table 表名;
```

```mysql
CREATE TABLE `city` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` char(35) NOT NULL DEFAULT '',
  `CountryCode` char(3) NOT NULL DEFAULT '',
  `District` char(20) NOT NULL DEFAULT '',
  `Population` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `CountryCode` (`CountryCode`),
  CONSTRAINT `city_ibfk_1` FOREIGN KEY (`CountryCode`) REFERENCES `country` (`Code`)
) ENGINE=InnoDB AUTO_INCREMENT=4080 DEFAULT CHARSET=latin1 
```

* 有列的定义, 有约束的定义, 表的存储引擎, 字符集
  * **飘号(反引号)的作用**, 用于包围限定数据库对象的名称, 比如库名, 表名, 列名, 约束名....
* **InnoDB引擎** : 支持事务, 外键 等高级特性		缺点 : 速度较快
* **MyIsam引擎** : 不支持事务, 外键..				优点 : 速度快

### 查看引擎

```mysql
show engines;
```



### 从外部.sql文件中导入数据

```mysql
source d:\\mywork\\mysql\\company.sql; -- 文件目录
```

### 查看表中的所有数据

```mysql
select * from 表名;
```

## 建表

### 数据类型

```mysql
int  			整数
bigint 			大整数
double 			浮点数
decimal 		定点数
char(长度) 		定长字符串		效率高, 占空间
varchar(长度) 	变长字符串		最长:65535字节
longtext		长文本
date			日期
time 			时间
datetime		日期时间
timestamp		时间戳			相对于1970,1,1,0.0.0 秒数
```

```mysql
// 创建表示例,为了防止弹出表已存在的错误，可以加上 if not exists
create table if not exists teacher(
	id int auto_increment, // 自增
	name varchar(20) not null, // 非空
	age int,
	gender enum('男', '女') default '男',
	primary key(id) -- 表级主键
) charset gbk engine innodb;
```



### 修改表

#### 注意

* 更新的删除操作都应该加where过滤, 如果没有where,会导致影响所有记录..

#### 向已有的表中添加列

```mysql
alter table 表名 
add 新列名 数据类型(长度) 其他选项等.
```

#### 在指定列后面添加新列（after）

```mysql
alter table student 
add age int after name;
```

#### 在最前面添加新列（first）

```mysql
alter table student 
add idcard varchar(30) first;
```

#### 修改现有表中的列

```mysql
alter table 表名
modify 列名 新数据类型(新长度) 新其他选项
```

#### 重命名现有表中的列

```mysql
alter table 表名
change 老列名 新列名 新数据类型(新长度) 新选项
```

#### 丢弃现有表中的列

```mysql
alter table student
drop column gender;
```

#### 重命名表

```mysql
alter table 表名 
rename to 新表名;
```

#### 丢弃表

```mysql
drop table [if exists] 表名;
```

#### 清空表

```mysql
// DDL, 效率高, 没有后悔
truncate table 表名;
// DML, 效率低, 但是能后悔
delete from 表名; 
```



## 查询

* 查询结果是一个虚表

### 注意点: 

```mysql
SQL 语言大小写不敏感。 
SQL 可以写在一行或者多行
关键字不能被缩写也不能分行
各子句一般要分行写。
使用缩进提高语句的可读性。
"" 的作用是保持原样, 不做任何处理
```

### 去重 distinct

```mysql
select 
	distinct continent
from 
	country
order by 
	continent;
```



### 联接

* **内联接** :多张表中的记录最后只有满足联接条件的.
* **外联接** : 保证某张表的记录的完整性, 如果满足联接条件显示数据, 不满足联接条件的显示为null

### 单行函数 : 

* 作用于结果集中的每条记录都经过函数处理

* ```mysql
  select 
  	upper(name),
  	lower(name)
  from 
  	country;
  ```

### 取子串

```mysql
select 
	substr("helloworld", 2, 5);
```

### 字符串连接	

```mysql
查询国家名称和大洲及人口的拼接结果, 要求数据之间用->隔开
select 
	concat(concat(concat(concat(name, " -> "), continent), " -> "), population) infos
from 
	country ;
// 法二：	
select 
	concat(name, " -> ", continent, " -> ", population) infos
from 
	country;
```

### 组函数 :

* 作用于一组数据, 最后一个结果.本质上是统计运算.
* **标志：**各个, 每个
* 一旦分组了, 必须把分组依据的列放在select后面.

```mysql
SELECT 
	department_id,
	AVG(salary)
FROM     
	company.employees
GROUP BY 
	department_id ;
```

* 分组的列如果有多个, 那么 分组时以多个列的组合值为分组依据

```mysql
select
	continent,
	GovernmentForm,
	count(*)
from 
	country 
group by 
	continent,
	GovernmentForm;
```

### count()

* 效果就相当于获取表中的记录数
* 真正获取表中的记录的语句必须使用`count(*)`

### 查询结果排序

* order by : 一定是在最后执行

### 执行顺序 

* ```mysql
  from -> join -> on -> join -> on ... -> where -> select -> order by 
  ```

* ```mysql
  select 
  	常量,
  	变量,
  	表达式,
  	函数调用,
  	表1.列名1,
  	表2.列名2
  from 
  	表1 
  join 
  	表2 
  on
  	联接条件 
  left join 
  	表3 
  on 
  	联接条件 
  where 
  	普通的行过滤条件
  order by
  	虚表的列
  ```

### 过滤记录的语句

```mysql
on 
	联接条件 
where 
	基表的行进行普通过滤
having 
	分组结果的虚表进行过滤
```



### 总结 : 做一个SQL查询步骤

```mysql
1) from 确定基表
2) 一张表数据够吗? 如果不够join另外的表
3) 如果是join还要考虑内联还是外联
4) 只要有join则必须有on和联接条件
5) 是否需要大基表中的所有记录? 如果需要过滤, 使用where 
6) 是否需要分组, 如果要分组, 分组依据哪个列
7) 如果有分组, 第一时间就把分组的列放在select后面
8) 继续分析select要处理哪些列和计算
9) 如果有分组, 并且要对分组的结果集再过滤, 再使用having 过滤虚表
10)是否对最终的显示有排序需求, 如果有使用order by , 升序还是降序?
```

### 子查询

* 解决需要两次查询解决的问题.
* 如果子查询用于where条件, 它的查询的虚表的列必须一列, 行通常也是一行.

```mysql
查询人均寿命最高的国家
select 
	continent,
	name,
	lifeexpectancy
from 
	country 
where 
	lifeexpectancy = (select max(lifeexpectancy) from country)
```

* **可以当作join语句与其他表联接**

  ```mysql
  查询中国的城市人口大于本省的城市平均人口的城市.
  select 
  	city1.name,
  	city1.population,
  	city2.avgPop 
  from 
  	city city1
  join 
  	(select 
  		district district2,
  		avg(population) avgPop 
  	from 
  		city 
  	where 
  		countrycode = 'chn'
  	group by 
  		district) city2 
  on 
  	city1.district = city2.district2 
  where 
  	city1.population > city2.avgPop 
  ```

## 表的完全克隆

```mysql
1) create table if not exists 新表名 like 已有表名; 
2) insert into 新表名 select * from 已有表名;
```

## 事务

### 定义

* 一组逻辑操作单元(DML), 使数据从一种状态变换到另一种状态。
* 在数据库编程语言中，事务是将一个数据处理执行步骤的集合作为一个单元来处理，**也就是说，执行这些步骤就好像是执行一个单个的命令一样**

![1566555270955](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1566555270955.png)

### ACID特性

```mysql
A 原子性 : 事务中的所有操作是不可分割的, 要么全部成功(事务的提交commit), 要么全部失败(事务的回滚rollback)
C 一致性 : 数据在事务前和事务后的一致, 数据没有丢失, 保持完整
I 隔离性 : 多个事务之间是隔离的, 一个事务的执行并不影响其他事务.
D 持久性 : 一旦事务提交, 产生的影响是持久性的. 事务提交会影响其他事务.
```

### 事务启动（设置提交状态）

```mysql
set autocommit = false; -- 默认为true
或者
start/begin transaction
```

### 事务组成 : 若干DML

### 事务结束

```mysql
commit 提交(表示成功)	
rollback 回滚(表示失败)
DDL 会提交 
用户会话正常结束 会提交 
系统异常终止 会回滚
```

### 还原设置

```mysql
set autocommit = true;-- 要记得还原设置
```

### COMMIT和ROLLBACK语句的优点

* 确保数据完整性。
* 数据改变被提交之前预览。
* 将逻辑上相关的操作分组。

## 预编译（预处理）

### 作用

* 是把一个SQL提前编译成可以执行体, 只要执行这个执行体就可以完成相应的SQL功能了
* 当想要执行多个查询，而每个查询之间只有很小的差别时，预处理语句将会非常有用。
* **例如，可以预备一条语句，然后多次执行它，而每次只是数据值不同。**

### 示例

```mysql
prepare p1 from 'select * from teachers';

-- 执行预编译 
execute p1;

-- 丢弃预编译
drop prepare p1; 
```

```mysql
prepare p2 from 
'insert into teachers(
	name,
	age,
	address
) values (
	?, -- 用问号表示可以替换的值
	?, -- ?占位符只能用于替换值的部分，不可用在参数部分
	?
)';

-- 要想执行预编译, 必须创建用户变量
set @变量名 = 值; -- 变量名可以自定义
execute p2 using @变量名, @变量名. -- 变量名的顺序要按照预编译里的顺序
```

## 约束

* 表级的强制的规定, 使得表中的数据满足某种条件.

```mysql
NOT NULL 		非空约束，规定某个字段不能为空, 只能作为列级约束
UNIQUE  		唯一约束，规定某个字段在整个表中是唯一的
PRIMARY KEY  	主键(非空且唯一) 一张表只允许有一个主键
FOREIGN KEY  	外键 可以有多个
CHECK  			检查约束
DEFAULT  		默认值 只能作为列级约束
```

### 联合主键

* 多个列的**组合值**是非空且唯一

```mysql
create table test(
	a int,
	b int,
	primary key(a, b)
);
```

#### 丢弃主键

```mysql
alter table test 
drop primary key; -- 主键唯一，所以不用指定哪个
```

#### 添加唯一键

```mysql
alter table test 
add unique(a);
```

#### 丢弃唯一键

```mysql
alter table test 
drop key a;
```

### 外键约束

* 保证了子表数据的引用完整性. 效率低.

#### 创建外键

```mysql
foreign key(本表的外键的列) references 父表(父表被引用的列-必须是主键)
```

* 创建外键时可以指定一些选项

```mysql
foreign key(master) references teachers(id) on delete do nothing(缺省), cascade(级联), set null(置空)
```



#### 示例

```mysql
create table if not exists classes (
	id int auto_increment,
	name varchar(30),
	beginDate datetime,
	room char(3),
	master int not null, 
	unique(name),
	primary key(id),
	foreign key(master) references teachers(id) -- classes 的master引用teachers的id
);
```

#### 丢弃外键

```mysql
alter table 表名
drop foreign key classes_ibfk_1; -- 要指定外键名，不唯一；外键名通过show create table 表名查看
```

#### 添加外键

```mysql
alter table 表名 
add foreign key(本表的外键的列) references 父表(父表的主键) on delete 选项 on update 选项.
```

## 分页（limit）

```mysql
limit 略过的记录数, 最终要显示的记录数.
limit (pageNo - 1) * records, records
-- 示例
select * from city limit 20, 20; -- 略过前20个，显示20个
```

## 一些查询的题目

* 哪些国家没有列出任何使用语言？(2种做法)

```mysql
select 
	co.name
from 
	country co 
left join 
	countrylanguage cl
on 
	co.code = cl.countrycode 
where 
	cl.language is null;
```

```mysql
select 
	co.name,
	count(cl.language) langs
from 
	country co 
left join 
	countrylanguage cl
on 
	co.code = cl.countrycode
group by 
	co.name
having 
	langs = 0;
```

* 列出在城市表中80%人口居住在城市的国家

```mysql
select 
	co.name,
	sum(ci.population) / co.population rate 
from 
	country co 
join 
	city ci 
on 
	co.code = ci.countrycode 
group by 
	co.name 
having 
	rate > 0.8;
```

* 查询人均寿命最长和最短的国家的名称及人均寿命

```mysql
select 
	name,
	lifeexpectancy
from 
	country 
where 
	lifeexpectancy in (
		(select max(lifeexpectancy) from country),
		(select min(lifeexpectancy) from country)
	);
```

* 查询亚洲国家的各省的总城市数量和平均人口数, 哪些平均人口大于50万, 降序显示总城市数量.

```mysql
select 
	ci.district ,
	count(*),
	avg(ci.population) avgpop,
	co.population
from 
	country co 
join 
	city  ci 
on 
	co.code = ci.countrycode 
where 
	co.continent = 'asia'
group by 
	ci.district 
having 
	avgpop > 500000
order by 
	count(*) desc; 
```

* 查询所有国家的首都和使用率最高的官方语言

```mysql
select 
	co.name,
	ci.name,
	t3.language,
	t3.maxPer
from 
	country  co 
left join 
	city ci 
on 
	co.capital = ci.id 
left join 
	(select 
		t1.language,
		t2.countrycode,
		t2.maxPer
	from 
		countrylanguage t1
	right join 
		(select 
			co.code countryCode, 
			max(cl.percentage) maxPer
		from 
			country co 
		join 
			countrylanguage cl 
		on 
				co.code = cl.countrycode
			and 
				cl.isofficial = 't'
		group by 
			co.code) t2
	on 
			t1.percentage = t2.maxPer
		and 
			t1.countrycode = t2.countrycode
		and 
			t1.isofficial = 't') t3 
on 
	co.code = t3.countrycode ；
```


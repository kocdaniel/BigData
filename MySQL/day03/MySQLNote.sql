登录mysql服务器
cmd> mysql -uroot -p123456

必须使用TCP/IP方式 -h host, -P port -p password -u user
cmd> mysql -h127.0.0.1 -P3306 -uroot -p123456 

所有SQL都必须以;结尾
查看服务器中有哪些数据库
mysql> show databases;

数据库在服务器以目录的形式保存
目录在 data 

创建新数据库
mysql> create database company;

mysql也有当前工作数据库的概念
切换工作数据库
mysql> use 新数据库名;

查看当前工作数据库
select database();

查看当前工作数据库中的所有表
show tables;

从外部.sql文件中导入数据
source d:\\mywork\\mysql\\company.sql;

查看表中的所有数据
select * from 表名;

练习 : 创建world数据库, 并导入 world.sql文件 

建表
create table customer (
	id int, 
	name varchar(20),
	age int,
	phone varchar(20),
	email varchar(50)
);

查看表结构(有哪些列, 列的数据类型是什么)
describe customer;

插入数据
insert into customer (
	id,
	name,
	age,
	phone,
	email
) values (
	1,
	'张三',
	30,
	'134234234',
	'z3@qq.com'
);

insert into customer (
	id,
	name,
	age,
	phone,
	email
) values (
	2,
	'李四',
	40,
	'144234234',
	'l4@qq.com'
);

修改数据
update customer set 
	name = '赵六',
	email = 'z6@qq.com'
where  -- 用于过滤行, 行的id值为1的才匹配
	id = 1;
	
删除数据, 如果没有where 全部删除
delete from customer
where 
	id = 1;

C 创建数据 insert into 
R 访问数据 select 
U 更新数据 update 
D 删除数据 delete 


select * from departments;

查询部门表中的部门ID和位置ID
SELECT department_id, location_id 
FROM   departments;

select 
	name,
	continent,
	population
from 
	country;
	
select 
	population,
	name,
	continent
from 
	country; -- 基表, 也是一个实表
	
查询结果是一个虚表

注意点: 
SQL 语言大小写不敏感。 
SQL 可以写在一行或者多行
关键字不能被缩写也不能分行
各子句一般要分行写。
使用缩进提高语句的可读性。

"" 的作用是保持原样, 不做任何处理
select 
	population as "PoP",
	name countryName,
	capital "国家 首都"
from 
	country;
	
desc country;
+----------------+---------------------------------------------------------------------------------------+------+-----+---------+-------+
| Field          | Type                                                                                  | Null | Key | Default | Extra |
+----------------+---------------------------------------------------------------------------------------+------+-----+---------+-------+
| Code           | char(3)                                                                               | NO   | PRI |         |       |
| Name           | char(52)                                                                              | NO   |     |         |       |
| Continent      | enum('Asia','Europe','North America','Africa','Oceania','Antarctica','South America') | NO   |     | Asia    |       |
| Region         | char(26)                                                                              | NO   |     |         |       |
| SurfaceArea    | float(10,2)                                                                           | NO   |     | 0.00    |       |
| IndepYear      | smallint(6)                                                                           | YES  |     | NULL    |       |
| Population     | int(11)                                                                               | NO   |     | 0       |       |
| LifeExpectancy | float(3,1)                                                                            | YES  |     | NULL    |       |
| GNP            | float(10,2)                                                                           | YES  |     | NULL    |       |
| GNPOld         | float(10,2)                                                                           | YES  |     | NULL    |       |
| LocalName      | char(45)                                                                              | NO   |     |         |       |
| GovernmentForm | char(45)                                                                              | NO   |     |         |       |
| HeadOfState    | char(60)                                                                              | YES  |     | NULL    |       |
| Capital        | int(11)                                                                               | YES  |     | NULL    |       |
| Code2          | char(2)                                                                               | NO   |     |         |       |
+----------------+---------------------------------------------------------------------------------------+------+-----+---------+-------+

查询国家的名称和平均寿命和大洲, 要求给列用汉字起别名
select 
	name as 国家名称,
	lifeexpectancy "平均寿命" ,
	continent 大洲 
from 
	country;
	
where 过滤行

SELECT employee_id, last_name, job_id, department_id
FROM   employees
WHERE  department_id = 90 ;

-- 执行逻辑是 把基表中的所有记录先过滤一下, 再把留下的记录再切开, 再拼接虚表.
select 
	name,
	population pop,
	continent con
from 
	country 
where  -- 在虚表产生之前执行.
	population > 50000000; -- pop 在where不能使用
	
查询哪些国家的平均寿命在75以上, 列起别名.
select 
	name,
	lifeexpectancy as 寿命
from 
	country 
where 
	lifeexpectancy > 75;
 
模糊查询中, _表示固定的任意某个字符, %表示任意个任意字符
SELECT last_name
FROM   employees
WHERE  last_name LIKE '_o%';

select 
	name
from 
	country 
where 
	name like 'china'; -- like 后面的字符串中如果没有使用通配符, 它和=一样
	
查询城市表中第3个字母是K, 以g结尾的城市名称.
select 
	id,
	name,
	countrycode
from 
	city 
where 
	name like '__k%g';
	
查询国家名称中只要包含ch的都查询出来
select 
	name
from 
	country 
where 
	name like '%ch%';
	
null只要参与比较运算, 结果总是false
查询哪些国家没有首都
select 
	name, 
	capital
from 
	country 
where 
	capital = null;

正确的: 
select 
	name, 
	capital,
	population
from 
	country 
where 
	capital is null;
	
select 
	name, 
	capital,
	population
from 
	country 
where 
	capital is not null;
	
SELECT employee_id, last_name, job_id, salary
FROM   employees
WHERE  salary >=10000
AND    job_id LIKE '%MAN%';


SELECT employee_id, last_name, job_id, salary
FROM   employees
WHERE  salary >= 10000
OR     job_id LIKE '%MAN%';

查询亚洲哪些国家人口大于5000万
select 
	name,
	continent,
	population
from 
	country 
where 
		continent = 'asia'
	and
		population > 50000000;
		
查询哪些欧洲国家的面积小于10万平方公里
select 
	name,
	continent,
	surfacearea area
from 
	country 
where 
		continent = 'europe'
	and 
		surfacearea < 100000;
		
select 
	name 
from 
	country 
where 
	1 + 3;
	
select 
	name 
from 
	country 
where 
	1 - 1; -- 如果是0表示假, 非0表示真

order by 是对虚表进行排序
	
SELECT   last_name, job_id, department_id
FROM     employees
ORDER BY last_name DESC ;


select 
	name,
	continent,
	population pop 
from 
	country 
where 
		continent = 'asia'
	and
		population > 50000000
order by 
	pop desc;

	
SELECT last_name, department_id, salary
FROM   employees
ORDER BY department_id ASC, salary DESC;


查询有首都的国家, 按照大洲降序人口升序, 人口数要大于2千万
select 
	name, 
	continent con,
	population pop 
from 
	country  
where 
		capital is not null 
	and 
		population > 20000000
order by 
	con desc,
	pop
	
查看最富有的国家
select 
	name,
	gnp
from 
	country 
order by 
	gnp;
	
查看亚洲最少人口的国家 
select
	name,
	population pop 
from 
	country 
where 
	continent = 'asia'
order by 
	pop desc;

去重 distinct
select 
	distinct continent
from 
	country
order by 
	continent;
	
+-------------+----------+------+-----+---------+----------------+
| Field       | Type     | Null | Key | Default | Extra          |
+-------------+----------+------+-----+---------+----------------+
| ID          | int(11)  | NO   | PRI | NULL    | auto_increment |
| Name        | char(35) | NO   |     |         |                |
| CountryCode | char(3)  | NO   | MUL |         |                |
| District    | char(20) | NO   |     |         |                |
| Population  | int(11)  | NO   |     | 0       |                |
+-------------+----------+------+-----+---------+----------------+	
查询中国有哪些不同的省份
select 
	distinct district
from 
	city 
where 
	countrycode = 'chn';

执行顺序 : 
3 select 
1 from 
2 where 
4 order by 

多表查询
多表联接的结果表中记录数 = 表1记录 * 表2的记录 * 表3的记录
结果表称为笛卡尔集

create table city2 select * from city  where name = 'london';
create table country2 select * from country where code = 'gbr' or code = 'can';

select * from city2, country2; 
+------+--------+-------------+----------+------------+------+----------------+---------------+-----------------+-------------+-----------+------------+----------------+------------+------------+----------------+-------------------------------------+--------------+---------+-------+
| ID   | Name   | CountryCode | District | Population | Code | Name           | Continent     | Region          | SurfaceArea | IndepYear | Population | LifeExpectancy | GNP        | GNPOld     | LocalName      | GovernmentForm                      | HeadOfState  | Capital | Code2 |
+------+--------+-------------+----------+------------+------+----------------+---------------+-----------------+-------------+-----------+------------+----------------+------------+------------+----------------+-------------------------------------+--------------+---------+-------+
|  456 | London | GBR         | England  |    7285000 | CAN  | Canada         | North America | North America   |  9970610.00 |      1867 |   31147000 |           79.4 |  598862.00 |  625626.00 | Canada         | Constitutional Monarchy, Federation | Elisabeth II |    1822 | CA    |
| 1820 | London | CAN         | Ontario  |     339917 | CAN  | Canada         | North America | North America   |  9970610.00 |      1867 |   31147000 |           79.4 |  598862.00 |  625626.00 | Canada         | Constitutional Monarchy, Federation | Elisabeth II |    1822 | CA    |
|  456 | London | GBR         | England  |    7285000 | GBR  | United Kingdom | Europe        | British Islands |   242900.00 |      1066 |   59623400 |           77.7 | 1378330.00 | 1296830.00 | United Kingdom | Constitutional Monarchy             | Elisabeth II |     456 | GB    |
| 1820 | London | CAN         | Ontario  |     339917 | GBR  | United Kingdom | Europe        | British Islands |   242900.00 |      1066 |   59623400 |           77.7 | 1378330.00 | 1296830.00 | United Kingdom | Constitutional Monarchy             | Elisabeth II |     456 | GB    |
+------+--------+-------------+----------+------------+------+----------------+---------------+-----------------+-------------+-----------+------------+----------------+------------+------------+----------------+-------------------------------------+--------------+---------+-------+

联接的结果集中绝大多数都是垃圾, 所以过滤行是必须的.
select 
	*
from 
	city2,
	country2 
where 
	countrycode = code;
+------+--------+-------------+----------+------------+------+----------------+---------------+-----------------+-------------+-----------+------------+----------------+------------+------------+----------------+-------------------------------------+--------------+---------+-------+
| ID   | Name   | CountryCode | District | Population | Code | Name           | Continent     | Region          | SurfaceArea | IndepYear | Population | LifeExpectancy | GNP        | GNPOld     | LocalName      | GovernmentForm                      | HeadOfState  | Capital | Code2 |
+------+--------+-------------+----------+------------+------+----------------+---------------+-----------------+-------------+-----------+------------+----------------+------------+------------+----------------+-------------------------------------+--------------+---------+-------+
| 1820 | London | CAN         | Ontario  |     339917 | CAN  | Canada         | North America | North America   |  9970610.00 |      1867 |   31147000 |           79.4 |  598862.00 |  625626.00 | Canada         | Constitutional Monarchy, Federation | Elisabeth II |    1822 | CA    |
|  456 | London | GBR         | England  |    7285000 | GBR  | United Kingdom | Europe        | British Islands |   242900.00 |      1066 |   59623400 |           77.7 | 1378330.00 | 1296830.00 | United Kingdom | Constitutional Monarchy             | Elisabeth II |     456 | GB    |
+------+--------+-------------+----------+------------+------+----------------+---------------+-----------------+-------------+-----------+------------+----------------+------------+------------+----------------+-------------------------------------+--------------+---------+-------+
下面的查询会出现列名模糊问题
select 
	name,
	countrycode,
	population,
	code,
	name,
	population
from 
	city2,
	country2 
where 
	countrycode = code 
	
	
select 
	city2.name,
	city2.countrycode,
	city2.population,
	country2.code,
	country2.name,
	country2.population
from 
	city2,
	country2 
where 
	city2.countrycode = country2.code 
	
-- 表也可以起别名, as关键字可以省略
select 
	ci.name cityName,
	ci.countrycode code,
	ci.population cityPop,
	co.code code,
	co.name countryName,
	co.population countryPop
from 
	city2 as ci,
	country2 co 
where 
	ci.countrycode = co.code 

-- 错误 : 表名一旦起了别名, 原名就不能用了, 原名就消失了, 因为最先执行的是from	
select 
	city2.name cityName,
	city2.countrycode code,
	city2.population cityPop,
	country2.code code,
	country2.name countryName,
	country2.population countryPop
from 
	city2 as ci,
	country2 co 
where 
	city2.countrycode = country2.code;
	
查询所有国家的名称和首都的名称
select 
	co.name country,
	ci.name capital 
from 
	country co,
	city ci 
where 
	co.capital = ci.id;
	
select 
	ci.name cityName,
	ci.countrycode code,
	ci.population cityPop,
	co.code code,
	co.name countryName,
	co.population countryPop
from 
	city2 as ci,
	country2 co 
where 
		ci.countrycode = co.code
	and 
		ci.population > 5000000;

+----------+------+---------+------+----------------+------------+
| cityName | code | cityPop | code | countryName    | countryPop |
+----------+------+---------+------+----------------+------------+
| London   | GBR  | 7285000 | GBR  | United Kingdom |   59623400 |
+----------+------+---------+------+----------------+------------+
SQL99标准把联接条件使用关键字修饰 on , 逗号联接本质就是内联接, 继续改进 使用join关键字
select 
	ci.name cityName,
	ci.countrycode code,
	ci.population cityPop,
	co.code code,
	co.name countryName,
	co.population countryPop
from 
	city2 as ci
inner join 
	country2 co 
on 
	ci.countrycode = co.code
where 
	ci.population > 5000000;
	
-- on 和 where是可以混用, 但是不要这样做.
select 
	ci.name cityName,
	ci.countrycode code,
	ci.population cityPop,
	co.code code,
	co.name countryName,
	co.population countryPop
from 
	city2 as ci
inner join 
	country2 co 
on 
	ci.countrycode = co.code
where 
	ci.population > 5000000;
	
-- inner关键字可以省略
select 
	ci.name cityName,
	ci.countrycode code,
	ci.population cityPop,
	co.code code,
	co.name countryName,
	co.population countryPop
from 
	city2 as ci
join 
	country2 co 
on 
	ci.countrycode = co.code
where 
	ci.population > 5000000;
	
使用SQL99 查询所有亚洲国家的名称和首都名称.
select 
	co.name country,
	ci.name capital,
	co.population pop 
from 
	country co 
join 
	city ci 
on 
	co.capital = ci.id 
where 
	co.continent = 'asia'
order by 
	pop;
	
使用SQL99 查询所有亚洲国家的名称和首都名称及官方语言
select 
	co.name country,
	ci.name capital,
	cl.language officialLang
from 
	country co 
join 
	city ci 
on 
	co.capital = ci.id 
join 
	countrylanguage cl 
on 
	co.code = cl.countrycode 
where 
		co.continent = 'asia'
	and 
		cl.isofficial = 'T'


内联接的逻辑是只保留联接条件为真的记录. 
select
	co.name,
	ci.name 
from 
	country2 co 
join 
	city2 ci 
on 
	co.capital = ci.id;

有时, 需要保证某张表的数据完整, 必须使用外联接.
left outer join 左外联接, 效果是保证左表的数据完整

select
	ci.id,
	co.name,
	ci.name 
from 
	country2 co 
left outer join 
	city2 ci 
on 
	co.capital = ci.id;
	
--outer 关键字可以省略	
select
	ci.id,
	co.name,
	ci.name 
from 
	country2 co 
left join 
	city2 ci 
on 
	co.capital = ci.id;

查询所有国家及首都名称, 如果没有首都显示null

查询所有国家及国家的官方语言, 如果没有官方语言显示null
select 
	co.name country,
	cl.language,
	cl.isofficial 
from 
	country co 
left join 
	countrylanguage cl 
on 
		co.code = cl.countrycode
	and 
		cl.isofficial = 't';



复习: 

Server / Client

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

短选项:
cmd > mysql -h服务器主机 -P端口号 -u用户名 -p密码
长选项:
cmd > mysql --host=服务器主机 --port=端口号 --user=用户名 --password=密码 默认工作数据库

查询 : 
select 
	database(); -- 当前工作数据库

显示所有数据库
show databases;

跨库显示表名
show tables from 库名;

查看表结构 : 查看列名, 数据类型, 长度, 其他选项等
desc 表名;

查看表的最详细的信息
show create table 表名;

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
有列的定义, 有约束的定义, 表的存储引擎, 字符集

InnoDB引擎 : 支持事务, 外键 等高级特性		缺点 : 速度较快
MyIsam引擎 : 不支持事务, 外键..				优点 : 速度快

show engines;

飘号(反引号)的作用, 用于包围限定数据库对象的名称, 比如库名, 表名, 列名, 约束名....

select database() from dual;

select 
	version(),
	database(),
	now()
from 
	country;

select 
	100,
	'abc',
	123 * 3 - 2
	
变量 : 
用户变量 : @变量名;
set @abc = 200;

系统变量 : @@变量名;
show variables;

执行顺序 : from -> join -> on -> join -> on ... -> where -> select -> order by 
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
	
联接 : 
	内联接 : 
		多张表中的记录最后只有满足联接条件的.
	外联接 : 
		保证某张表的记录的完整性, 如果满足联接条件显示数据, 不满足联接条件的显示为null

	
单行函数 : 作用于结果集中的每条记录都经过函数处理
转成大写和小写
select 
	upper(name),
	lower(name)
from 
	country;

取子串
select 
	substr("helloworld", 2, 5);

字符串连接	
select 
	concat(name, population)
from
	country;
	
练习 查询国家名称和大洲及人口的拼接结果, 要求数据之间用->隔开
select 
	concat(concat(concat(concat(name, " -> "), continent), " -> "), population) infos
from 
	country ;
	
select 
	concat(name, " -> ", continent, " -> ", population) infos
from 
	country;

	
组函数 : 作用于一组数据, 最后一个结果.本质上是统计运算.
SELECT 
	AVG(salary), 
	MAX(salary),
    MIN(salary), 
	SUM(salary)
FROM   
	company.employees
	
select 
	max(surfaceArea),
	min(surfaceArea)
from 
	country;
	
select 
	--name, -- 代表个体信息的列
	max(population) -- 代表群体信息的列
from 
	country;
	
--效果就相当于获取表中的记录数
select 
	count(name)
from 
	country;

如果列中的数据有为null的无法参与统计
select 
	count(capital)
from 
	country;
	
真正获取表中的记录的语句必须使用count(*)
select 
	count(*)
from 
	country;
	
-- 一旦分组了, 必须把分组依据的列放在select后面.
SELECT 
	department_id,
	AVG(salary)
FROM     
	company.employees
GROUP BY 
	department_id ;
	
各个, 每个

查询各大洲的平均人口
select 
	continent,
	avg(population)
from 
	country 
group by 
	continent;

查询各国家的城市总人口
select 
	countrycode,
	sum(population)
from 
	city 
group by 
	countrycode 

分组的列如果有多个, 那么 分组时以多个列的组合值为分组依据
select
	continent,
	GovernmentForm,
	count(*)
from 
	country 
group by 
	continent,
	GovernmentForm;
	
查询各大洲的平均人口, 只显示平均人口大于2000万的记录
select 
	continent,
	avg(population) avgPop
from 
	country 
group by 
	continent
having
	avgPop > 20000000; -- having后面的条件中的列必须是虚表中的列才行.

查询中国各省的城市总人口数, 显示城市总人口数大于300万的记录.
select 
	countrycode,
	district,
	sum(population) sumPop
from 
	city 
group by 
	district 
having 
		sumPop > 3000000
	and 
		countrycode = 'chn'
order by 
	sumPop desc;
	
-- 
select 
	district,
	sum(population) sumPop
from 
	city 
where 
	countrycode = 'chn'
group by 
	district 
having 
	sumPop > 3000000
order by 
	sumPop desc;
	
过滤记录的语句
on 
	联接条件 
where 
	基表的行进行普通过滤
having 
	分组结果的虚表进行过滤
	

+-------------+---------------+------+-----+---------+-------+
| Field       | Type          | Null | Key | Default | Extra |
+-------------+---------------+------+-----+---------+-------+
| CountryCode | char(3)       | NO   | PRI |         |       |
| Language    | char(30)      | NO   | PRI |         |       |
| IsOfficial  | enum('T','F') | NO   |     | F       |       |
| Percentage  | float(4,1)    | NO   |     | 0.0     |       |
+-------------+---------------+------+-----+---------+-------+
列出所有在超过10个国家中使用的语言。
select
	language,
	count(*)
from 
	countrylanguage
group by 
	language
having 
	count(*) > 10;
	
亚洲国家各有多少种语言
select
	co.name,
	count(*)
from 
	countrylanguage cl 
join 
	country co 
on 
	cl.countrycode = co.code 
where 
	co.continent = 'asia'
group by 
	co.name;

总结 : 做一个SQL查询步骤
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


列出不同的国家(country code)有居民超过7,000,000的城市， 它们有多少？
select 
	countrycode,
	count(*)
from 
	city 
where 
	population > 7000000
group by 
	countrycode;

哪些国家没有列出任何使用语言？
select 
	co.name,
	count(cl.language) cc
from 
	country co 
left join 
	countrylanguage cl 
on 
	co.code = cl.countrycode 
group by 
	co.name 
having 
	cc = 0;
	
select 
	co.name,
	cl.language
from 
	country co 
left join 
	countrylanguage cl 
on 
	co.code = cl.countrycode 
where 
	cl.language is null;

查询哪些国家没有官方语言
select 
	co.name,
	cl.language
from 
	country co 
left join 
	countrylanguage cl 
on 
		co.code = cl.countrycode 
	and 
		cl.isofficial = 'T'
where 
	cl.language is null;

列出在城市表中80%人口居住在城市的国家
select 
	co.name,
	sum(ci.population),
	co.population,
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

查询亚洲国家的各省的总城市数量和平均人口数, 哪些平均人口大于50万, 降序显示总城市数量.
select 
	co.name,
	ci.district,
	count(*) cities,
	avg(ci.population) avgPop
from 
	country co 
join 
	city ci 
on 
	co.code = ci.countrycode 
where 
	co.continent = 'asia'
group by 
	ci.district
having 
	avgPop > 500000
order by 
	cities desc;


子查询: 解决需要两次查询解决的问题.
如果子查询用于where条件, 它的查询的虚表的列必须一列, 行通常也是一行.

查询人均寿命最高的国家
select 
	continent,
	name,
	lifeexpectancy
from 
	country 
where 
	lifeexpectancy = (select max(lifeexpectancy) from country)
	
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


数据的CRUD操作, 这些语句统称为DML (数据操纵语言)
select 
insert 
update 
delete 

数据库对象的相关操作, 创建, 修改, 丢弃, 这些语句统称为DDL (数据定义语言)
create 
alter 
drop

create database if not exists `school` charset utf8;
alter database `school` charset gbk;
drop database if exists `school`;

数据类型
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

创建表
-- 主键 非空并唯一
not null, --非空
create table if not exists teacher(
	id int auto_increment,
	name varchar(20) not null,
	age int,
	gender enum('男', '女') default '男',
	primary key(id) -- 表级主键
) charset gbk engine innodb;

create table if not exists classes (
	id int auto_increment,
	name varchar(30),
	beginDate datetime,
	room char(3),
	master int, 
	primary key(id)
);

创建学生表, id, name, class_id, phone, email 
create table if not exists student (
	id int auto_increment,
	name varchar(20) unique,
	class_id int,
	phone char(14),
	email varchar(50),
	primary key(id)
);

基于子查询建表, 建成的实表不会复制原表的主键.
create table if not exists country2 
as select * from world.country;

复制表结构, 没有数据
create table if not exists country3 like world.country;

insert into student (
	class_id,
	name,
	email,
	phone
) values (
	1,
	'小花',
	'xh@qq.com',
	'134234234'
), (
	1, 
	'小黑',
	'xhei@qq.com',
	'234234234'
);

+----------+-------------+------+-----+---------+----------------+
| Field    | Type        | Null | Key | Default | Extra          |
+----------+-------------+------+-----+---------+----------------+
| id       | int(11)     | NO   | PRI | NULL    | auto_increment |
| name     | varchar(20) | YES  | UNI | NULL    |                |
| class_id | int(11)     | YES  |     | NULL    |                |
| phone    | char(14)    | YES  |     | NULL    |                |
| email    | varchar(50) | YES  |     | NULL    |                |
+----------+-------------+------+-----+---------+----------------+
alter table 表名 
向已有的表中添加列
add 新列名 数据类型(长度) 其他选项等.

alter table student 
add gender varchar(1) not null;

alter table teacher 
add address varchar(100) not null;

-- 在指定列后面添加新列
alter table student 
add age int after name;

-- 在最前面添加新列
alter table student 
add idcard varchar(30) first;

alter table 表名
修改现有表中的列
modify 列名 新数据类型(新长度) 新其他选项
+----------+--------------+------+-----+---------+----------------+
| Field    | Type         | Null | Key | Default | Extra          |
+----------+--------------+------+-----+---------+----------------+
| idcard   | varchar(30)  | YES  |     | NULL    |                |
| id       | int(11)      | NO   | PRI | NULL    | auto_increment |
| name     | varchar(20)  | YES  | UNI | NULL    |                |
| age      | int(11)      | YES  |     | NULL    |                |
| class_id | int(11)      | YES  |     | NULL    |                |
| phone    | char(14)     | YES  |     | NULL    |                |
| email    | varchar(50)  | YES  |     | NULL    |                |
| address  | varchar(100) | YES  |     | NULL    |                |
| gender   | varchar(1)   | NO   |     | NULL    |                |
+----------+--------------+------+-----+---------+----------------+
alter table student
modify gender enum('男', '女') default '男';

alter table 
重命名现有表中的列
change 老列名 新列名 新数据类型(新长度) 新选项

alter table student 
change gender sex char(1);

丢弃现有表中的列
alter table student
drop column gender;

alter table student 
drop column idCard;

alter table student 
drop column sex;

alter table 表名 
重命名表
rename to 新表名;

alter table student 
rename to students;

alter table teacher 
rename to teachers;

丢弃表
drop table 表名;

清空表
truncate table 表名, DDL, 效率高, 没有后悔

和
delete from 表名; DML, 效率低, 但是能后悔
不一样的

+---------+-----------------+------+-----+---------+----------------+
| Field   | Type            | Null | Key | Default | Extra          |
+---------+-----------------+------+-----+---------+----------------+
| id      | int(11)         | NO   | PRI | NULL    | auto_increment |
| name    | varchar(20)     | NO   |     | NULL    |                |
| age     | int(11)         | YES  |     | NULL    |                |
| gender  | enum('男','女') | YES  |     | 男      |                |
| address | varchar(100)    | NO   |     | NULL    |                |
+---------+-----------------+------+-----+---------+----------------+

在最后添加一个新列phone
在name后面添加一个新列salary

修改address列长度为50

丢弃gender列

所有的表名都变成复数


考试
1 哪些国家没有列出任何使用语言？(2种做法)
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


2 列出在城市表中80%人口居住在城市的国家
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


3 查询人均寿命最长和最短的国家的名称及人均寿命
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


4 查询亚洲国家的各省的总城市数量和平均人口数, 哪些平均人口大于50万, 降序显示总城市数量.
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

5 查询所有国家的首都和使用率最高的官方语言
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
	co.code = t3.countrycode 

create table if not exists 表名(
	列1 数据类型(长度) 其他选项等,
	.....
	primary key(主键列)
);

修改表

alter table 表名 
添加新列
add 新列名 数据类型(长度) 选项等 after 某列[first]

修改列
modify 列名 新数据类型(新长度) 新选项

改列名
change 老列名 新列名 新数据类型(新长度) 新选项

丢弃列 
drop 列名 


丢弃表
drop table if exists 表名;

清空表 
truncate table 表名 

DDL -> 数据定义语言, create , alter , drop ....

DML -> 数据操纵语言, insert , update, delete, select 

DCL -> 数据控制语言, commit, rollback...

+---------+-----------------+------+-----+---------+----------------+
| Field   | Type            | Null | Key | Default | Extra          |
+---------+-----------------+------+-----+---------+----------------+
| id      | int(11)         | NO   | PRI | NULL    | auto_increment |
| name    | varchar(20)     | NO   |     | NULL    |                |
| age     | int(11)         | YES  |     | NULL    |                |
| gender  | enum('男','女') | YES  |     | 男      |                |
| address | varchar(100)    | NO   |     | NULL    |                |
+---------+-----------------+------+-----+---------+----------------+
insert into teachers (
	name,
	age,
	gender,
	address 
) value (
	'许姐',
	30,
	'女',
	'北京昌平'
);

insert into teachers (
	name,
	age,
	gender,
	address 
) values (
	'杨老师',
	40,
	'男',
	'北京西城'
), (
	'张老师',
	25,
	'女',
	'上海'
);

insert into teachers (
	name,
	address
) values (
	'李老师',
	'天津'
);

-- 这样写不好, 因为它的值的插入必须固定受限于表的当前的字段列表
insert into teachers values (
)
+----------+--------------+------+-----+---------+----------------+
| Field    | Type         | Null | Key | Default | Extra          |
+----------+--------------+------+-----+---------+----------------+
| id       | int(11)      | NO   | PRI | NULL    | auto_increment |
| name     | varchar(20)  | YES  | UNI | NULL    |                |
| age      | int(11)      | YES  |     | NULL    |                |
| class_id | int(11)      | YES  |     | NULL    |                |
| phone    | char(14)     | YES  |     | NULL    |                |
| email    | varchar(50)  | YES  |     | NULL    |                |
| address  | varchar(100) | YES  |     | NULL    |                |
+----------+--------------+------+-----+---------+----------------+

insert into students (
	name,
	class_id,
	age,
	phone,
	address
) 
select 
	'某学生',
	1,
	age,
	'234234',
	address 
from 
	teachers 
where 
	id = 1;
	
表的完全克隆:
1) create table if not exists 新表名 like 已有表名; 
2) insert into 新表名 select * from 已有表名;


更新的删除操作都应该加where过滤, 如果没有where,会导致影响所有记录..

事务 : 一组逻辑操作单元(DML), ACID
A 原子性 : 事务中的所有操作是不可分割的, 要么全部成功(事务的提交commit), 要么全部失败(事务的回滚rollback)
C 一致性 : 数据在事务前和事务后的一致, 数据没有丢失, 保持完整
I 隔离性 : 多个事务之间是隔离的, 一个事务的执行并不影响其他事务.
D 持久性 : 一旦事务提交, 产生的影响是持久性的. 事务提交会影响其他事务.

事务启动 : set autocommit = false;
事务组成 : 若干DML
事务结束 : commit 提交(表示成功)	
		   rollback 回滚(表示失败)
		   DDL 会提交
		   用户会话正常结束 会提交 
		   系统异常终止 会回滚
		 
克隆city表
在事务中删除数据, 在另一个会话中查询数据
回滚事务 ,再察看数据

在事务中删除数据, 在另一个会话中查询数据
提交事务, 再察看数据 

还原设置
set autocommit = true;

预编译(预处理) 作用是把一个SQL提前编译成可以执行体, 只要执行这个执行体就可以完成相应的SQL功能了
prepare p1 from 
'select * from teachers';

执行预编译 
execute p1;

丢弃预编译
drop prepare p1; 

+---------+-----------------+------+-----+---------+----------------+
| Field   | Type            | Null | Key | Default | Extra          |
+---------+-----------------+------+-----+---------+----------------+
| id      | int(11)         | NO   | PRI | NULL    | auto_increment |
| name    | varchar(20)     | NO   |     | NULL    |                |
| age     | int(11)         | YES  |     | NULL    |                |
| gender  | enum('男','女') | YES  |     | 男      |                |
| address | varchar(100)    | NO   |     | NULL    |                |
+---------+-----------------+------+-----+---------+----------------+
prepare p2 from 
'insert into teachers(
	name,
	age,
	address
) values (
	?,
	?,
	?
)';

要想执行预编译, 必须创建用户变量
set @变量名 = 值;

execute p2 using @变量名, @变量名.

prepare p3 from 
'
	delete from 
		teachers 
	where id = ?
';

+-----------+-------------+------+-----+---------+----------------+
| Field     | Type        | Null | Key | Default | Extra          |
+-----------+-------------+------+-----+---------+----------------+
| id        | int(11)     | NO   | PRI | NULL    | auto_increment |
| name      | varchar(30) | YES  |     | NULL    |                |
| beginDate | datetime    | YES  |     | NULL    |                |
| room      | char(3)     | YES  |     | NULL    |                |
| master    | int(11)     | YES  |     | NULL    |                |
+-----------+-------------+------+-----+---------+----------------+

?占位符只能用于替换值的部分.
如果在SQL中出现', 使用'' 转义
prepare p4 from 
'
	insert into classes (
		name,
		begindate,
		room,
		master
	) values (
		''h50823'',
		now(),
		?,
		?
	)
';
'

约束 : 表级的强制的规定, 使得表中的数据满足某种条件.
NOT NULL 		非空约束，规定某个字段不能为空, 只能作为列级约束
UNIQUE  		唯一约束，规定某个字段在整个表中是唯一的
PRIMARY KEY  	主键(非空且唯一) 一张表只允许有一个主键
FOREIGN KEY  	外键 可以有多个
CHECK  			检查约束
DEFAULT  		默认值 只能作为列级约束

drop table if exists classes;
create table if not exists classes (
	id int auto_increment,
	name varchar(30),
	beginDate datetime,
	room char(3),
	master int not null, 
	unique(name),
	primary key(id)
);

联合主键, 多个列的组合值是非空且唯一
create table test(
	a int,
	b int,
	primary key(a, b)
);

丢弃主键
alter table test 
drop primary key;

添加唯一键
alter table test 
add unique(a);

alter table test 
add unique(b);

丢弃唯一键
alter table test 
drop key a;

+-----------+-------------+------+-----+---------+----------------+
| Field     | Type        | Null | Key | Default | Extra          |
+-----------+-------------+------+-----+---------+----------------+
| id        | int(11)     | NO   | PRI | NULL    | auto_increment |
| name      | varchar(30) | YES  |     | NULL    |                |
| beginDate | datetime    | YES  |     | NULL    |                |
| room      | char(3)     | YES  |     | NULL    |                |
| master    | int(11)     | YES  |     | NULL    |                |
+-----------+-------------+------+-----+---------+----------------+
insert into classes (
	name,
	begindate,
	room,
	master 
) values (
	'java0715',
	'2019-07-15',
	'301',
	10
);

--外键约束, 保证了子表数据的引用完整性. 效率低.
foreign key(本表的外键的列) references 父表(父表被引用的列-必须是主键)

drop table if exists classes;
create table if not exists classes (
	id int auto_increment,
	name varchar(30),
	beginDate datetime,
	room char(3),
	master int not null, 
	unique(name),
	primary key(id),
	foreign key(master) references teachers(id)
);

insert into classes (
	name,
	begindate,
	room,
	master 
) values (
	'java0815',
	'2019-08-15',
	'302',
	2
), (
	'bigdata0715',
	'2019-07-15',
	'303',
	2
), (
	'h50823',
	now(),
	'312',
	3
);

丢弃外键
alter table 表名
drop foreign key;

创建外键时可以指定一些选项 : 
foreign key(master) references teachers(id) on delete do nothing(缺省), cascade(级联), set null(置空)
drop table if exists classes;
create table if not exists classes (
	id int auto_increment,
	name varchar(30),
	beginDate datetime,
	room char(3),
	master int not null, 
	unique(name),
	primary key(id),
	foreign key(master) references teachers(id) on delete cascade
);

insert into teachers (
	id,
	name,
	age,
	gender,
	address
) values (
	2,
	'杨老师',
	30,
	'女',
	'北京天安门'
);

drop table if exists classes;
create table if not exists classes (
	id int auto_increment,
	name varchar(30),
	beginDate datetime,
	room char(3),
	master int, 
	unique(name),
	primary key(id),
	foreign key(master) references teachers(id) on delete set null
);

添加外键
alter table 表名 
add foreign key(本表的外键的列) references 父表(父表的主键) on delete 选项 on update 选项.

给子表classes表添加外键, 使用选项cascade. 测试效果
丢弃外键 
重新添加外键, 使用选项set null 测试效果 

limit 略过的记录数, 最终要显示的记录数.
limit (pageNo - 1) * records, records


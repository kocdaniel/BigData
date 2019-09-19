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























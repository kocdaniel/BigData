��¼mysql������
cmd> mysql -uroot -p123456

����ʹ��TCP/IP��ʽ -h host, -P port -p password -u user
cmd> mysql -h127.0.0.1 -P3306 -uroot -p123456 

����SQL��������;��β
�鿴������������Щ���ݿ�
mysql> show databases;

���ݿ��ڷ�������Ŀ¼����ʽ����
Ŀ¼�� data 

���������ݿ�
mysql> create database company;

mysqlҲ�е�ǰ�������ݿ�ĸ���
�л��������ݿ�
mysql> use �����ݿ���;

�鿴��ǰ�������ݿ�
select database();

�鿴��ǰ�������ݿ��е����б�
show tables;

���ⲿ.sql�ļ��е�������
source d:\\mywork\\mysql\\company.sql;

�鿴���е���������
select * from ����;

��ϰ : ����world���ݿ�, ������ world.sql�ļ� 

����
create table customer (
	id int, 
	name varchar(20),
	age int,
	phone varchar(20),
	email varchar(50)
);

�鿴��ṹ(����Щ��, �е�����������ʲô)
describe customer;

��������
insert into customer (
	id,
	name,
	age,
	phone,
	email
) values (
	1,
	'����',
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
	'����',
	40,
	'144234234',
	'l4@qq.com'
);

�޸�����
update customer set 
	name = '����',
	email = 'z6@qq.com'
where  -- ���ڹ�����, �е�idֵΪ1�Ĳ�ƥ��
	id = 1;
	
ɾ������, ���û��where ȫ��ɾ��
delete from customer
where 
	id = 1;

C �������� insert into 
R �������� select 
U �������� update 
D ɾ������ delete 


select * from departments;

��ѯ���ű��еĲ���ID��λ��ID
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
	country; -- ����, Ҳ��һ��ʵ��
	
��ѯ�����һ�����

ע���: 
SQL ���Դ�Сд�����С� 
SQL ����д��һ�л��߶���
�ؼ��ֲ��ܱ���дҲ���ܷ���
���Ӿ�һ��Ҫ����д��
ʹ������������Ŀɶ��ԡ�

"" �������Ǳ���ԭ��, �����κδ���
select 
	population as "PoP",
	name countryName,
	capital "���� �׶�"
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

��ѯ���ҵ����ƺ�ƽ�������ʹ���, Ҫ������ú��������
select 
	name as ��������,
	lifeexpectancy "ƽ������" ,
	continent ���� 
from 
	country;
	
where ������

SELECT employee_id, last_name, job_id, department_id
FROM   employees
WHERE  department_id = 90 ;

-- ִ���߼��� �ѻ����е����м�¼�ȹ���һ��, �ٰ����µļ�¼���п�, ��ƴ�����.
select 
	name,
	population pop,
	continent con
from 
	country 
where  -- ��������֮ǰִ��.
	population > 50000000; -- pop ��where����ʹ��
	
��ѯ��Щ���ҵ�ƽ��������75����, �������.
select 
	name,
	lifeexpectancy as ����
from 
	country 
where 
	lifeexpectancy > 75;
 
ģ����ѯ��, _��ʾ�̶�������ĳ���ַ�, %��ʾ����������ַ�
SELECT last_name
FROM   employees
WHERE  last_name LIKE '_o%';

select 
	name
from 
	country 
where 
	name like 'china'; -- like ������ַ��������û��ʹ��ͨ���, ����=һ��
	
��ѯ���б��е�3����ĸ��K, ��g��β�ĳ�������.
select 
	id,
	name,
	countrycode
from 
	city 
where 
	name like '__k%g';
	
��ѯ����������ֻҪ����ch�Ķ���ѯ����
select 
	name
from 
	country 
where 
	name like '%ch%';
	
nullֻҪ����Ƚ�����, �������false
��ѯ��Щ����û���׶�
select 
	name, 
	capital
from 
	country 
where 
	capital = null;

��ȷ��: 
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

��ѯ������Щ�����˿ڴ���5000��
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
		
��ѯ��Щŷ�޹��ҵ����С��10��ƽ������
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
	1 - 1; -- �����0��ʾ��, ��0��ʾ��

order by �Ƕ�����������
	
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


��ѯ���׶��Ĺ���, ���մ��޽����˿�����, �˿���Ҫ����2ǧ��
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
	
�鿴��еĹ���
select 
	name,
	gnp
from 
	country 
order by 
	gnp;
	
�鿴���������˿ڵĹ��� 
select
	name,
	population pop 
from 
	country 
where 
	continent = 'asia'
order by 
	pop desc;

ȥ�� distinct
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
��ѯ�й�����Щ��ͬ��ʡ��
select 
	distinct district
from 
	city 
where 
	countrycode = 'chn';

ִ��˳�� : 
3 select 
1 from 
2 where 
4 order by 

����ѯ
������ӵĽ�����м�¼�� = ��1��¼ * ��2�ļ�¼ * ��3�ļ�¼
������Ϊ�ѿ�����

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

���ӵĽ�����о��������������, ���Թ������Ǳ����.
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
����Ĳ�ѯ���������ģ������
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
	
-- ��Ҳ���������, as�ؼ��ֿ���ʡ��
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

-- ���� : ����һ�����˱���, ԭ���Ͳ�������, ԭ������ʧ��, ��Ϊ����ִ�е���from	
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
	
��ѯ���й��ҵ����ƺ��׶�������
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
SQL99��׼����������ʹ�ùؼ������� on , �������ӱ��ʾ���������, �����Ľ� ʹ��join�ؼ���
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
	
-- on �� where�ǿ��Ի���, ���ǲ�Ҫ������.
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
	
-- inner�ؼ��ֿ���ʡ��
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
	
ʹ��SQL99 ��ѯ�������޹��ҵ����ƺ��׶�����.
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
	
ʹ��SQL99 ��ѯ�������޹��ҵ����ƺ��׶����Ƽ��ٷ�����
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


�����ӵ��߼���ֻ������������Ϊ��ļ�¼. 
select
	co.name,
	ci.name 
from 
	country2 co 
join 
	city2 ci 
on 
	co.capital = ci.id;

��ʱ, ��Ҫ��֤ĳ�ű����������, ����ʹ��������.
left outer join ��������, Ч���Ǳ�֤������������

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
	
--outer �ؼ��ֿ���ʡ��	
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

��ѯ���й��Ҽ��׶�����, ���û���׶���ʾnull

��ѯ���й��Ҽ����ҵĹٷ�����, ���û�йٷ�������ʾnull
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



��ϰ: 

Server / Client

������(Tcp) :
	���ݿ�1(Ŀ¼)
		��1(�ļ�)
			��(�ֶ�)1
			��(�ֶ�)2
			.....
				����(��¼)
				��¼2.....
		
		��2 
		��3
		....
	���ݿ�2(Ŀ¼)
	
�ͻ���ͨ��socket���ӷ�����
����߱�ip�Ͷ˿�

��ѡ��:
cmd > mysql -h���������� -P�˿ں� -u�û��� -p����
��ѡ��:
cmd > mysql --host=���������� --port=�˿ں� --user=�û��� --password=���� Ĭ�Ϲ������ݿ�

��ѯ : 
select 
	database(); -- ��ǰ�������ݿ�

��ʾ�������ݿ�
show databases;

�����ʾ����
show tables from ����;

�鿴��ṹ : �鿴����, ��������, ����, ����ѡ���
desc ����;

�鿴�������ϸ����Ϣ
show create table ����;

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
���еĶ���, ��Լ���Ķ���, ��Ĵ洢����, �ַ���

InnoDB���� : ֧������, ��� �ȸ߼�����		ȱ�� : �ٶȽϿ�
MyIsam���� : ��֧������, ���..				�ŵ� : �ٶȿ�

show engines;

Ʈ��(������)������, ���ڰ�Χ�޶����ݿ���������, �������, ����, ����, Լ����....

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
	
���� : 
�û����� : @������;
set @abc = 200;

ϵͳ���� : @@������;
show variables;

ִ��˳�� : from -> join -> on -> join -> on ... -> where -> select -> order by 
select 
	����,
	����,
	���ʽ,
	��������,
	��1.����1,
	��2.����2
from 
	��1 
join 
	��2 
on
	�������� 
left join 
	��3 
on 
	�������� 
where 
	��ͨ���й�������
order by
	������
	
���� : 
	������ : 
		���ű��еļ�¼���ֻ����������������.
	������ : 
		��֤ĳ�ű�ļ�¼��������, �����������������ʾ����, ������������������ʾΪnull

	
���к��� : �����ڽ�����е�ÿ����¼��������������
ת�ɴ�д��Сд
select 
	upper(name),
	lower(name)
from 
	country;

ȡ�Ӵ�
select 
	substr("helloworld", 2, 5);

�ַ�������	
select 
	concat(name, population)
from
	country;
	
��ϰ ��ѯ�������ƺʹ��޼��˿ڵ�ƴ�ӽ��, Ҫ������֮����->����
select 
	concat(concat(concat(concat(name, " -> "), continent), " -> "), population) infos
from 
	country ;
	
select 
	concat(name, " -> ", continent, " -> ", population) infos
from 
	country;

	
�麯�� : ������һ������, ���һ�����.��������ͳ������.
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
	--name, -- ���������Ϣ����
	max(population) -- ����Ⱥ����Ϣ����
from 
	country;
	
--Ч�����൱�ڻ�ȡ���еļ�¼��
select 
	count(name)
from 
	country;

������е�������Ϊnull���޷�����ͳ��
select 
	count(capital)
from 
	country;
	
������ȡ���еļ�¼��������ʹ��count(*)
select 
	count(*)
from 
	country;
	
-- һ��������, ����ѷ������ݵ��з���select����.
SELECT 
	department_id,
	AVG(salary)
FROM     
	company.employees
GROUP BY 
	department_id ;
	
����, ÿ��

��ѯ�����޵�ƽ���˿�
select 
	continent,
	avg(population)
from 
	country 
group by 
	continent;

��ѯ�����ҵĳ������˿�
select 
	countrycode,
	sum(population)
from 
	city 
group by 
	countrycode 

�����������ж��, ��ô ����ʱ�Զ���е����ֵΪ��������
select
	continent,
	GovernmentForm,
	count(*)
from 
	country 
group by 
	continent,
	GovernmentForm;
	
��ѯ�����޵�ƽ���˿�, ֻ��ʾƽ���˿ڴ���2000��ļ�¼
select 
	continent,
	avg(population) avgPop
from 
	country 
group by 
	continent
having
	avgPop > 20000000; -- having����������е��б���������е��в���.

��ѯ�й���ʡ�ĳ������˿���, ��ʾ�������˿�������300��ļ�¼.
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
	
���˼�¼�����
on 
	�������� 
where 
	������н�����ͨ����
having 
	�������������й���
	

+-------------+---------------+------+-----+---------+-------+
| Field       | Type          | Null | Key | Default | Extra |
+-------------+---------------+------+-----+---------+-------+
| CountryCode | char(3)       | NO   | PRI |         |       |
| Language    | char(30)      | NO   | PRI |         |       |
| IsOfficial  | enum('T','F') | NO   |     | F       |       |
| Percentage  | float(4,1)    | NO   |     | 0.0     |       |
+-------------+---------------+------+-----+---------+-------+
�г������ڳ���10��������ʹ�õ����ԡ�
select
	language,
	count(*)
from 
	countrylanguage
group by 
	language
having 
	count(*) > 10;
	
���޹��Ҹ��ж���������
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

�ܽ� : ��һ��SQL��ѯ����
1) from ȷ������
2) һ�ű����ݹ���? �������join����ı�
3) �����join��Ҫ����������������
4) ֻҪ��join�������on����������
5) �Ƿ���Ҫ������е����м�¼? �����Ҫ����, ʹ��where 
6) �Ƿ���Ҫ����, ���Ҫ����, ���������ĸ���
7) ����з���, ��һʱ��Ͱѷ�����з���select����
8) ��������selectҪ������Щ�кͼ���
9) ����з���, ����Ҫ�Է���Ľ�����ٹ���, ��ʹ��having �������
10)�Ƿ�����յ���ʾ����������, �����ʹ��order by , �����ǽ���?


�г���ͬ�Ĺ���(country code)�о��񳬹�7,000,000�ĳ��У� �����ж��٣�
select 
	countrycode,
	count(*)
from 
	city 
where 
	population > 7000000
group by 
	countrycode;

��Щ����û���г��κ�ʹ�����ԣ�
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

��ѯ��Щ����û�йٷ�����
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

�г��ڳ��б���80%�˿ھ�ס�ڳ��еĹ���
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

��ѯ���޹��ҵĸ�ʡ���ܳ���������ƽ���˿���, ��Щƽ���˿ڴ���50��, ������ʾ�ܳ�������.
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


�Ӳ�ѯ: �����Ҫ���β�ѯ���������.
����Ӳ�ѯ����where����, ���Ĳ�ѯ�������б���һ��, ��ͨ��Ҳ��һ��.

��ѯ�˾�������ߵĹ���
select 
	continent,
	name,
	lifeexpectancy
from 
	country 
where 
	lifeexpectancy = (select max(lifeexpectancy) from country)
	
��ѯ�й��ĳ����˿ڴ��ڱ�ʡ�ĳ���ƽ���˿ڵĳ���.
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


���ݵ�CRUD����, ��Щ���ͳ��ΪDML (���ݲ�������)
select 
insert 
update 
delete 

���ݿ�������ز���, ����, �޸�, ����, ��Щ���ͳ��ΪDDL (���ݶ�������)
create 
alter 
drop

create database if not exists `school` charset utf8;
alter database `school` charset gbk;
drop database if exists `school`;

��������
int  			����
bigint 			������
double 			������
decimal 		������
char(����) 		�����ַ���		Ч�ʸ�, ռ�ռ�
varchar(����) 	�䳤�ַ���		�:65535�ֽ�
longtext		���ı�
date			����
time 			ʱ��
datetime		����ʱ��
timestamp		ʱ���			�����1970,1,1,0.0.0 ����

������
-- ���� �ǿղ�Ψһ
not null, --�ǿ�
create table if not exists teacher(
	id int auto_increment,
	name varchar(20) not null,
	age int,
	gender enum('��', 'Ů') default '��',
	primary key(id) -- ������
) charset gbk engine innodb;

create table if not exists classes (
	id int auto_increment,
	name varchar(30),
	beginDate datetime,
	room char(3),
	master int, 
	primary key(id)
);

����ѧ����, id, name, class_id, phone, email 
create table if not exists student (
	id int auto_increment,
	name varchar(20) unique,
	class_id int,
	phone char(14),
	email varchar(50),
	primary key(id)
);

�����Ӳ�ѯ����, ���ɵ�ʵ���Ḵ��ԭ�������.
create table if not exists country2 
as select * from world.country;

���Ʊ�ṹ, û������
create table if not exists country3 like world.country;

insert into student (
	class_id,
	name,
	email,
	phone
) values (
	1,
	'С��',
	'xh@qq.com',
	'134234234'
), (
	1, 
	'С��',
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
alter table ���� 
�����еı��������
add ������ ��������(����) ����ѡ���.

alter table student 
add gender varchar(1) not null;

alter table teacher 
add address varchar(100) not null;

-- ��ָ���к����������
alter table student 
add age int after name;

-- ����ǰ���������
alter table student 
add idcard varchar(30) first;

alter table ����
�޸����б��е���
modify ���� ����������(�³���) ������ѡ��
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
modify gender enum('��', 'Ů') default '��';

alter table 
���������б��е���
change ������ ������ ����������(�³���) ��ѡ��

alter table student 
change gender sex char(1);

�������б��е���
alter table student
drop column gender;

alter table student 
drop column idCard;

alter table student 
drop column sex;

alter table ���� 
��������
rename to �±���;

alter table student 
rename to students;

alter table teacher 
rename to teachers;

������
drop table ����;

��ձ�
truncate table ����, DDL, Ч�ʸ�, û�к��

��
delete from ����; DML, Ч�ʵ�, �����ܺ��
��һ����

+---------+-----------------+------+-----+---------+----------------+
| Field   | Type            | Null | Key | Default | Extra          |
+---------+-----------------+------+-----+---------+----------------+
| id      | int(11)         | NO   | PRI | NULL    | auto_increment |
| name    | varchar(20)     | NO   |     | NULL    |                |
| age     | int(11)         | YES  |     | NULL    |                |
| gender  | enum('��','Ů') | YES  |     | ��      |                |
| address | varchar(100)    | NO   |     | NULL    |                |
+---------+-----------------+------+-----+---------+----------------+

��������һ������phone
��name�������һ������salary

�޸�address�г���Ϊ50

����gender��

���еı�������ɸ���





 



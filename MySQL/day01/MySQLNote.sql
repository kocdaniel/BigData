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























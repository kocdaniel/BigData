# Shell 编程

## Shell脚本

> 1. 脚本格式

* 脚本以`#!/bin/bash`开头，指定解析器，CentOs默认为bash解析器
* 脚本后缀：`.sh`

> 2. 脚本的执行方式

* 采用bash或sh + 脚本的相对路径或绝对路径，不需要赋予脚本执行权限
* 直接输入脚本的相对路径或绝对路径，需要赋予脚本执行权限

## Shell中的变量

### 系统变量

1. 常用系统变量：$HOME, $PWD, $SHELL, $USER，可以通过`echo $HOME`显示变量内容
2. 显示当前Shell中的所有变量：`set`

### 自定义变量

> 1. 定义变量

* 变量=值
* 注意：
  * 等号两边不可有空格
  * 变量名称可以由字母、数字和下划线组成，但是不能以数字开头，环境变量名建议大写
  * 在bash中，变量**默认类型都是字符串类型**，无法直接进行数值运算
  * 变量的值如果有空格，需要使用双引号或单引号括起来

> 2. 撤销变量

* unset 变量

> 3. 声明静态变量

* readonly 变量，但是静态变量不能unset

> 4. export 变量名

* 提升为全局环境变量，可供其它shell程序使用

* ```shell
  [atguigu@hadoop100 datas]$ vim helloworld.sh
  
  #!/bin/bash
  echo helloworld
  echo $A
  ```

* ```shell
  [atguigu@hadoop100 datas]$ chmod 777 helloworld.sh
  [atguigu@hadoop100 datas]$ ./helloworld.sh 
  helloworld
  
  # 发现并没有输出A的值
  ```

* ```shell
  [atguigu@hadoop100 datas]$ export A
  [atguigu@hadoop100 datas]$ ./helloworld.sh 
  helloworld
  10 # A可以输出
  ```

### 特殊变量

> $n

* 功能描述：n为数字，$0代表该脚本名称，$1-$9代表第一到第九个参数，十以上的参数需要用大括号包含，如${10}

> $# 

* 功能描述：获取所有输入参数个数，常用于循环

> $*，$@

* $*
  * 功能描述：这个变量代表命令行中所有的参数，**$*把所有的参数看成一个整体**
* $@
  * 功能描述：这个变量也代表命令行中所有的参数，不过**$@把每个参数区分对待**

> $?

* 功能描述：最后一次执行的命令的返回状态。如果这个变量的值为0，证明上一个命令正确执行；如果这个变量的值为非0（具体是哪个数，由命令自己来决定），则证明上一个命令执行不正确了

## 运算符

> 1. 基本语法

* `“$((运算式))”或“$[运算式]”`
* `expr  + , - , \*,  /, %`  加减乘除取余 ，**但是expr运算符之间要有空格**

```shell
[atguigu@hadoop100 datas]$ expr 3 + 2
5
[atguigu@hadoop100 datas]$ expr 3+2
3+2
```

* 计算（2+3)*4的值

1. expr一步完成计算，需要用到飘号 `

```shell
[atguigu@hadoop100 datas]$ expr `expr 2 + 3` \* 4
20
```

2. $[运算式]计算

```shell
[atguigu@hadoop100 datas]$ c=$[(2+3)*4]
[atguigu@hadoop100 datas]$ echo $c
20
```

## 条件判断

> 1. 基本语法

* `[ condition ]` ：**condition前后必须要有空格**
* 条件非空即为true，否则为false

> 2. 常用判断条件

1. 两个**整数**之间的比较

```shell
= 字符串比较      # (注意：必须加空格，否则就是一个非空字符串，始终返回true ,例如：[ a = b ])
-lt 小于（less than）			-le 小于等于（less equal）
-eq 等于（equal）				-gt 大于（greater than）
-ge 大于等于（greater equal）	-ne 不等于（Not equal）
```

2. 按照文件权限进行判断

```shell
-r 有读的权限（read）			-w 有写的权限（write）
-x 有执行的权限（execute）
```

3. 按照文件类型进行判断

```shell
-f 文件存在并且是一个常规的文件（file）
-e 文件存在（existence）		-d 文件存在并是一个目录（directory）
```

## 流程控制

> 1. if 判断

```shell
# 1)then和if在同一行
if [ 条件判断式 ];then
	程序
fi

# then另起一行
if [ 条件判断式 ]
	then
		程序
fi

# 完整结构
if [ 条件判断式 ]
	then
		程序
elif [ 条件判断式 ]
	then
		程序
else
	程序
fi
```

* 注意：
  * [ 条件判断式 ]，中括号和条件判断式之间必须有空格
  * if 后要有空格

> 2. case语句

```shell
case $变量名 in
	"值1")
		如果变量的值等于值1，则执行程序1
	;;
	
	"值2")
		如果变量的值等于值2，则执行程序2
	;;
	...省略其它分支...
	*)
		如果变量的值都不是以上的值，则执行此程序 
	;;
esac
	
```

* 注意：
  * case行尾必须为 " in "，每一个模式匹配必须以右括号结束
  * 双分号 " ;; "，表示程序结束，相当于java中的break
  * " *) "：表示默认模式，相当于java中的default
  * 结尾以esac结束

> 3. for循环

1. 基本语法1（普通for循环）

```shell
for((初始值;循环控制条件;变量变化))
	do
		程序
	done
```

* 案例实操：从1加到100

```shell
#!/bin/bash
s=0
for((i=0;i<=100;i++))
do
	s=$[$s+$i]
done
echo $s
```

2. 基本语法2（foreach）

```shell
for 变量 in 值1 值2 值3 ...
	do 
		程序
	done
```

> 4. while循环

1. 基本语法

```shell
while [ 条件判断式 ]
	do
		程序
	done
```

2. 案例实操：从1加到100

```shell
#!/bin/bash
s=0
i=0
while [ $i -lt 100 ]
do
	s=$[$s+$i]
	i=$[$i+1]
done
echo $s
```

## read读取控制台输入

* 基本语法

```shell
read(选项)(参数)
选项：
-p：指定读取值时的提示符；
-t：指定读取值时等待的时间（秒）。
参数
	变量：指定读取值的变量名
```

* 提示7秒内，读取控制台输入的名称

```shell
#!/bin/bash
read -t 7 -p "Enter your name in 7 seconds " NAME
echo $NAME
```

## 函数

> 系统函数

1. basename基本语法：`basename [string / pathname] [suffix]`       

   * 功能描述：basename命令会删掉所有的前缀包括最后一个（‘/’）字符，然后将字符串显示出来

   * 选项：

     suffix为后缀，如果被指定了，会将或中的去掉

```shell
[atguigu@hadoop100 datas]$ basename /home/atguigu/datas/while.sh 
while.sh
[atguigu@hadoop100 datas]$ basename /home/atguigu/datas/while.sh .sh
while
```

2. dirname基本语法：`dirname 文件绝对路径 `
   * 功能描述：从给定的包含绝对路径的文件名中去除文件名（非目录的部分），然后返回剩下的路径（目录的部分）

```shell
[atguigu@hadoop100 datas]$ dirname /home/atguigu/datas/while.sh
/home/atguigu/datas
```

> 自定义函数

1. 基本语法

```shell
[ function ] funname[()]
{
	Action;
	[return int;]
}
funname
```

2. 经验技巧
   * 必须在调用函数地方之前，先声明函数，shell脚本是逐行运行。不会像其它语言一样先编译。
   * 函数返回值，只能通过$?系统变量获得，可以显示加：return返回，如果不加，将以最后一条命令运行结果，作为返回值。return后跟数值n(0-255)

## Shell工具

> 1. cut

* cut的工作就是“剪”，具体的说就是在文件中负责剪切数据用的。cut 命令从文件的每一行剪切字节、字符和字段并将这些字节、字符和字段输出。
* 不会改变原文件内容

1. 基本用法

`cut [选项参数]  filename` 

说明：默认分隔符是制表符

| 选项参数 | 功能                                |
| -------- | ----------------------------------- |
| -f       | 列号，提取第几列                    |
| -d       | 分隔符，按照指定分隔符分割列        |
| -f  n-   | n  为行号，n- 表示第n列以后的所有列 |

> 2. sed

* sed是一种**流编辑器**，它一次处理一行内容。处理时，把当前处理的行存储在临时缓冲区中，称为“模式空间”，接着用sed命令处理缓冲区中的内容，处理完成后，把缓冲区的内容送往屏幕。接着处理下一行，这样不断重复，直到文件末尾。**文件内容并没有改变，除非你使用重定向存储输出**

1. 基本语法

`sed [选项参数]  ‘command’  filename`

2. 选项参数

| 选项参数 | 功能                                                         |
| -------- | ------------------------------------------------------------ |
| -e       | 直接在指令列模式上进行sed的动作编辑，在一次编辑多个地方的时候使用 |

3. 命令功能描述

| 命令 | 功能描述                              |
| ---- | ------------------------------------- |
| *a*  | 新增，a的后面可以接字串，在下一行出现 |
| d    | 删除                                  |
| s    | 查找并替换                            |

4. 案例实操

```shell
# 数据准备
[atguigu@hadoop102 datas]$ touch sed.txt
[atguigu@hadoop102 datas]$ vim sed.txt
dong shen
guan zhen
wo  wo
lai  lai

le  le

# 将“mei nv”这个单词插入到sed.txt第二行下，打印
[atguigu@hadoop102 datas]$ sed '2a mei nv' sed.txt 
dong shen
guan zhen
mei nv
wo  wo
lai  lai

le  le

# 删除sed.txt文件所有包含wo的行，/wo/：正则表达式
[atguigu@hadoop102 datas]$ sed '/wo/d' sed.txt
dong shen
guan zhen
lai  lai

le  le

# 将sed.txt文件中wo替换为ni，g=global，否则只会替换一个wo
[atguigu@hadoop102 datas]$ sed 's/wo/ni/g' sed.txt 
dong shen
guan zhen
ni  ni
lai  lai

le  le

# 将sed.txt文件中的第二行删除并将wo替换为ni
# 注意：如果执行多条相同的命令，不加-e只会执行一个
[atguigu@hadoop102 datas]$ sed -e '2d' -e 's/wo/ni/g' sed.txt 
dong shen
ni  ni
lai  lai

le  le
```

> 3. awk

* 一个强大的文本分析工具，把文件逐行的读入，以空格为默认分隔符将每行切片，切开的部分再进行分析处理。

1. 基本语法

`awk [选项参数] ‘pattern1{action1}  pattern2{action2}...’ filename`

* pattern：表示AWK在数据中查找的内容，就是匹配模式

* action：在找到匹配内容时所执行的一系列命令

**注意：这里的模式匹配需要使用单引号，因为双引号会对正则的一些特殊符号处理**

2. 选项参数说明

| 选项参数 | 功能                 |
| -------- | -------------------- |
| -F       | 指定输入文件折分隔符 |
| -v       | 赋值一个用户定义变量 |

3. 案例实操

```shell
# 数据准备
[atguigu@hadoop102 datas]$ sudo cp /etc/passwd ./
#（1）搜索passwd文件以root关键字开头的所有行，使用冒号切分，并输出该行的第7列。
[atguigu@hadoop102 datas]$ awk -F: '/^root/{print $7}' passwd 
/bin/bash

#（2）搜索passwd文件以root关键字开头的所有行，使用冒号切分，并输出该行的第1列和第7列，中间以“，”号分割。
[atguigu@hadoop102 datas]$ awk -F: '/^root/{print $1","$7}' passwd 
root,/bin/bash
# 注意：只有匹配了pattern的行才会执行action

#（3）对/etc/passwd用冒号切分后，只显示第一列和第七列，然后以逗号分割，且在所有行前面添加列名user，shell在最后一行添加"banzhang，/bin/zuishuai"。
[atguigu@hadoop102 datas]$ awk -F : 'BEGIN{print "user, shell"} {print $1","$7} END{print "banzhang,/bin/zuishuai"}' passwd
user, shell
root,/bin/bash
bin,/sbin/nologin
。。。
atguigu,/bin/bash
banzhang,/bin/zuishuai
# 注意：BEGIN 在所有数据读取行之前执行；END 在所有数据执行之后执行。

#（4）将passwd文件中的用户id增加数值1并输出  注意：i取值的时候不需要加$
[atguigu@hadoop102 datas]$ awk -v i=1 -F: '{print $3+i}' passwd
1
2
3
4

```

4. awk的内置变量

| 变量     | 说明                                   |
| -------- | -------------------------------------- |
| FILENAME | 文件名                                 |
| NR       | 已读的记录数(行数)                     |
| NF       | 浏览记录的域的个数（切割后，列的个数） |

```shell
#（1）统计使用冒号切分passwd后，文件名，每行的行号，每行的列数
[atguigu@hadoop102 datas]$ awk -F: '{print "filename:"  FILENAME ", linenumber:" NR  ",columns:" NF}' passwd 
filename:passwd, linenumber:1,columns:7
filename:passwd, linenumber:2,columns:7
filename:passwd, linenumber:3,columns:7
#（2）切割IP
[atguigu@hadoop102 datas]$ ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk -F " " '{print $1}' 
192.168.1.102
```

* awk与cut命令的区别
  * awk 以空格为分割域时,是以单个或多个连续的空格为分隔符的
  * cut则是以单个空格作为分隔符

> 4. sort

* 它将文件进行排序，并将排序结果标准输出

1. 基本语法

`sort(选项)(参数)`

| 选项 | 说明                     |
| ---- | ------------------------ |
| -n   | 依照数值的大小排序       |
| -r   | 以相反的顺序来排序       |
| -t   | 设置排序时所用的分隔字符 |
| -k   | 指定需要排序的列         |

参数：指定待排序的文件列表

2. 案例实操

````shell
# 数据准备
[atguigu@hadoop102 datas]$ touch sort.txt
[atguigu@hadoop102 datas]$ vim sort.txt
aaa:10:1.1
ccc:30:3.3
ddd:40:6.6
bbb:20:2.2
eee:50:5.5

# 默认排序
[atguigu@hadoop100 datas]$ sort sort.txt 
aaa:10:1.1
bbb:20:2.2
ccc:30:3.3
ddd:40:4.4
eee:50:5.5

# 按照“：”分割后的第三列倒序排序。
[atguigu@hadoop100 datas]$ sort -t : -nrk 3 sort.txt 
eee:50:5.5
ddd:40:4.4
ccc:30:3.3
bbb:20:2.2
aaa:10:1.1
````


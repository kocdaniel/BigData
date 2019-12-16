## hive启动时错误1

```
Cannot execute statement:impossible to write to binary long since BINLOG_FORMAT = STATEMENT...
当启动时报错
Caused by: javax.jdo.JDOException:Couldnt obtain a new sequence(unique id):Cannot execute statement:impossible to write to binary log since BINLOG_FORMAT = STATEMENT and at least one table uses a storage engine limited to row-logging when transaction isolation level is READ COMMITTED or READ UNCOMMITED.
NestedThrowables: java.sql.SQLException:Cannot execute statement:impossible to write to binary log since BINLOG_FORMAT = STATEMENT and at least one table uses a storage engine limited to row-based logging. InnoDB is limited to row-logging when transaction isolation level is READ COMMITED or READ UNCOMMITED.
```

```
原因：这是由于hive的元数据存储MYSQL配置不当引起的

解决方案1（临时解决）：mysql> set global binlog_format='MIXED'

解决方案2（永久解决）：
修改/etc/my.cnf,添加属性
# binary logging format - mixed recommended 
binlog_format=mixed
```

## hive启动时错误2

```
Exception in thread "main" java.lang.IncompatibleClassChangeError: Found class jline.Terminal, but interface was expected
	at jline.console.ConsoleReader.<init>(ConsoleReader.java:230)
	at jline.console.ConsoleReader.<init>(ConsoleReader.java:221)
	at jline.console.ConsoleReader.<init>(ConsoleReader.java:209)
	at org.apache.hadoop.hive.cli.CliDriver.setupConsoleReader(CliDriver.java:787)
	at org.apache.hadoop.hive.cli.CliDriver.executeDriver(CliDriver.java:721)
	at org.apache.hadoop.hive.cli.CliDriver.run(CliDriver.java:681)
	at org.apache.hadoop.hive.cli.CliDriver.main(CliDriver.java:621)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:498)
	at org.apache.hadoop.util.RunJar.run(RunJar.java:221)
	at org.apache.hadoop.util.RunJar.main(RunJar.java:136)
```

```
原因：
hadoop目录下存在老版本jline：
/hadoop-2.7.2/share/hadoop/yarn/lib：
-rw-r--r-- 1 root root   87325 Mar 10 18:10 jline-0.9.94.jar

解决：
将hive安装路径下的lib目录下的jline-版本号.jar文件拷贝到hadoop安装目录/share/hadoop/yarn/lib下即可
如：cp -r /hive/lib/jline-2.12.jar /hadoop-2.7.2/share/hadoop/yarn/lib
```

## hive建表时出现

```
Error: Error while processing statement: FAILED: Execution Error, return code 1 from org.apache.hadoop.hive.ql.exec.DDLTask. MetaException(message:For direct MetaStore DB connections, we don't support retries at the client level.) (state=08S01,code=1)。
```

```
原因：在创建mysql时使用的字符集不对，需要修改hive数据库的字符集。
解决：在mysql中使用命令修改hive数据库字符集：alter database hive character set latin1;
```

## 在drop表时卡死

```
原因：由于是先创建的表，之后再修改的hive数据库的字符集，所以卡死。
解决：
1. 进入mysql,将mysql下建立的元数据库hive删除，再使用mysql重新创建，创建后修改字符集为latin1，在mysql删除hive数据库时，需要将hive停止，不然mysql也会卡死。
2. 也可以修改/etc/my.cnf文件，将里边涉及到字符的属性都设置为latin1
```


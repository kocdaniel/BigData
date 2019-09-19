# File

## File类及其方法：

```java
@Test
	public void testName() throws Exception {
		File file = new File("nums.txt");
		//new FileInputStream(file);
		System.out.println("file.canRead() : " + file.canRead());
		System.out.println("file.canWrite() : " + file.canWrite());
		System.out.println("file.getAbsolutePath() : " + file.getAbsolutePath());
		System.out.println("file.getCanonicalPath() : " + file.getCanonicalPath()); // 获取标准路径
		System.out.println("file.getFreeSpace() : " + file.getFreeSpace());
		System.out.println("file.getName() : " + file.getName());
		System.out.println("file.getTotalSpace() : " + file.getTotalSpace());
		System.out.println("file.lastModified() : " + file.lastModified());
		System.out.println("file.length() : " + file.length());
		//System.out.println("file.createNewFile() : " + file.createNewFile());
		
		System.out.println("file.exists() : " + file.exists());
		System.out.println("file.isDirectory() : " + file.isDirectory());
		System.out.println("file.isFile() : " + file.isFile());
		
		System.out.println("file.delete() : " + file.delete());
	}
```

# 多线程

## 程序，进程与线程

 * **程序** : 保存在硬盘上的静态文件
 * **进程** : 在内存中处于运行状态的程序, 有生命周期, 一个程序可以启动多个进程(实例), 进程之间不可以直接通信 
 * **线程** : 进程中的一个子任务, 线程也有生命周期, 一个线程对应一个运行栈, 线程之间通信方便

    使用Thread类来描述, 创建一个Thread对象, 就相当于创建线程对象, 一个线程对象内部包含一个栈.

## 创建并启动线程的方式

### 方式 1 : 实现的方式 

 1. 写一个具体类, 让这个类实现Runnable接口, 并实现run方法, 这个run方法就相当于线程的入口(线程体)
 2. 创建这个类的对象, 并以它为实参再创建 Thread对象, 这个Thread对象就是线程对象
 3. 调用Thread对象的start方法启动子线程

```java
//1) 写一个具体类, 让这个类实现Runnable接口, 并实现run方法, 这个run方法就相当于线程的入口(线程体)
public class HelloRunner implements Runnable {
	
	private int i = 0;

	@Override
	public void run() {
		for (; i < 100; i++) {
			System.out.println(Thread.currentThread().getName() + " : " + i);
		}
	}

}
// 主方法
public class HelloRunnerTest {
	
	public static void main(String[] args) {
	    // 创建这个类的对象
		Runnable runnable = new HelloRunner();
		// 以它为实参再创建 Thread对象
		Thread thread = new Thread(runnable); // 建新栈
		thread.setName("子线程1");
		// 调用Thread对象的start方法启动子线程
		thread.start(); // 激活新栈, 并把run()压入新栈执行
		//thread.run();
		
		// 使用同一个Runnable对象可以创建多个子线程, 或者也可以再使用另外的Runnable对象
		Thread thread2 = new Thread(runnable);
		thread2.setName("子线程2");
		thread2.start();
		
		Thread.currentThread().setName("主线程");
		for (int i = 0; i < 100; i++) {
			System.out.println(Thread.currentThread().getName() + " : " + i);
		}

	}
}
```



### 方式2 : 继承的方式

 1. 写一个具体类, 让这个类继承Thread类, 并重写run方法, 这个run方法就是线程的入口(线程体)
 2. 创建这个类的对象, 就相当于创建了一个线程对象(建了一个新栈)
 3. 调用对象的start方法, 激活栈, 并压入run方法

```java
// 自定义继承类
class MyThread extends Thread {
	
	@Override
	public void run() {
		for (int i = 0; i < 100; i++) {
			System.out.println(Thread.currentThread().getName() + " : " + i);
		}
	}
}

// 主方法
public class ThreadTest {
	
	public static void main(String[] args) {
		MyThread myThread = new MyThread();
		myThread.start();
	}	
}
```

### 线程状态（有5种）

 1. 新建 ( new Thread())
 2. 就绪 (start()) -> 失去CPU执行权, 解除阻塞后 
 3. 运行 (获取CPU执行权)
 4. 阻塞 (sleep, join, wait, 同步)
 5. 死亡 (run结束) 

![1565958127065](C:\Users\gengqing\AppData\Roaming\Typora\typora-user-images\1565958127065.png)

### 线程分类 :

 1. **守护线程** : 为用户线程服务的, 如果用户线程死掉, 守护线程也死, 在start()前设置，（守护线程是用来服务用户线程的，通过在start()方法前调用`thread.setDaemon(true)`可以把一个用户线程变成一个守护线程。）
 2. **用户线程** : 用户线程, 被守护线程守护的. 进程中只要还有一个用户线程, 进程就不会结束.
 3. **主线程永远无法设置为守护线程**

### 线程的同步


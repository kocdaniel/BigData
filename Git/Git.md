# Git
## 常用命令

>工作区，暂存区和本地库的理解

* 工作区：电脑本地的项目目录
* 本地库：工作区的隐藏文件夹`.git`，即Git的本地库
* 暂存区：一般存放在工作目录下的`.git/index`中，暂存区有时也叫索引
最终向github提交的都是`.git`下的内容

![https://github.com/kocdaniel/BigData/blob/master/img/git%E6%8F%90%E4%BA%A4.png](https://github.com/kocdaniel/BigData/blob/master/img/git提交.png)


>创建版本库

* 在项目文件夹内执行：`git init`
* 执行之后会在项目文件夹内生成一个`.git`文件夹，即Git的**本地库**

>提交文件

* `git status`:查看文件状态
* `git add 文件名`：将文件添加到暂存区
* `git commit `：编写注释，并完成提交，提交到`.\.git\refs\heads`目录下
* `git commit -m "注释"`：直接带注释提交

>查看文件提交记录

* `git log 文件名`：查看历史记录
* `git log --pretty=oneline 文件名`：简易信息查看

>回退历史

* `git reset --hard HEAD^`：回退到上一次提交
* `git reset --hard HEAD~n`：回退n此操作

>版本穿越

* `git reflog 文件名`：查看历史记录的版本号
* `git reset --hard 版本号`：穿越

>还原文件

* `git checkout -- 文件名`：还原文件，**在没有add和commit的前下，不可撤销**

>删除文件

* 先删除文件
* 再`git add 删除的文件名`：需要同步到本地库

>分支

* `git branch 分支名`：创建分支
* `git branch -v` ：查看分支
* `git branch -d 分支名`：删除分支
* `git checkout 分支名`：切换分支
* `git checkout -b 分支名`：创建新分支并跳转

>合并分支

* `git checkout master`：切换到主分支
* `git merge 分支名`：合并分支到主分支

>合并冲突及解决

* 冲突一般指**同一个文件同一位置**的代码，
* 在两种版本合并时版本管理软件无法判断到底应该保留哪个版本，
* 因此会提示该文件发生冲突，需要程序员来手工判断解决冲突。
* 程序合并时发生冲突系统会提示CONFLICT关键字，命令行后缀会进入MERGING状态，表示此时是解决冲突的状态。
* 需要程序员vim手动编辑保留哪一个版本
* 可以通过`git diff`查看发生冲突的文件及冲突的内容
* 然后修改冲突文件的内容，再次`git add <file>` 和`git commit` 提交后，
* 后缀MERGING消失，说明冲突解决完成。

>将本地库推送到github

* 增加远程地址：`git remote add origin url`
    * origin远程代号，一般为origin，可以自定义
    * url：远程仓库的地址

* 推送到远程库：`git push origin master`
    * origin：远程代号
    * master：本地分支名称

>从github上克隆一个项目

* `git clone 远程地址 新项目目录名`

>从github更新项目，即将github上最新的版本更新到本地库

* git pull 远程代号 远程分支名

## 在eclipse上使用Git

>配置用户名，email

* Windows-->Preferences-->Team-->Git-->Configuration
* 编辑器会自动加载.gitconfig文件
* ![gitconfig](https://github.com/kocdaniel/BigData/blob/master/img/gitconfig.png)

>检查SSH key

* ![ssh](https://github.com/kocdaniel/BigData/blob/master/img/sshkey.png)

>新建javaWeb项目，并将其纳入Git管理

1. 选中工程鼠标右键->Team->Share Projects->Git

![share](https://github.com/kocdaniel/BigData/blob/master/img/shareproject.png)

2. 勾选上方Use or create repository...->选中项目->点击create Respository->Finish

![create](https://github.com/kocdaniel/BigData/blob/master/img/createrespository.png)

3. 初始化完成后，项目后缀显示NO-HEAD，表示版本库已建立，但是还没有提交任何文件，所以没有主干分支

![nohead](https://github.com/kocdaniel/BigData/blob/master/img/nohead.png)

4. commit提交：Team->commit,将要提交的文件拖入左下方，实现git add（也可以单独git add ：Team -> add to index），右边填写注释。点击commit，完成一次本地提交，这时可以看到项目名称后缀多了个master

![commit](https://github.com/kocdaniel/BigData/blob/master/img/commit.png)

![master](https://github.com/kocdaniel/BigData/blob/master/img/master.png)

>与远程库的交互

1. 在github上新建一个同名的空仓库
2. 项目名称上右键：Team -> Push Branch 'master'，即可push到remote

![push1](https://github.com/kocdaniel/BigData/blob/master/img/push1.png)

3. 填写push信息，将远程仓库的地址复制到url中，并填写用户名和密码

![push2](https://github.com/kocdaniel/BigData/blob/master/img/push2.png)

4. 指定push的本地分支和远程分支

![push3](https://github.com/kocdaniel/BigData/blob/master/img/push3.png)

5. finish即可，然后到github上查看代码
6. 远程库如果更新，可以pull到本地仓库，填写的信息和push类似

![pull](https://github.com/kocdaniel/BigData/blob/master/img/pull.png)

## GitFlow

![gitflow](https://github.com/kocdaniel/BigData/blob/master/img/gitflow.png)


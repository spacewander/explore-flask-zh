![环境](images/environment.png)

# 环境

为了正确地跑起来，你的应用需要依赖许多不同的软件。
就算是再怎么否认这一点的人，也无法否认至少需要依赖Flask本身。
你的应用的**运行环境**，在当你想要让它跑起来时，是至关重要的。
幸运的是，我们有许多工具可以减低管理环境的复杂度。

## 使用virtualenv来管理环境

[virtualenv](http://www.virtualenv.org/en/latest/)是一个能把你的应用隔离在一个**虚拟环境**中的工具。
一个虚拟环境是一个包含了你的应用依赖的软件的文件夹。一个虚拟环境同时也封存了你在开发时的环境变量。
与其把依赖包，比如Flask，下载到你的系统包管理文件夹，或用户包管理文件夹，我们可以把它下载到对应当前应用的一个隔离的文件夹之下。
这使得你可以指定一个特定的Python二进制版本，取决于当前开发的项目。

virtualenv也可以让你给不同的项目指定同样的依赖包的不同版本。
当你在一个老旧的包含众多不同项目的平台上开发时，这种灵活性十分重要。

用了virtualenv，你将只会把少数几个Python模块安装到系统的全局空间中。其中一个会是virtualenv本身：

```sh
# 使用pip安装virtualenv
$ pip install virtualenv
```

安装完virtualenv，就可以开始创建虚拟环境。切换到你的项目文件夹，运行`virtualenv`命令。这个命令接受一个参数，作为虚拟环境的名字（同样也是它的位置，在当前文件夹`ls`下你就知道了）。

```sh
$ virtualenv venv
New python executable in venv/bin/python
Installing setuptools, pip...done.
```

这将创建一个包含所有依赖的文件夹。

一旦新的virtual environment已经准备就绪，你需要给对应的virtual environment下的`bin/activate`脚本执行`source`，来激活它。

```
$ source venv/bin/activate
```

你可以通过运行`which python`看到：“python”现在指向的是virtual environment中的二进制版本。

```sh
$ which python
/usr/local/bin/python
$ source venv/bin/activate
(venv)$ which python
/Users/robert/Code/myapp/venv/bin/python
```

当一个virtual environment被激活了，依赖包会被pip安装到virtual environment中而不是全局系统环境。

你也许注意到了，你的shell提示符发生了改变。
virtualenv在它前面添加了当前被激活的virtual environment，所以你能意识到你并不存在于全局系统环境中。

运行`deactivate`命令，你就能离开你的virtual environment。

```
(venv)$ deactivate
$
```

## 使用virtualenvwrapper管理你的virtual environment

我想要让你了解到[virtualenvwrapper](http://virtualenvwrapper.readthedocs.org/en/latest/)对于前面的工作做了什么改进，这样你就知道为什么你应该使用它。

虚拟环境文件夹现在已经位于你的项目文件夹之下。
但是你仅仅是在激活了虚拟环境后才会跟它交互。它甚至不应该被放入版本控制中。所以它呆在项目文件夹中也是挺碍眼的。
解决这个问题的一个方法就是使用virtualenvwrapper。这个包把你所有的virtual environment整理到单独的文件夹下，通常是`~/.virtualenvs/`。

要安装virtualenvwrapper，遵循这个[文档](http://virtualenvwrapper.readthedocs.org/en/latest/)中的步骤。

> **注意**
> 确保你在安装virtualenvwrapper时不在任何一个virtual environment中。你需要把它安装在全局空间，而不是一个已存在的virtual environment中

现在，你不再需要运行`virtualenv`来创建一个环境，只需运行`mkvirtualenv`：

```sh
$ mkvirtualenv rocket
New python executable in rocket/bin/python
Installing setuptools, pip...done.
```

在你的virtual environment目录之下，比如在`~/.virtualenv`之下，`mkvirtualenv`创建了一个文件夹，并替你激活了它。
就像普通的`virtualenv`，`python`和`pip`现在指向的是virtual environment而不是全局系统。
为了激活想要的环境，运行这个命令：`workon [environment name]`，而`deactivate`依然会关闭环境。

## 记录依赖变动

随着项目增长，你会发现它的依赖列表也一并随着增长。在你能运行一个Flask应用之前，即使已经需要数以十记的依赖包也毫不奇怪。
管理依赖的最简单的方法就是使用一个简单的文本文件。
pip可以生成一个文本文件，列出所有已经安装的包。它也可以解析这个文件，并在新的系统（或者新的环境）下安装每一个包。

### pip freeze

**requirements.txt**是一个常常被许多Flask应用用于列出它所依赖的包的文本文件。它是通过`pip freeze > requirements.txt`生成的。
使用`pip install -r requirements.txt`，你就能安装所有的包。

> **注意**
> 在freeze或install依赖包时，确保你正为于正确的virtual environment之中。

### 手动记录依赖变动

随着项目增长，你可能会发现`pip freeze`中列出的每一个包并不再是运行应用所必须的了。
也许有些包只是在开发时用得上。`pip freeze`没有判断力；它只是列出了当前安装的所有的包。所以你只能手动记录依赖的变动了。
你可以把运行应用所需的包和开发应用所需的包分别放入对应的*require_run.txt*和*require_dev.txt*。

## 版本控制

选择一个版本控制系统并使用它。
我推荐Git。如我所知，Git是当下最大众的版本控制系统。
在删除代码的时候无需担忧潜在的巨大灾难是无价的。
你现在可以对过去那种把不要的代码注释掉的行为说拜拜了，因为你可以直接删掉它们，即使将来突然需要，也可以通过`git revert`来恢复。
另外，你将会有整个项目的备份，存在Github,Bitbucket或你自己的Git server。

### 什么不应该在版本控制里

我通常不把一个文件放在版本控制里，如果它满足以下两个原因中的一个。
1. 它是不必要的
2. 它是不公开的。

编译的产物，比如`.pyc`，和virtual environment（如果你因为某些原因没有使用virtualenvwrapper）正是前者的例子。
它们不需要加入到版本控制中，因为它们可以通过`.py`或`requirements.txt`生成出来。

接口密钥（调用接口时必须传入的参数），应用密钥，以及数据库证书则是后者的例子。
它们不应该在版本控制中，因为一旦泄密，将造成严重的安全隐患。

> **注意**
> 在做安全相关的决定时，我会假设稳定版本库将会在一定程度上被公开。这意味着要清除所有的隐私，并且永不假设一个安全漏洞不会被发现，
> 因为“谁能想到他们会干出什么事情？”

在使用Git时，你可以在版本库中创建一个特别的文件名为*.gitignore*。
在里面，能使用正则表达式来列出对应的文件。任何匹配的文件将被Git所忽略。
我建议你至少在其中加入`*.pyc`和`/instance`。instance文件夹中存放着跟你的应用相关的不便公开的配置。

```
.gitignore:
*.pyc
instance/
```

> **参见**
> * 在这里你可以了解什么是*.gitignore* : http://git-scm.com/docs/gitignore
> * Flask文档中对instance目录的一段介绍 : http://flask.pocoo.org/docs/config/#instance-folders

## 调试

### 调试模式

Flask有一个便利的特性叫做“debug mode”。在你的应用配置中设置`debug = True`就能启动它。
当它被启动后，服务器会在代码变动之后重新加载，并且一旦发生错误，错误会打印成一个带交互式命令行的调用栈。

> **注意**
> 不要在生产环境中开启debug mode。交互式命令行运行任意的代码输入，如果是在运行中的网站上，这将导致安全上的灾难性后果。

> **另见**
> - 阅读一下quickstart页面的debug mode部分 : http://docs.jinkan.org/docs/flask/quickstart.html#debug-mode
> - 这里有一些关于错误处理，日志记录和使用其他调试工具的信息 : http://docs.jinkan.org/docs/flask/errorhandling.html

### Flask-DebugToolbar

[Flask-DebugToolbar](http://flask-debugtoolbar.readthedocs.org/en/latest/) 是用来调试你的应用的另一个得力工具。在debug mode中，它在你的应用中添加了一个侧边条。
这个侧边条会给你提供有关SQL查询，日志，版本，模板，配置和其他有趣的信息。

## 总结

* 使用virtualenv来打包你的应用的依赖包。
* 使用virtualenvwrapper来打包你的virtual environment。
* 使用一个或多个文本文件来记录依赖变化。
* 使用一个版本控制系统。我推荐Git。
* 使用.gitignore来排除不必要的或不能公开的东西混进版本控制。
* debug mode会在开发时给你有关bug的信息。
* Flaks-DebugToolbar拓展将给你有关bug更多的信息。

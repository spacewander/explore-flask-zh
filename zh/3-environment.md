![Environment](images/3.png)

# 环境

Your application is probably going to require a lot of software to function properly. If it doesn’t at least require the Flask package, you may be reading the wrong book. Your application’s **environment** is essentially all of the things that need to be around when it runs. Lucky for us, there are a number of things that we can do to make managing our environment much less complicated.

为了正确地跑起来，你的应用需要依赖许多不同的软件。
就算是再怎么否认这一点的人，也无法否认至少需要依赖Flask本身。
你的应用的**运行环境**，在当你想要让它跑起来时，是至关重要的。
幸运的是，我们有许多工具可以减低管理环境的复杂度。

## 使用virtualenv来管理环境

virtualenv is a tool for isolating your application in what is called a **virtual environment**. A virtual environment is a directory that contains the software on which your application depends. A virtual environment also changes your environment variables to keep your development environment contained. Instead of downloading packages, like Flask, to your system-wide — or user-wide — package directories, we can download them to an isolated directory for our current application. This makes it easy to specify which Python binary to use, which dependencies want to have available on a per project basis.

virtualenv是一个能把你的应用隔离在一个**virtual environment**的环境中的工具。
一个virtual environment是一个包含了你的应用依赖的软件的文件夹。一个virtual environment同时也封存了你在开发时的环境变量。
与其把依赖包，比如Flask，下载到你的系统包管理文件夹，或用户包管理文件夹，我们可以把它下载到对应当前应用的一个隔离的文件夹之下。
这使得你可以指定一个特定的Python二进制版本，取决于当前开发的项目。

Virtualenv also lets you use different versions of the same package for different projects. This flexibility may be important if you’re working on an older system with several projects that have different version requirements.

virtualenv也可以让你给不同的项目指定同样的依赖包的不同版本。
当你在一个包含众多不同项目的老旧的平台上开发时，这种灵活性十分重要。

When using virtualenv, you'll generally have only a few Python packages installed globally on your system. One of these will be virtualenv itself:

用了virtualenv，你将只会把少数几个Python模块安装到系统的全局空间中。其中一个会是virtualenv本身：

```
$ pip install virtualenv
```

Then, when you are inside your project directory, you'll create a new virtual environment with virtualenv:

接着，当你位于你的项目文件夹时，你可以通过virtualenv创建一个新的virtual environment

```
$ virtualenv venv
```

This creates a new directory where the dependencies will be installed.

这将创建一个包含所有依赖的文件夹。

{ NOTE: The argument passed to `virtualenv` is the destination directory of the virtual environment. It can be anything you'd like. }

{ NOTE: 传递给`virtualenv`的参数是virtual environment的目标文件夹。这个取决于你的具体情况。 }

Once the new virtual environment has been created, you must activate it by sourcing the `bin/activate` script that was created inside the virtual environment:

一旦新的virtual environment已经准备就绪，你需要给对应的virtual environment下的`bin/activate`脚本执行`source`，来激活它。

```
$ source venv/bin/activate
```

This script makes some changes to your shell's environment variables so that everything points to the new virtual environment instead of your global system. You can see the effect by running `which python`; “python” now refers to the Python binary in the virtual environment. When a virtual environment is active, dependencies installed with Pip will be downloaded to that virtual environment instead of the global system.

这个脚本对你的shell的环境变量施加了魔法，让它们指向新的virtual environment而不是你的全局系统环境。
你可以通过运行`which python`看到：“python”现在指向的是virtual environment中的二进制版本。
当一个virtual environment被激活了，依赖包会被pip安装到virtual environment中而不是全局系统环境。

You may notice that your shell prompt has been changed too. virtualenv prepends the name of the currently activated virtual environment, so you know that you're not working on the global system.

你也许注意到了，你的shell提示符发生了改变。
virtualenv在它前面添加了当前被激活的virtual environment，所以你能意识到你并不存在于全局系统环境中。

You can deactivate your virtual environment by running the `deactivate` command.

运行`deactivate`命令，你就能离开你的virtual environment。

```
(venv)$ deactivate
$
```

## 使用virtualenvwrapper管理你的virtual environment

I didn't want to mention **virtualenvwrapper** until you had seen the basics of virtualenv. I wanted to make that you understand what virtualenvwrapper is improving upon, so that you’ll understand why you’d want to use it.

在你了解了virtualenv的基本知识后，是时候提及**virtualenvwrapper**了。
我想要让你了解到virtualenvwrapper对于前面的工作做了什么改进，这样你就知道为什么你需要使用它。

The virtual environment directory adds clutter to your project repository. You only interact with it directly when activating the virtual environment. It shouldn’t even be in version control. The solution to this clutter is to use virtualenvwrapper. This package keeps all of your virtual environments out of the way in a single directory, usually `~/.virtualenvs/`.

virtual environment文件夹现在已经是你的项目文件夹的一部分。
但是你仅仅是在激活了virtual environment后才会跟它交互。它甚至不应该被放入版本控制中。
解决这个问题的一个方法就是使用virtualenvwrapper。这个包把你所有的virtual environment整理到单独的文件夹下，通常是`~/.virtualenvs/`。

To install virtualenvwrapper, follow the instructions in the documentation [http://virtualenvwrapper.readthedocs.org/en/latest/].

要安装virtualenvwrapper，遵循这个[文档](http://virtualenvwrapper.readthedocs.org/en/latest/)中的步骤。

{ WARNING: Make sure that you've deactivated all virtual environments before installing virtualenvwrapper. You want it installed globally, not in a pre-existing environment. }

{ WARNING: 确保你在安装virtualenvwrapper时不在任何一个virtual environment中。你需要把它安装在全局空间，而不是一个已存在的virtual environment中 }

Now, instead of running `virtualenv` to create an environment, you’ll run `mkvirtualenv`:

现在，你不再需要运行`virtualenv`来创建一个环境，只需运行`mkvirtualenv`：

```
$ mkvirtualenv rocket
New python executable in rocket/bin/python
Installing setuptools............done.
Installing pip...............done.
```

`mkvirtualenv` creates a directory in your virtual environments folder, e.g. `~/.virtualenvs`, and activates it for you. Just like with plain old `virtualenv`, `python` and `pip` now point to that virtual environment instead of the global system. To activate a particular environment, use the command: `workon [environment name]`. `deactivate` still deactivates the environment.

在你的virtual environment目录之下，比如在`~/.virtualenv`之下，`mkvirtualenv`创建了一个文件夹，并替你激活了它。
就像普通的`virtualenv`，`python`和`pip`现在指向的是virtual environment而不是全局系统。
为了激活想要的环境，运行这个命令：`workon [environment name]`，而`deactivate`依然会关闭环境。

## 记录依赖变动

As a project grows, you’ll find that the list of dependencies grows with it. It’s not uncommon to need dozens of Python packages installed before you can even run a Flask application. The easiest way to manage these is with a simple text file. Pip can generate a text file listing all installed packages. It can also read in this list to install each of them on a new system, or in a freshly minted environment.

随着项目增长，你会发现它的依赖列表也一并随着增长。在你能运行一个Flask应用之前，即使已经需要数以十记的依赖包也毫不奇怪。
管理依赖的最简单的方法就是使用一个简单的文本文件。
pip可以生成一个文本文件，列出所有已经安装的包。它也可以解析这个文件，并在新的系统（或者新的环境）下安装每一个包。

### pip freeze

**requirements.txt** is a text file used by many Flask applications to list all of the packages needed to run an application. It is generated by running `pip freeze > requirements.txt`. The list can be installed later using `pip install -r requirements.txt`.

**requirements.txt**是一个常常被许多Flask应用用于列出它所依赖的包的文本文件。它是通过`pip freeze > requirements.txt`生成的。
使用`pip install -r requirements.txt`，你就能安装所有的包。

{ Warning: Make sure that you are operating in the correct virtual environments when freezing and installing dependencies. }

{ Warning: 在freeze或install依赖包时，确保你正为于正确的virtual environment之中。 }

### 手动记录依赖变动

As your project grows, you may find that certain packages listed by `pip freeze` aren’t actually needed to run the application. You’ll have packages that are installed for development only. `pip freeze` doesn’t discriminate; it just lists the packages that are currently installed. As a result you may want to manually track your depencies as you add them. You can separate those packages need to run your application and those needed to develop your application into *require_run.txt* and *require_dev.txt* respectively.

随着项目增长，你可能会发现`pip freeze`中列出的每一个包并不再是运行应用所必须的了。
也许有些包只是在开发时用得上。`pip freeze`没有判断力；它只是列出了当前安装的所有的包。所以你只能手动记录依赖的变动了。
你可以把运行应用所需的包和开发应用所需的包分别放入对应的*require_run.txt*和*require_dev.txt*。

## 版本控制

Pick a version control system and use it. I recommend Git. From what I've seen, Git is the most popular choice for projects these days. Being able to delete code without worrying about making a critical mistake is invaluable. You’ll be able to keep your project free of massive blocks of commented out code, because you can delete it now and revert that change later should the need arise. Plus, you’ll have backup copies of your entire project on GitHub, Bitbucket, or your own Gitolite server.

选择一个版本控制系统并使用它。
我推荐Git。如我所知，Git是当下最大众的版本控制系统。
在删除代码的时候无需担忧潜在的巨大灾难是无价的。
你现在可以对过去那种把不要的代码注释掉的行为说拜拜了，因为你可以直接删掉它们，即使将来突然需要，也可以通过`git revert`来恢复。
另外，你将会有整个项目的备份，存在Github,Bitbucket或你自己的Git server。

### 什么不应该在版本控制里

I usually keep a file out of version control for one of two reasons. Either it’s clutter, or it’s a secret. Compiled files, e.g. `.pyc` files and virtual environments (if you’re not using virtualenvwrapper for some reason) are examples of clutter. They don’t need to be in version control because they can be generated from `.py` files and `requirements.txt` respectively. API keys, application secret keys, and database credentials are examples of secrets. They shouldn’t be in version control because their exposure would be a massive breach of security.

我通常不把一个文件放在版本控制里，如果它满足以下两个原因中的一个。
要么它是不必要的，要么它是不公开的。
编译的产物，比如`.pyc`，和virtual environment（如果你因为某些原因没有使用virtualenvwrapper）正是前者的例子。
它们不需要加入到版本控制中，因为它们可以通过`.py`或`requirements.txt`生成出来。
接口密钥（调用接口时必须传入的参数），应用密钥，以及数据库证书则是后者的例子。
它们不应该在版本控制中，因为一旦泄密，将造成严重的安全隐患。

{ NOTE: When making security related decisions, I assume that my repository will become public at some point. This means keeping secrets out, and never assuming that a security hole won’t be found because, “Who’s going to guess that they could do that?” }

{ NOTE: 在做安全相关的决定时，我会假设稳定版本库将会在一定程度上被公开。这意味着要清除所有的隐私，并且永不假设一个安全漏洞不会被发现，
因为“谁能想到他们会干出什么事情？”}


When using Git, you can create a special file called *.gitignore* in your repository. In it, list regular expression patterns to match against filenames. Any filename that matches one of the patterns will be ignored by Git. I recommend ignoring `*.pyc` and `/instance` to get you started. Instance folders are used to make secret configuration variables available to your application.

在使用Git时，你可以在版本库中创建一个特别的文件名为*.gitignore*。
在里面，能使用正则表达式来列出对应的文件。任何匹配的文件将被Git所忽略。
我建议你至少在其中加入`*.pyc`和`/instance`。instance文件夹中存放着跟你的应用相关的不便公开的配置。

{ .gitignore:
*.pyc
instance/
}

{ SEE ALSO:
* You can read more about *.gitignore* here: http://git-scm.com/docs/gitignore
* The Flask docs have a good section on instance folders: http://flask.pocoo.org/docs/config/#instance-folders
}

{ SEE ALSO:
* 在这里你可以了解什么是*.gitignore* : http://git-scm.com/docs/gitignore
* Flask文档中对instance目录的一段介绍 : http://flask.pocoo.org/docs/config/#instance-folders
}

## 调试

### 调试模式

Flask comes with a handy feature called "debug mode." To turn it on, you just have to set `debug = True` in your development configuration. When it's on, the server will reload on code changes and errors will come with a stack trace and an interactive console.

Flask有一个便利的特性叫做“debug mode”。在你的应用配置中设置`debug = True`就能启动它。
当它被启动后，服务器会在代码变动之后重新加载，并且一旦发生错误，错误会打印成一个带交互式命令行的调用栈。

{ WARNING: Take care not to enable debug mode in production. The interactive console enables arbitrary code execution and would be a massive security vulnerability if it was left on in the live site. }

{ WARNING: 不要在生产环境中开启debug mode。交互式命令行运行任意的代码输入，如果是在运行中的网站上，这将导致安全上的灾难性后果。 }

{ SEE MORE:
- Take a look at the quick start section on debug mode: http://flask.pocoo.org/docs/quickstart/#debug-mode
- There is some good information on handling errors, logging and working with other debuggers here: flask.pocoo.org/docs/errorhandling }

{ SEE MORE:
- 阅读一下quickstart页面的debug mode部分 : http://flask.pocoo.org/docs/quickstart/#debug-mode
- 这里有一些关于错误处理，日志记录和使用其他调试工具的信息 : http://flask.pocoo.org/docs/errorhandling }

### Flask-DebugToolbar

Flask-DebugToolbar is another great tool for debugging problems with your application. In debug mode, it overlays a side-bar onto every page in your application. The side bar gives you debug information about SQL queries, logging, versions, templates, configuration and other fun stuff.

[Flask-DebugToolbar](http://flask-debugtoolbar.readthedocs.org/en/latest/) 是用来调试你的应用的另一个得力工具。在debug mode中，它在你的应用中添加了一个侧边条。
这个侧边条会给你提供有关SQL查询，日志，版本，模板，配置和其他有趣的信息。


## 总结

* Use virtualenv to keep your application’s dependencies together.
* Use virtualenvwrapper to keep your virtual environments together.
* Keep track of dependencies with one or more text files.
* Use a version control system. I recommend Git.
* Use .gitignore to keep clutter and secrets out of version control.
* Debug mode can give you information about problems in development.
* The Flask-DebugToolbar extension will give you even more of that information.

* 使用virtualenv来打包你的应用的依赖包。
* 使用virtualenvwrapper来打包你的virtual environment。
* 使用一个或多个文本文件来记录依赖变化。
* 使用一个版本控制系统。我推荐Git。
* 使用.gitignore来排除不必要的或不能公开的东西混进版本控制。
* debug mode会在开发时给你有关bug的信息。
* Flaks-DebugToolbar拓展将给你有关bug更多的信息。

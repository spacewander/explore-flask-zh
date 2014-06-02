![Organizing your project](images/4.png)

# 组织你的项目

Flask doesn't require that your project directory have a certain structure. Unlike Django, which comes with a startapp tool to create your application skeletons, Flask leaves the organization of your application up to you. This is one of the reasons I liked Flask as a beginner, but it does mean that you have to put some thought into how to structure your code. You could put your entire application in one file, or have it spread across multiple packages. Neither of these is ideal for most projects though. There are a few organizational patterns that you can use to make development and deployment easier.

Flask不会要求你的项目文件夹有一个固定的结构。不像Django，它通过一个startapp工具来创建项目的大致结构，Flask把项目组织的职责托付给你。
这是我喜欢使用Flask开始项目的其中一个理由，但是这意味着你不得不思考怎么组织你的代码。
你可以把这个应用放到一个文件中，或者把它分割多个包。然而这两种结构并不适合大多数项目。
这里有一些固定的组织模式，你可以遵循它们以便于开发和部署。

## Definitions

## 约定

There are a few terms that I want to define for this section.

在这一段中我想要先约定一些概念。

Repository: This is the base folder where your applications sits. This term traditionally refers to version control systems, but that’s out of the scope here. When I refer to your repository in this chapter, I’m talking about the root directory of your project. You probably won't need to leave this directory when working on your application.

**版本库（Repository）**：你的应用的根目录。这个概念来自于版本控制系统，但在这里有所拓展。
当我在这一章提到“版本库”时，指的是你的项目的根目录。在开发你的应用时，你不太可能会离开这个目录。

Package: This refers to a Python package that contains your application's code. I'll talk more about setting up your app as a package in this chapter, but for now just know that the package is a sub-directory of the repository.

**包（Package）**：包含了你的应用代码的一个包。在这一章，我将深入探讨以包的形式建立你的应用，但是现在只需知道包时版本库的一个子目录。

Module: A module is a single Python file that can be imported by other Python files. A package is essentially multiple modules packaged together.

**模块（Module）**：一个模块时一个简单的，可以被其它Python文件引入的Python文件。一个包由多个模块组成。

{ SEE ALSO:
* Read more about Python modules here: http://docs.python.org/2/tutorial/modules.html
* That link has a section on packages as well: http://docs.python.org/2/tutorial/modules.html#packages
}

{ SEE ALSO:
* 在这里可以读到更多的关于Python模块的内容: http://docs.python.org/2/tutorial/modules.html
* 这个链接中也有一节关于包的内容: http://docs.python.org/2/tutorial/modules.html#packages
}

## 组织模式

### 单一模块

A lot of Flask examples that you come across will keep all of the code in a single file, often _app.py_. This is great for quick projects, where you just need to serve a few routes and you’ve got less than a few hundred lines of application code.

在许多Flask例子里，你会看到它们把所有的代码放到一个单一文件中，通常是*app.py*。对于微项目来说这恰到好处，毕竟你只需要处理几个路由（route）并且只有百来行代码。

The repository for a single module application might look something like this:

单一模块的应用的版本库看起来像这样：

```
app.py
config.py
requirements.txt
static/
templates/
```

Application logic would sit in _app.py_ in this example. 

在这个例子中，应用逻辑部分会存放在*app.py*

### 包

When you’re working on a project that’s a little more complex, a single module can get messy. You’ll need to define classes for models and forms, and they’ll get mixed in with the code for your routes and configuration. All of this can frustrate development. To solve this problem, we can factor out the different components of our app into a group of inter-connected modules — a package.

当你开始在一个变得更加复杂的项目上工作时，单一模块就会造成严重的问题。
你需要为模型（model）和表单（form）定义多个类，而它们会跟你的路由和配置代码又吵又闹。所有的一切让你焦头烂额。
为了解决这个问题，我们得把应用中不同的组件分开到单独的、高内聚的一组模块 - 也即是包 - 之中。

The repository for a package-based application will probably look something like this: 

基于包的应用的版本库看起来就像是这样：

```
config.py
requirements.txt
run.py
instance/
  /config.py
yourapp/
  /__init__.py
  /views.py
  /models.py
  /forms.py
  /static/
  /templates/
```

This structure allows you to group the different components of your application in a logical way. The class definitions for models are together in _models.py_, the route definitions are in _views.py_, and forms are defined in _forms.py_ (we’ll talk about forms later).

这个结构允许你理智地整理你的应用的不同组件。
有关模型的类定义全待在*models.py*，而路由定义在*views.py*，有关表单的类定义全待在*forms.py*（等会我们再来谈谈表单）。

This table provides a basic rundown of the components you'll find in most Flask applications:

下面的表格列举了大多数Flask应用都有的基本组件：

{ THE FOLLOWING DATA SHOULD BE IN A TABLE }

/run.py : This is the file that is invoked to start up a development server. It gets a copy of the app from your package and runs it. This won't be used in production, but it will see a lot of mileage in development.

/requirements.txt : This file lists all of the Python packages that your app depends on. You may have separate files for production and development dependencies.

/config.py : This file contains most of the configuration variables that your app needs.

/instance/config.py : This file contains configuration variables that shouldn’t be in version control. This includes things like API keys and database URIs containing passwords. This also contains variables that are specific to this particular instance of your application. For example, you might have DEBUG = False in config.py, but set DEBUG = True in instance/config.py on your local machine for development. Since this file will be read in after config.py, it will override it and set DEBUG = False.

/yourapp/ : This is the package that contains your application.

/yourapp/__init__.py : This file initializes your application and brings together all of the various components.

/yourapp/views.py : This is where the routes are defined. It may be split into a package of its own (_yourapp/views/_) with related views grouped together into modules.

/yourapp/models.py : This is where you define the models of your application. This may be split into several modules in the same way as views.py.

/yourapp/static/ : This file contains the public CSS, JavaScript, images and other files that you want to make public via your app. It is accessible from yourapp.com/static/ by default.

/yourapp/templates/ : This is where you'll put the Jinja2 templates for your app.

/run.py : 这个文件中用于启动一个开发服务器。它从你的包获得应用的副本并运行它。这不会在生产环境中用到，不过依然在许多Flask开发的过程中看到。

/requirements.txt : 这个文件列出了你的应用依赖的所有Python包。你可能需要把它分成生产依赖和开发依赖。[请看第三章]

/config.py : 这个文件包含了你的应用需要的大多数配置变量

/instance/config.py : 这个文件包含不应该出现在版本控制的配置变量。其中有类似调用密钥和数据库URI连接密码。
同样也包括了你的应用中特有的不能放到阳光下的东西。比如，你可能在*config.py*中设定`DEBUG = False`，但在你自己的开发机上的*instance/config.py*设置`DEBUG = True`。
因为这个文件可以在*config.py*之后被载入，它将覆盖掉`DEBUG = False`，并设置`DEBUG = True`。

/yourapp/ : 这个包里包括了你的应用。

/yourapp/__init__.py : 这个文件初始化了你的应用并所有其它的组件组合在一起。

/yourapp/views.py : 这里定义了路由。它也许需要作为一个包（*yourapp/views/*），由一些包含了紧密相联的路由的模块组成。

/yourapp/models.py : 在这里定义了应用的模型。你可能需要像对待*views.py*一样把它分割成许多模块。

/yourapp/static/ : 这个文件包括了公共CSS， Javascript, images和其他你想通过你的应用展示出去的静态文件。默认情况下人们可以从*yourapp.com/static/*获取这些文件。

/yourapp/templates/ : 这里放置着你的应用的Jinja2模板。

There will probably be several other files included in your app in the end, but these are common to most Flask applications.

对于你的应用，可能还需要别的一些文件，但这些适用于大多数Flask应用。

### Blueprints

At some point you may find that you have a lot of related routes. If you’re like me, your first thought will be to split _views.py_ into a package and group related views into modules. When you’re at this point, it may be time to factor your application into blueprints.

有朝一日你可能会发觉应用里有许多相关的路由了。如果是我，我会首先把*views.py*分割成一个包并把相关的路由组织成模块。
要是你已经这么做了，是时候把你的应用分解成[蓝图](http://docs.jinkan.org/docs/flask/blueprints.html)（blueprint）了

Blueprints are essentially components of your app defined in a somewhat self-contained manner. They act as apps within your application. You might have different blueprints for the admin panel, the front-end and the user dashboard. This lets you group views, static files and templates by components, while letting you share models, forms and other aspects of your application between several components.

蓝图是按照一定程度上的自组织的方式，作为你的应用的一部分的组件。
它们表现得就像你的应用下的子应用一样。你可能使用不同的蓝图来对应管理面板（admin panel），前端（front-end）和用户面板（user dashboard）。
这使得你按照组件组织视图，静态文件和模板，并在组件间共享模型，表单和你的应用的其他部分。

{ SEE ALSO:
* You can read more about blueprints in chapter 7.
}

{ SEE ALSO:
* 你可以在第7章阅读到关于蓝图的更多内容。
}

## 总结

* Using a single module for your application is good for quick projects.
* Using a package for your application is good for projects with views, models, forms, etc.
* Blueprints are a great way to organize projects with several distinct components.

* 对于微应用，建议使用单一模块结构。
* 对于包含了视图，模型，表单以及更多的项目，使用包结构。
* 蓝图是把项目按照一些不同的组件组织起来的好办法。

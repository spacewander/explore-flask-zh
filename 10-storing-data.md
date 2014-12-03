# 存储数据

Most Flask applications are going to deal with storing data at some point. There are many different ways to store data. Finding the best one depends entirely on the data you are going to store. If you are storing relational data (e.g. a user has many posts and a post has one user) a relational database is probably going to be the way to go (big suprise). Other types of data might be more suited to NoSQL data stores, such as MongoDB.

大多数Flask应用都将要跟数据打交道。有很多种不同的方法存储数据。至于哪种最优，取决于数据的类型。如果你储存的是关系性数据（比如一个用户有多个邮件，一个邮件对应一个用户），关系型数据库无疑是你的选择。其他类型的数据也许适合储存到NoSQL数据库（比如MongoDB）中。

I am not going to tell you how to choose a database engine for your application. There are people who will tell you that NoSQL is the only way to go and those who will say the same about relational databases. All I will say on that subject is that if you are unsure, a relational database (MySQL, PostgreSQL, etc.) will almost certainly work for whatever you are doing.

我不会告诉你如何为你的应用选择数据库。如果有人告诉你，NoSQL是你的唯一选择；那么必然也会有人建议用关系型数据库处理同样的问题。对此我唯一需要说的是，如果你不清楚，关系型数据库（MySQL, PostgreSQL等等）将满足你绝大部分的需求。

Plus, when you use a relational database you get to use SQLAlchemy and SQLAlchemy is fun.

另外，当你使用关系型数据库，你就能用到SQLAlchemy，而SQLAlchemy用起来真爽。

## SQLAlchemy

SQLAlchemy is an ORM (Object Relational Mapper). It is basically an abstraction that sits on top of the raw SQL queries being executed on your database. It provides a consistent API to a long list of database engines. The most popular include MySQL, PostgreSQL, and SQLite. This makes it easy to move data between your models and your databse and it makes it really easy to do other things like switch database engines and migrate your schemas.

SQLAlchemy是一个ORM（[对象关系映射](http://zh.wikipedia.org/wiki/%E5%AF%B9%E8%B1%A1%E5%85%B3%E7%B3%BB%E6%98%A0%E5%B0%84)）。基于对目标数据库的原生SQL的抽象，它提供了与一长串数据库引擎的一致的API。这一列表中包括MySQL，PostgreSQL，和SQLite。这使得在你的模型和数据库间交换数据变得轻松愉快，同时也使得诸如换掉数据库引擎和迁移数据库模式等其他事情变得没那么繁琐。

There is a great Flask extension that makes using SQLAlchemy in Flask even easier. It is called Flask-SQLAlchemy. Flask-SQLAlchemy configures a lot of sane defaults for SQLAlchemy. It also handles some sesssion management so that you don't have to deal with janitorial stuff in your application code.

存在一个很棒的Flask插件使得在Flask中使用SQLAlchemy更为轻松。它就是Flask-SQLAlchemy。Flask-SQLAlchemy为SQLAlchemy设置了许多合理的配置。它也内置了一些session管理，这样你就不用在应用代码里处理这种基础事务了。

Let's dive into some code. We are going to define some models then configure some SQLAlchemy. The models are going to go in _myapp/models.py_, but first we are going to define our database in _myapp/__init__.py_

让我们深入看看一些代码。我们将先定义一些模型，接着配置下SQLAchemy。这些模型将位于*myapp/models.py*，不过首先我们要在*myapp/__init__.py*定义我们的数据库。

_myapp/__init__.py_
```
from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy

app = Flask(__name__, instance_relative_config=True)

app.config.from_object('config')
app.config.from_pyfile('config.py')

db = SQLAlchemy(app)
```

Initialize and configure your Flask app then use it to initialize your SQLAlchemy database handler. We are going to use an instance folder for our database configuration so we should use the `instance_relative_config` option when initializing the app and then call `app.config.from_pyfile`. Then you can define your models.

初始化并配置你的Flask应用，然后用它来初始化你的SQLAlchemy数据库处理程序。我们将为数据库配置使用一个instance文件夹，所以我们应该在初始化应用时加上`instance_relative_config`选项，然后调用`app.config.from_pyfile`。现在你可以定义模型了。

_myapp/models.py_
```
from . import db

class Engine(db.Model):

    # Columns

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)

    title = db.Column(db.String(128))

    thrust = db.Column(db.Integer, default=0)
```

`Column`, `Integer`, `String`, `Model` and other SQLAlchemy classes are all available via the `db` object constructed from Flask-SQLAlchemy. Here we have defined a model to store the current state of our spacecraft's engines. Each engine has an id, a title and a thrust level.

`Column`，`Integer`，`String`，`Model`和其他的SQLAlchemy类都可以通过由Flask-SQLAlchemy构造的`db`对象访问。下面我们会定义一个储存我们的太空飞船引擎的当前状态的模型。每个引擎有一个ID，一个标题和一个推力等级。

We still need to add some database information to our configuration. We are using an instance folder to keep confidential configuration variables out of version control, so we are going to put it in _instance/config.py_.

我们需要往我们的配置添加一些数据库信息。我们打算使用一个instance文件夹来避免配置变量被记录进版本控制系统，所以我们要把它们放入*instance/config.py*。

_instance/config.py_
```
SQLALCHEMY_DATABASE_URI = "postgresql://user:password@localhost/spaceshipDB"
```

{ SEE MORE: Your database URI will be different depending on the engine you use and where it is hosted. See the SQLAlchemy documentation for this here: http://docs.sqlalchemy.org/en/latest/core/engines.html?highlight=database#database-urls }

{ SEE MORE: 你的数据库URI将取决于你选择的数据库和它部署的位置。看一下这个相关的SQLAlchemy文档： http://docs.sqlalchemy.org/en/latest/core/engines.html?highlight=database#database-urls }

## 初始化数据库

Now that the database is configured and we have defined a model, we can initialize the database. This step basically involves creating that database scheme from the model definitions.

既然数据库已经配置好了，而模型也定义了，是时候初始化数据库了。这个步骤从由模型定义中创建数据库模式开始。

Normally that might be a real pain in the neck to do. Lucky for us, SQLAlchemy has a really cool command that will do all of this for us.

通常这会是非常痛苦的过程。不过幸运的是，SQLAlchemy提供了一个十分酷的工具帮我们完成了所有的琐事。

Let's open up a Python terminal in our repository root.

让我们在版本库的根目录下打开一个Python终端。

```
$ pwd
/Users/me/Code/myapp
$ workon myapp
(myapp)$ python
Python 2.7.5 (default, Aug 25 2013, 00:04:04)
[GCC 4.2.1 Compatible Apple LLVM 5.0 (clang-500.0.68)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> from myapp import db
>>> db.create_all()
>>>
```

Now, thanks to SQLAlchemy, you will find that the tables have been created in the database specified in your configuration.

现在，感谢SQLAlchemy，你会发现在你配置的数据库中，所需的表格已经被创建出来了。

## Alembic迁移工具

The schema of a database is not set in stone. For example, you may want to add a `last_fired` column to the engine table. If you don't have any data, you can just update the model and run `db.create_all()` again. However, if you have six months of engine data logged in that table, you probably do not want to start over from scratch. That's where database migrations come in.

数据库的模式并非亘古不变的。举个例子，你可能需要在引擎的表里添加一个`last_fired`的项。如果这个表是一张白纸，你只需要更新模型并重新运行`db.create_all()`。然而，如果你在引擎表里记录了六个月的数据，你肯定不会想要从头开始。这时候就需要数据库迁移工具了。

Alembic is a database migration tool created specifically for use with SQLAlchemy. It lets you keep a versioned history of your database schema so that you can upgrade to a new schema and even downgrade back to an older one.

Alembic是专用于SQLAlchemy的数据库迁移工具。它允许你保持你的数据库模式的版本历史，这样你就可以升级到一个新的模式，或者降级到旧的模式。

Alembic has an extensive tutorial to get you started, so I'll just give you a quick overview and point out a couple of things to watch out for.

Alembic有一个可拓展的新手教程，所以我只会大概地说一下并指出一些需要注意的事项。

You will create your alembic "migration environment" via an installed `alembic init` command. Run this in your repository root and you will end up with a new directory with the very clever name `alembic`. Your repository will end up looking something like this example adapted from the Alembic tutorial:

通过一个初始化的`alembic init`命令，你将创建一个alembic"迁移环境"。在你的版本库的根目录下执行这个命令，你将得到一个叫`alembic`的新文件夹。你的版本库将看上去就像Alembic教程中的这个例子一样：

```
myapp/
	alembic.ini
    alembic/
        env.py
        README
        script.py.mako
        versions/
            3512b954651e_add_account.py
            2b1ae634e5cd_add_order_id.py
            3adcc9a56557_rename_username_field.py
    myapp/
    	__init__.py
        views.py
        models.py
      	templates/
    run.py
    config.py
    requirements.txt

```

The _alembic/_ directory has the scripts that migrate your data from version to version. There is also an _alembic.ini_ file that contains configuration information.

*alembic/*文件夹中包括了在版本间迁移数据的脚本。同时会有一个包括配置信息的*alembic.ini*文件。

{ WARNING: Add _alembic.ini_ to _.gitignore_! You are going to have your database credentials in the file so you **do not** want it to end up in version control.

You do want to keep _alembic/_ in versin control though. It does not contain sensitive information (that can't already be derived from your source code) and keeping it in version control will mean having several copies should something happen to the files on your computer. }

{ WARNING: 把*alembic/*添加到*.gitignore*中！在那里会有你的数据库凭证，所以你*不应该*把它留在版本控制中。

不过你可以把*alembic/*放进版本控制。它不会包含敏感信息（而且不能从你的源代码中重新生成），并且在版本控制中保存多个副本可以避免你的电脑发生不测。}

When it comes time to make a schema change, there are a couple of steps. First your run `alembic revision` to generate a migration script. Open up the newly generated Python file in _myapp/alembic/versions/_ and fill in the `upgrade` and `downgrade` functions using Alembic's `op` object. // FIXME

当数据库模式需要发生变化时，你要做一系列事情。首先，你运行`alembic revision`来生成迁移脚本。在`myapp/alembic/versions/`打开新生成的Python文件并使用Alembic的`op`对象完成`upgrade`和`downgrade`函数。

Once we have our migration script ready, we can run `alembic upgrade head` to migrade our data to the latest version.

一旦我们的迁移脚本已经准备就绪，我们只需运行`alembic upgrade head`来迁移我们的数据到最新版本。

{ SEE MORE: For the details on configuring Alembic, creating your migration scripts and running your migrations see the Alembic tutorial: http://alembic.readthedocs.org/en/latest/tutorial.html }

{ WARNING: Don't forget to put a plan in place to back up your data. The details of that plan are outside the scope of this book, but you should always have your datbase backed up in a secure and robust way. }

{ NOTE: The NoSQL scene is less established with Flask, but as long as the database engine of your choice has a Python library, you should be able to use it. There are even several extensions in the Flask extension registry to help integrate NoSQL engines with Flask: http://flask.pocoo.org/extensions/ }

{ SEE MORE: 想知道更多关于配置Alembic，创建你的迁移脚本和运行你的迁移，请看Alembic教程： http://alembic.readthedocs.org/en/latest/tutorial.html }

{ WARNING: 不要忘记设定数据的备份计划。备份计划的话题已经超出本书的范围，但你应该总是要有一个安全和健壮的方式备份你的数据库。}

{ NOTE:  Flask在NoSQL上的支持较少，但只要有你选择的数据库引擎有对应的Python库，你就能够用上它。这里有一些Flask插件，可以给Flask提供NoSQL引擎的支持。 http://flask.pocoo.org/extensions/ }

## 总结

- Use SQLAlchemy to work with relational databases.
- Use Flask-SQLAlchemy to work with SQLAlchemy.
- Alembic helps you manage migrate your data between schema changes.
- You can use NoSQL databases with Flask, but the methods and tools vary between engines.
- Back up your data!

- 使用SQLAchemy来搭配关系型数据库。
- 使用Flask-SQLAlchemy来包装SQLAlchemy。
- Alembic会在数据库模式改变时帮助你管理数据迁移。
- 你可以用NoSQL搭配Flask，但具体做法取决于具体引擎。
- 记得备份你的数据！

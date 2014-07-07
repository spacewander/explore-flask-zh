![Configuration](images/5.png)

# 配置

When you're learning Flask, configuration seems simple. You just define some variables in config.py and everything works. That simplicity starts to fade away when you have to manage configuration for a production application. You may need to protect secret API keys or use different configurations for different environments (e.g. development and production). There are some advanced Flask features available to help us make this easier.

当你开始学习Flask时，配置看上去是小菜一碟。你仅仅需要在*config.py*定义几个变量，然后万事大吉。
然而当你不得不管理一个生产上的应用的配置时，这一切将变得棘手万分。
你不得不设法保护API密钥，或者纠结于为了不同的环境（比如开发环境和生产环境）使用不同的配置。
还好Flask提供了一些高级特性，帮助我们减轻负担。

## 从小处起步

A simple application may not need any of these complicated features. You may just need to put _config.py_ in the root of your repository and load it in _app.py_ or _yourapp/__init__.py_

一个简单的应用不需要任何复杂的配置。你仅仅需要在你的根目录下放置一个*config.py*文件，并在*app.py*或*yourapp/__init__.py*中加载它。

 _config.py_  should contain one variable assignment per line. Once _config.py_ is loaded later, the configuration variables will be accessible via the `app.config` dictionary, e.g. `app.config[“DEBUG”]`. Here’s an example of a typical _config.py_ file for a small project:

*config.py*的每一行中应该是某一个变量的赋值语句。一旦*config.py*在稍后被加载，这个配置变量可以通过`app.config`字典来获取，比如`app.config["DEBUG"]`。
以下是一个小项目的*config.py*文件的范例：

```
DEBUG = True # Turns on debugging features in Flask
BCRYPT_LEVEL = 13 # Configuration for the Flask-Bcrypt extension
MAIL_FROM_EMAIL = "robert@example.com" # For use in application emails
```

There are some built-in configuration variables like `DEBUG`. There are also some configuration variables for extensions that you may be using like `BCRYPT_LEVEL` for the Flask-Bcrypt extension, used for password hashing. You can even define your own configuration variables for use throughout the application. In this example, I would use `app.config[“MAIL_FROM_EMAIL”]` whenever I needed the default “from” address for a transactional email (e.g. password resets). It makes it easy to change that later on.

有一些配置变量是内建的，比如`DEBUG`。还有些配置变量是关于Flask拓展的，比如`BCPYRT_LEVEL`就是用于Flask-Bcrypt拓展（一个用于hash映射密码的拓展）。
你甚至可以定义在这个应用中用到的自己的配置变量。
在这个例子中，我使用`app.config["MAIL_FROM_EMAIL"]`来表示邮件往来时（比如重置密码）默认的发送方。
这使得在将来要修改的时候不会带来太多麻烦。

To load these configuration variables into the application, I would use `app.config.from_object()` in _app.py_ for a single-module application or _yourapp/__init__.py_ for a package based application. In either case, the code looks something like this:

为了加载这些配置变量，我通常使用`app.config.from_object()`。如果是单一模块应用中，是在*app.py*；或者在*yourapp/__init__.py*，如果是基于包的应用。
无论在哪种情况下，代码看上去像这样：

```
from flask import Flask

app = Flask(__name__)
app.config.from_object('config')
# Now I can access the configuration variables via app.config["VAR_NAME"].
```

### 一些重要的配置变量

{ THIS INFORMATION SHOULD BE IN A TABLE }

* VARIABLE : DESCRIPTION : DEFAULT VALUE
* DEBUG : Gives you some handy tools for debugging errors. This includes a web-based stack trace and Python console when an request results in an application error. : Should be set to True in development and False in production.
* SECRET_KEY : This is a secret key that is used by Flask to sign cookies and other things. You should define this in your instance folder to keep it out of version control. You can read more about instance folders in the next section. : This should be a complex random value.
* BCRYPT_LEVEL : If you’re using Flask-Bcrypt to hash user passwords (if you’re not, start now), you’ll need to specify the number of “rounds” that the algorithm executes in hashing a password. The more rounds used in hashing, the longer it will be for a computer hash (and importantly, to crack) the password. The number of rounds used should increase over time as computing power increases. : As a rule of thumb, take the last two digits of the current year and use that value. For example, I’m writing this in 2013, so I’m currently using a `BCRYPT_LEVEL = 13`. You’ll often hear that you should choose the highest possible level before you application becomes too slow to bear. That’s true, but it’s tough to translate into a number to use. Feel free to play around with higher numbers, but you should be alright with that rule of thumb.

* 变量名 : 描述 : 默认值
* DEBUG : 在调试错误的时候给你一些有用的工具。比如当一个请求导致异常的发生时，会出现的一个web界面的调用堆栈和Python命令行。 : 在开发环境下应该设置成True，在生产环境下应设置为False。
* SECRET_KEY : Flask使用这个密钥来对cookies和别的东西进行签名。你应该在*instance*文件夹中设定这个值，并不要把它放入版本控制中。你可以在下一节读到关于*instance*文件夹的更多信息。 : 这应该是一个复杂的任意值。
* BCRYPT_LEVEL : 如果使用Flask-Bcrypt来hash映射用户密码（如果没有，现在就用它），你需要为hash密码的算法指定“rounds”的值。设置的rounds值越高，计算一次hash花费的时间就越长（同样的效果作用于破解方，这个才是重要的）。rounds的值应该随着你的设备的计算能力的提升而增加 : 作为一个经验法则，应该把round的值设定为当前年份的后两位，所以我现在使用`BCRYPT_LEVEL = 13`。你也许听别人说过要选择一个恰好不会让你的应用不堪忍受地慢的值。这没问题，但很难找准这个数。你自然可以选择更大的参数，但是上面的经验之谈应该可以满足了。

{ WARNING: Make sure DEBUG = False in production. Leaving it on will allow users to run arbitrary Python code on your server. }

{ WARNING: 确保生产环境下已经设置了 `DEBUG = False`。如果忘记关掉，用户会很乐意对你的服务器执行任意的Python代码。}

## instance文件夹

Sometimes you’ll need to define configuration variables that shouldn’t be shared. For this reason, you’ll want to separate them from the variables in _config.py_ and keep them out of the repository. You may be hiding secrets like database passwords and API keys, or defining variables specific to your current machine. To make this easy, Flask gives us a feature called Instance folders. The instance folder is a subdirectory sits in the repository root and contains a configuration file specifically for this instance of the application. It is not committed to version control.

有时你需要定义一些不能为人所知的配置变量。为此，你会想要把它们从*config.py*中的其他变量分离出来，并保持在版本控制之外。
你可能要隐藏类似数据库密码和API密钥的秘密，或定义特定于当前机器的参数。
为了让这更加轻松，Flask提供了一个叫*instance文件夹*的特性。
instance文件夹是根目录的一个子文件夹，包括了一个特定于当前应用实例的配置文件。它不应该被提交到版本控制中。

Here’s a simple repository for a Flask application using an instance folder:

这是一个使用了instance文件夹的简单Flask应用的结构:

```
config.py
requirements.txt
run.py
instance/
  config.py
yourapp/
  __init__.py
  models.py
  views.py
  templates/
  static/
```

### 使用instance文件夹

To load the configuration variables defined inside of an instance folder, you can use `app.config.from_pyfile()`. If we set `instance_relative_config=True` when we create our app with the `Flask()` call, `app.config.from_pyfile()` will check for the specified file in the _instance/_ directory.

要想加载定义在instance文件夹中的配置变量，你可以使用`app.config.from_pyfile()`。
如果在调用`Flask()`创建应用时设置了`instance_relative_config=Trye`，`app.config.from_pyfile()`将查看在*instance*文件夹的特殊文件。

```
app = Flask(__name__, instance_relative_config=True)
app.config.from_object('config')
app.config.from_pyfile('config.py')
```

Now, you can define variables in _instance/config.py_ just like you did in _config.py_. You should also add the instance folder to your version control system’s ignore list. To do this with git, you would save `instance/` on a new line in  _gitignore_.

现在，你可以在*instance/config.py*中定义变量，一如在*config.py*。
你也应该将instance文件夹加入到版本控制系统的忽略名单中。比如假设你用的是git，你需要在*gitignore*中新开一行，写下`instance/`。

### 密钥

The private nature of the instance folder makes it a great candidate for defining keys that you don't want exposed in version control. These may include your app's secret key or third-party API keys. This is especially important if your application is open source, or might be at some point in the future.

instance文件夹的隐秘属性使得它成为藏匿密钥的好地方。
你可以在放入应用的密钥或第三方的API密钥。假如你的应用是开源的，或者将会是开源的，这会很重要。

Your _instance/config.py_ file might look something like this:

你的*instance/config.py*文件大概看上去像这样:

{ THIS COULD BE A GOOD CHANCE TO ENCODE BACKER NAMES! }

{ 啊哈，我可以在这里给赞助者做植入式广告! }

```
SECRET_KEY = 'ABCDEFG' # This is a bad secret key!
STRIPE_API_KEY = 'yekepirtsaton'
SQLALCHEMY_DATABASE_URI = "postgresql://username:password@localhost/databasename"
```

### 最小化依赖于环境的配置

If the difference between your production and development environments are pretty minor, you may want to use your instance folder to handle the configuration changes. Variables defined in the instance/config.py file can override the value in config.py. You just need to make the call to `app.config.from_pyfile()` after `app.config.from_object()`.  One way to take advantage of this is to change the way your app is configured on different machines. Your development repository might look like this:

如果你的生产环境和开发环境之间的差别非常小，你可以使用你的instance文件夹抹平配置上的差别。
在*instance/config.py*中定义的变量可以覆盖在*config.py*中设定的值。
你只需要在`app.config.from_object()`之后才调用`app.config.from_pyfile()`。
这样做的其中一个优点是你可以在不同的机器中修改你的应用的配置。你的开发版本库可能看上去像这样:

config.py
```
DEBUG = False
SQLALCHEMY_ECHO = False
```

instance/config.py
```
DEBUG = True
SQLALCHEMY_ECHO = True
```

Then in production, you would leave these lines out of _instance/config.py_ and it would fall back to the values defined in _config.py_. 

然后在生产环境中，你将这些代码从*instance/config.py*中移除，它就会改用回*config.py*中设定的变量。

{ SEE MORE:
* Read about Flask-SQLAlchemy’s configuration keys here: http://pythonhosted.org/Flask-SQLAlchemy/config.html#configuration-keys
}

{ SEE MORE:
* 在这里可以读到关于Flask-SQLAlchemy的配置密钥: http://pythonhosted.org/Flask-SQLAlchemy/config.html#configuration-keys
}

## 依照环境变量来配置

The instance folder shouldn’t be in version control. This means that you won’t be able to track changes to your instance configurations. That might not be a problem with one or two variables, but if you have a finely tuned configurations for various environments (production, staging, development, etc.) you don’t want to risk losing that. 

instance文件夹不应该在版本控制中。这意味这你将不能追踪你的instance配置。
在只有一两个变量的情况下这不是什么问题，但如果你有关于多个环境（生产，稳定，开发，等等）的一大堆配置，你不会愿意冒失去它们的风险。

Flask gives us the ability to choose a configuration file on the fly based on the value of an environment variable. This means that we can have several configuration files in our repository (and in version control) and always load the right one, depending on the environment.

Flask给我们提供了根据一个环境变量快速选择一个配置文件的能力。
这意味着我们可以在我们的版本库（和版本控制）中有多个配置文件，并总是能根据具体环境，加载到对的那个。

When we’re at the point of having several configuration files in the repository, it’s time to move those files into a `config` package. Here’s what that looks like in a repository:

当我们到了有多个配置文件共存的境况，是时候把文件都移动到`config`包之下。
下面是在这样的一个版本库中大致的样子:

```
requirements.txt
run.py
config/
  __init__.py # Empty, just here to tell Python that it's a package.
  default.py
  production.py
  development.py
  staging.py
instance/
  config.py
yourapp/
  __init__.py
  models.py
  views.py
  static/
  templates/
```

In this case we have a few different configuration files:

在我们有一些不同的配置文件的情况下:

{ PUT THIS IN A TABLE }

* _config/default.py_ : Default values, to be used for all environments or overridden by individual environments. An example might be setting `DEBUG = False` in _config/default.py_ and `DEBUG = True` in _config/development.py_.
* _config/development.py_ : Values to be used during development. Here you might specify the URI of a database sitting on localhost.
* _config/production.py_ : Values to be used in production. Here you might specify the URI for your database server, as opposed to the localhost database URI used for development.
* _config/staging.py_ : Depending on your deployment process, you may have a staging step where you test changes to your application on a server that simulates a production environment. You’ll probably use a different database, and you may want to alter other configuration values for staging applications.

* _config/default.py_ : 默认值，适用于所有的环境或交由具体环境进行覆盖。举个例子，在*config/default.py*中设置`DEBUG = False`，在*config/development.py*中设置`DEBUG = True`。
* _config/development.py_ : 在开发环境中用到的值。这里你可以设定在localhost中用到的数据库URI链接。
* _config/production.py_ : 在生产环境中用到的值。这里你可以设定数据库服务器的URI链接，而不是开发环境下的本地数据库URI链接。
* _config/staging.py_ : 在你的开发过程中，你可能需要在一个模拟生产环境的服务器上测试你的应用。你也许会使用不一样的数据库，想要为稳定版本的应用替换掉一些配置。

To actually use these files in your various environments, you can make a call to `app.config.from_envvar()`:

要在不同的环境中指定所需的变量，你可以调用`app.config.from_envvar()`:

yourapp/__init__.py
```
app = Flask(__name__, instance_relative_config=True)
app.config.from_object('config.default')
app.config.from_pyfile('config.py') # Don't forget our instance folder
app.config.from_envvar('APP_CONFIG_FILE')
```

`app.config.from_envvar(‘APP_CONFIG_FILE’)` will load the file specified in the environment variable `APP_CONFIG_FILE`. The value of that environment variable should be the full path of a configuration file. 

`app.config.from_envvar(‘APP_CONFIG_FILE’)`将加载由环境变量`APP_CONFIG_FILE`指定的文件。这个环境变量的值应该是一个配置文件的绝对路径。

How you set this environment variable depends on the platform on which you’re running your app. If you’re running on a regular Linux server, you could set up a shell script that sets the environment variables and runs `run.py`:

这个环境变量的设定方式取决于你运行你的应用的平台。如果你是在一台标准的Linux服务器上运行，你可以使用一个shell脚本来设置环境变量并运行`run.py`

start.sh
```
APP_CONFIG_FILE=/var/www/yourapp/config/production.py
python run.py
```

If you’re using Heroku, you’ll want to set the environment variables with the Heroku tools. The same idea applies to other “PaaS” platforms.

如果你把应用托管到Heroku，你可以用Heroku提供的工具设置环境变量参数。对于其他PAAS平台也是同样的处理。

## 总结

* A simple app may only need one configuration file: _config.py_.
* Instance folders can help us hide secret configuration values.
* Instance folders can be used to alter an application’s configuration for a specific environment.
* We should use environment variables and `app.config.from_envvar()` for complicated, environment-based configurations.

* 一个简单的应用也许仅需一个配置文件:*config.py*
* instance文件夹可以帮助我们隐藏不愿为人所知的配置变量。
* instance文件夹可以用来将应用的配置替换成当前的变量。
* 应对复杂的，基于环境的配置，我们可以结合环境变量和`app.config.from_envvar()`来使用。

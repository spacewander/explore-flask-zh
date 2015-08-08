![配置](images/configuration.png)

# 配置

当你开始学习Flask时，配置看上去是小菜一碟。你仅仅需要在*config.py*定义几个变量，然后万事大吉。
然而当你不得不管理一个生产上的应用的配置时，这一切将变得棘手万分。
你不得不设法保护API密钥，或者纠结于为了不同的环境（比如开发环境和生产环境）使用不同的配置。
在本章我们将探讨Flask的一些高级特性，它们能让配置管理更为轻松。

## 从小处起步

一个简单的应用不需要任何复杂的配置。你仅仅需要在你的根目录下放置一个*config.py*文件，并在*app.py*或*yourapp/\_\_init\_\_.py*中加载它。

*config.py*的每一行中应该是某一个变量的赋值语句。一旦*config.py*在稍后被加载，这个配置变量可以通过`app.config`字典来获取，比如`app.config["DEBUG"]`。
以下是一个小项目的*config.py*文件的范例：

```python
DEBUG = True # 启动Flask的Debug模式
BCRYPT_LEVEL = 13 # 配置Flask-Bcrypt拓展
MAIL_FROM_EMAIL = "robert@example.com" # 设置邮件来源
```

有一些配置变量是内建的，比如`DEBUG`。还有些配置变量是关于Flask拓展的，比如`BCPYRT_LEVEL`就是用于Flask-Bcrypt拓展（一个用于hash映射密码的拓展）。
你甚至可以定义在这个应用中用到的自己的配置变量。
在这个例子中，我使用`app.config["MAIL_FROM_EMAIL"]`来表示邮件往来时（比如重置密码）默认的发送方。
这使得在将来要修改的时候不会带来太多麻烦。

为了加载这些配置变量，我通常使用`app.config.from_object()`。如果是单一模块应用中，是在*app.py*；或者在*yourapp/\_\_init\_\_.py*，如果是基于包的应用。
无论在哪种情况下，代码看上去像这样：

```
from flask import Flask

app = Flask(__name__)
app.config.from_object('config')
# 现在通过app.config["VAR_NAME"]，我们可以访问到对应的变量
```

### 一些重要的配置变量

| 变量         | 描述          |  默认值|
| -------------|:-------------:|------- |
| DEBUG        | 在调试错误的时候给你一些有用的工具。比如当一个请求导致异常的发生时，会出现的一个web界面的调用堆栈和Python命令行。| 在开发环境下应该设置成True，在生产环境下应设置为False。|
| SECRET_KEY   | Flask使用这个密钥来对cookies和别的东西进行签名。你应该在*instance*文件夹中设定这个值，并不要把它放入版本控制中。你可以在下一节读到关于*instance*文件夹的更多信息。| 这应该是一个复杂的任意值。|
| BCRYPT_LEVEL | 如果使用Flask-Bcrypt来hash映射用户密码（如果没有，现在就用它），你需要为hash密码的算法指定“rounds”的值。设置的rounds值越高，计算一次hash花费的时间就越长（同样的效果作用于破解方，这个才是重要的）。rounds的值应该随着你的设备的计算能力的提升而增加| 如果使用Flask-Bcrypt来hash映射用户密码（如果没有，现在就用它），你需要为hash密码的算法指定“rounds”的值。设置的rounds值越高，计算一次hash花费的时间就越长（同样的效果作用于破解方，这个才是重要的）。rounds的值应该随着你的设备的计算能力的提升而增加|

** 确保生产环境下已经设置了 `DEBUG = False`。如果忘记关掉，用户会很乐意对你的服务器执行任意的Python代码。**

## instance文件夹

有时你需要定义一些不能为人所知的配置变量。为此，你会想要把它们从*config.py*中的其他变量分离出来，并保持在版本控制之外。
你可能要隐藏类似数据库密码和API密钥的秘密，或定义特定于当前机器的参数。
为了让这更加轻松，Flask提供了一个叫*instance文件夹*的特性。
instance文件夹是根目录的一个子文件夹，包括了一个特定于当前应用实例的配置文件。我们不要把它提交到版本控制中。

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

要想加载定义在instance文件夹中的配置变量，你可以使用`app.config.from_pyfile()`。
如果在调用`Flask()`创建应用时设置了`instance_relative_config=True`，`app.config.from_pyfile()`将查看在*instance*文件夹的特殊文件。

```python
app = Flask(__name__, instance_relative_config=True)
app.config.from_object('config')
app.config.from_pyfile('config.py')
```

现在，你可以在*instance/config.py*中定义变量，一如在*config.py*。
你也应该将instance文件夹加入到版本控制系统的忽略名单中。比如假设你用的是git，你需要在*gitignore*中新开一行，写下`instance/`。

### 密钥

instance文件夹的隐秘属性使得它成为藏匿密钥的好地方。
你可以在放入应用的密钥或第三方的API密钥。假如你的应用是开源的，或者将会是开源的，这会很重要。我们希望其他人去使用他们自己申请的密钥。

```python
# instance/config.py

SECRET_KEY = 'Sm9obiBTY2hyb20ga2lja3MgYXNz'
STRIPE_API_KEY = 'SmFjb2IgS2FwbGFuLU1vc3MgaXMgYSBoZXJv'
SQLALCHEMY_DATABASE_URI= \
"postgresql://user:TWljaGHFgiBCYXJ0b3N6a2lld2ljeiEh@localhost/databasename"
```

### 最小化依赖于环境的配置

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

然后在生产环境中，你将这些代码从*instance/config.py*中移除，它就会改用回*config.py*中设定的变量。

> **参见**
> * 在这里可以读到关于Flask-SQLAlchemy的配置密钥: http://pythonhosted.org/Flask-SQLAlchemy/config.html#configuration-keys

## 依照环境变量来配置

instance文件夹不应该在版本控制中。这意味这你将不能追踪你的instance配置。
在只有一两个变量的情况下这不是什么问题，但如果你有关于多个环境（生产，稳定，开发，等等）的一大堆配置，你不会愿意冒失去它们的风险。

Flask给我们提供了根据环境变量选择一个配置文件的能力。
这意味着我们可以在我们的版本库中有多个配置文件，并总是能根据具体环境，加载到对的那个。

当我们到了有多个配置文件共存的境况，是时候把文件都移动到`config`包之下。
下面是在这样的一个版本库中大致的样子:

```
requirements.txt
run.py
config/
  __init__.py # 空的，只是用来告诉Python它是一个包。
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

在我们有一些不同的配置文件的情况下，可以这样设置:

| 文件名               | 内容    |
| ------------------   |-------------   |
| config/default.py    | 默认值，适用于所有的环境或交由具体环境进行覆盖。举个例子，在*config/default.py*中设置`DEBUG = False`，在*config/development.py*中设置`DEBUG = True`。|
| config/development.py| 在开发环境中用到的值。这里你可以设定在localhost中用到的数据库URI链接。|
| config/production.py | 在生产环境中用到的值。这里你可以设定数据库服务器的URI链接，而不是开发环境下的本地数据库URI链接。|
| config/staging.py    | 在你的开发过程中，你可能需要在一个模拟生产环境的服务器上测试你的应用。你也许会使用不一样的数据库，想要为稳定版本的应用替换掉一些配置。|

要在不同的环境中指定所需的变量，你可以调用`app.config.from_envvar()`:

```python
# yourapp/__init__.py

app = Flask(__name__, instance_relative_config=True)
app.config.from_object('config.default')
app.config.from_pyfile('config.py') # 从instance文件夹中加载配置
app.config.from_envvar('APP_CONFIG_FILE')
```

`app.config.from_envvar(‘APP_CONFIG_FILE’)`将加载由环境变量`APP_CONFIG_FILE`指定的文件。这个环境变量的值应该是一个配置文件的绝对路径。

这个环境变量的设定方式取决于你运行你的应用的平台。如果你是在一台标准的Linux服务器上运行，你可以使用一个shell脚本来设置环境变量并运行`run.py`。

start.sh
```
APP_CONFIG_FILE=/var/www/yourapp/config/production.py
python run.py
```

*start.sh*特定于某个环境，所以它也不能放入版本控制当中。如果你把应用托管到Heroku，你可以用Heroku提供的工具设置环境变量参数。对于其他PAAS平台也是同样的处理。

## 总结

* 一个简单的应用也许仅需一个配置文件:*config.py*
* instance文件夹可以帮助我们隐藏不愿为人所知的配置变量。
* instance文件夹可以用来改变特定环境下的程序配置。
* 应对复杂的，基于环境的配置，我们可以结合环境变量和`app.config.from_envvar()`来使用。

![关于视图和路由的进阶技巧](images/views.png)

# 关于视图和路由的进阶技巧

## 视图装饰器

Python装饰器让我们可以用其他函数包装特定函数。
当一个函数被一个装饰器"装饰"时，那个装饰器会被调用，接着会做额外的工作，修改变量，调用原来的那个函数。我们可以把我们想要重用的代码作为装饰器来包装一系列视图。

装饰器的语法看上去像这样:

```python
@decorator_function
def decorated():
    pass
```

如果你看过Flask入门指南，那么对这个语法应该不敢到陌生。`@app.route`正是用于在Flask应用中给视图函数设定路由URL的装饰器。

让我们看一下在你的Flask应用中用得上的一些别的装饰器。

### 认证

Flask-Login使得用户认证系统的实现不再困难。
除了处理用户认证的细节之外，Flask-Login允许我们使用`@login_required`这个装饰器来验证用户对某些资源的访问权限。

下面是从一个用到Flask-Login和`@login_required`装饰器的一个示范应用中获取的例子:

```
from flask import render_template
from flask.ext.login import login_required, current_user


@app.route('/')
def index():
    return render_template("index.html")

@app.route('/dashboard')
@login_required
def account():
    return render_template("account.html")
```

> **注意**
> `@app.route`必须是最外面的视图装饰器。

只有已经验证的用户能够接触到*/dashboard*路由。你可以配置Flask-Login来重定向未验证用户到登录页面，返回HTTP 401状态码或别的你乐意的事。

> **参见**
> 通过[官方文档](http://flask-login.readthedocs.org/en/latest/)可以读到更多关于Flask-Login的内容

### 缓存

意淫一下，假如你的应用突然有一天在微博/朋友圈或网上别的地方火了。
于是秒秒钟会有成千上万的请求涌向你的应用。你的主页在每个请求中都要从数据库跑上一大趟，结果海量的请求导致网站慢得像教务系统一样。
你能做什么来加速这一过程，以免用户以为你的应用挂掉了？

答案不止一个，不过就本章主旨而言，标准答案是实现缓存。
特别的，我们将要用到[Flask-Cache](http://pythonhosted.org/Flask-Cache/)拓展。这个拓展给我们提供一个可以用来缓存某个响应一段时间的装饰器。

你可以将Flask-Cache配置成跟你想用的后台缓存一起使用。一个普遍的选择是[Redis](http://redis.io/)，一个容易配置和使用的软件。
假设Flask-Cache已经配置好了，下面是我们的被装饰的视图的例子:

```
from flask.ext.cache import Cache
from flask import Flask

app = Flask()

# 通过这个方式获取相关配置
cache = Cache(app)

@app.route('/')
@cache.cached(timeout=60)
def index():
    [...] # 进行一些数据库调用来获取所需信息
    return render_template(
        'index.html',
        latest_posts=latest_posts,
        recent_users=recent_users,
        recent_photos=recent_photos
    )

```

现在这个函数将会在每60秒最多运行一次。响应的结果会被保存在缓存中，并可以让期间的每一个请求获取。

> **注意**
> Flask-Cache同时允许我们**记住**函数 - 或缓存通过给定的参数调用的某个函数。你甚至可以缓存过于复杂的Jinja2模板片段!

### 自定义装饰器

在这个例子中，让我们假设我们有一个应用，每个月要求用户定期付费。如果一个用户的账户已经过期，我们要重定向他们到账单页面并把悲伤的现实告知。

myapp/util.py
```
from functools import wraps
from datetime import datetime

from flask import flash, redirect, url_for

from flask.ext.login import current_user

def check_expired(func):
    @wraps(func)
    def decorated_function(*args, **kwargs):
        if datetime.utcnow() > current_user.account_expires:
            flash("Your account has expired. Please update your billing information.")
            return redirect(url_for('account_billing'))
        return func(*args, **kwargs)

    return decorated_function
```

1. 当用`@check_expired`装饰一个函数时，`check_expired()`被调用，被装饰的函数作为一个参数被传递进来。
2. `@wraps`是一个装饰器，告知Python函数`decorated_function()`包装了视图函数`func()`。严格来说这不是必须的，但是这么做会使得装饰函数更加自然一些，更有利于文档和调试。
3. `decorated_function`将截取原本传递给视图函数`func()`的args和kwargs。在这里我们检查用户的账户是否过期。如果是，我们将闪烁一则信息，并重定向到账单页面。
4. 既然已经处理好自己的事情，我们把原来的参数交由视图函数`func()`去继续执行。

位于最顶部的装饰器将最先运行，然后调用下一个函数:一个视图函数或下一个装饰器。装饰器语法只是一个语法糖而已。

```python
# 这样
@foo
@bar
def one():
    pass
```


```python
# 等同于这样:
def two():
    pass
two = foo(bar(two))
r2 = two()

r1 == r2 # True
```

下面这个例子用到了我们自定义的装饰器和来自Flask-Cache拓展的`@login_required`装饰器。我们可以将多个装饰器堆成栈来一起使用。

myapp/views.py
```
from flask import render_template

from flask.ext.login import login_required

from . import app
from .util import check_expired

@app.route('/use_app')
@login_required
@check_expired
def use_app():
    """欢迎光临"""

    return render_template('use_app.html')

@app.route('/account/billing')
@login_required
def account_billing():
    """拿账单来"""
    # [...]
    return render_template('account/billing.html')
```

当一个用户试图访问*/use\_app*时，`check_expired()`将在执行视图函数之前确保相关的账户资料不会泄漏。

> 参见
> 在Python文档中可以读到更多关于`wraps()`的内容：<http://docs.python.org/2/library/functools.html#functools.wraps>

## URL转换器

### 内建转换器

当你在Flask中定义一个路由时，你可以将指定的一部分转换成Python变量并传递给视图函数。

```
@app.route('/user/<username>')
def profile(username):
    pass
```

在URL中作为<username>的那一部分内容将作为`username`参数传递给视图函数。你也可以指定一个转换器过滤出特定的类型。

```
@app.route('/user/id/<int:user_id>')
def profile(user_id):
    pass
```

在这个代码块中，<http://myapp.com/user/id/tomato> 这个URL会返回一个404状态码 -- 此物无处觅。
这是因为URL中预期是整数的部分却遇到了一串字符串。

我们可以有另外一个接受一个字符串的视图函数。*/usr/id/tomato/*将调用它，而前一个函数只会被*/user/id/124*所调用。

下面是来自Flask文档的关于默认转换器的表格:

| 类型   | 作用                             |
| -------|-------------------------------   |
| string | 接受任何没有斜杠`/`的文本（默认）|
| int    | 接受整数                         |
| float  | 类似于`int`，但是接受的是浮点数  |
| path   | 类似于`string`，但是接受斜杠`/`  |

### 自定义转换器

我们也可以按照自己的需求打造自定义的转换器。
Reddit - 一个知名的链接分享网站 - 用户在此可以创建和管理基于主题和链接分享的社区。
比如`/r/python`和`/r/flask`，分别由URL`reddit.com/r/python`和`reddit.com/r/flask`表示。
Reddit有一个有趣的特性是，通过在URL中用一个`+`隔开各个社区名，你可以同时看到来自多个社区的帖子。比如`reddit.com/r/python+flask`。

我们可以使用一个自定义转换器来实现这种特性。
我们可以接受由加号隔离开来的任意数目参数，通过我们的ListConverter转换成一个列表，并传递给视图函数。

util.py
```python
from werkzeug.routing import BaseConverter

class ListConverter(BaseConverter):

    def to_python(self, value):
        return value.split('+')

    def to_url(self, values):
        return '+'.join(BaseConverter.to_url(value)
                        for value in values)
```

我们需要定义两个方法:`to_python()`和`to_url()`。
一如其名，`to_python()`用于转换路径成一个Python对象，并传递给视图函数。而`to_url()`被`url_for()`调用，来转换参数成为符合URL的形式。

为了使用我们的ListConverter，我们首先得将它的存在告知Flask。

/myapp/\_\_init\_\_.py
```
from flask import Flask

app = Flask(__name__)

from .util import ListConverter

app.url_map.converters['list'] = ListConverter
```

> **注意**
> 假如你的util模块有一行`from . import app`，那么有可能陷入循环import的问题。这就是为什么我等到app初始化之后才import ListConverter。

现在我们可以一如使用内建转换器一样使用我们的转换器。我们在字典中指定它的键为"list"，所以我们可以在`@app.route()`中这样使用:

views.py
```python
from . import app

@app.route('/r/<list:subreddits>')
def subreddit_home(subreddits):
    """显示给定subreddits里的所有帖子"""
    posts = []
    for subreddit in subreddits:
        posts.extend(subreddit.posts)

    return render_template('/r/index.html', posts=posts)
```

这应该会像Reddit的子社区系统一样工作。这样的方法可以用来实现你能想到的URL转换器。

## 总结

* Custom URL converters can be a great way to implement creative features involving URL’s.
* 来自Flask-Login的`@login_required`装饰器可以帮助你限制验证用户对视图的访问。
* Flask-Cache插件为你提供一组装饰器来实现多种方式的缓存。
* 我们可以开发自定义视图装饰器来帮助我们组织自己的代码，并坚守DRY(Don't Repeat Yourself 不重复你自己)原则。
* 自定义的URL转换器将会让你很嗨地玩转URL。

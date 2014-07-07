![Advanced patterns for views and routing](images/6.png)

# Advanced patterns for views and routing
# 关于视图和路由的进阶技巧

## View decorators
## 视图装饰器

Python decorators let us modify functions using other functions. When a function is “decorated” with another function, the decorator is called and can then call the original function, though it doesn’t have to. We can use decorators to wrap several views with some code that we wish to apply to each.
Python装饰器让我们可以用其他函数包装某个函数。
当一个函数被其他函数"装饰"时，那个装饰器会被调用，接着会调用原来的那个函数(不过不一定会这么做)。我们可以把我们想要重用的代码作为装饰器来包装一系列视图。

The syntax for decorating a function looks like this:
装饰器的语法看上去像这样:

```
@decorator_function
def decorated():
    pass
```

If you’ve gone through the Flask tutorial, that syntax might look familiar to you. `@app.route` is a decorator used to route URLs to view functions in Flask apps.
如果你看过Flask入门指南，那么对这个语法应该不敢到陌生。`@app.route`正是用于在Flask应用中给视图函数设定路由URL的装饰器。

Let’s take a look at some other decorators you can use in your Flask apps.
让我们看一下在你的Flask应用中用得上的一些别的装饰器。

### Authentication
### 认证

If your application requires that a user be logged in to access certain areas, there’s a good chance you want to use the Flask-Login extension. In addition to handling the details of user authentication, Flask-Login gives us a decorator to restrict certain views to authenticated users: `@login_required`.
如果你的应用要求用户在访问特定的资源前必须登录，是时候用上Flask-Login拓展。
除了处理用户认证的细节之外，Flask-Login允许我们使用`@login_required`这个装饰器来验证用户对某些资源的访问权限。

Here are a few views from an example application that uses Flask-Login and the `@login_required` decorator.
下面是从一个用到Flask-Login和`@login_required`装饰器的一个示范应用中获取的例子:

```
from Flask import render_template
from flask.ext.login import login_required, current_user


@app.route('/')
def index():
    return render_template("index.html")

@app.route('/dashboard')
@login_required
def account():
    return render_template("account.html")
```
{ WARNING: `@app.route` should always be the outermost view decorator. }
{ WARNING: `@app.route`必须是最外面的视图装饰器。 }

Only an authenticated user will be able to access the _/dashboard_ route. You can configure Flask-Login to redirect unauthenticated users to a login page, return an HTTP 401 status or anything else you’d like it to do with them.
只有已经验证的用户能够接触到*/dashboard*路由。你可以配置Flask-Login来重定向未验证用户到登录页面，返回HTTP 401状态码或别的你想干的事。

### Caching
### 缓存

Imagine that an article mentioning your application just appeared on CNN and several other news sites. You’re getting thousands of requests per second. Your homepage makes several trips to the database for each request, so all of this attention is slowing things down to a crawl. How can you speed things up quickly, so all of these visitors don’t miss out on our site?
意淫一下，假如你的应用突然有一天在微博/朋友圈或网上别的地方火了。
于是秒秒钟会有成千上万的请求涌向你的应用。你的主页在每个请求中都要从数据库跑上一大趟，结果海量的请求导致网站慢得像教务系统一样。
你能做什么来加速这一过程，以免用户以为你的应用挂掉了？

There are many good answers, but the one that is relevant to this chapter is to implement caching. Specifically, we’re going to use the Flask-Cache extension. This extension provides us with a decorator that we can use on our index view to cache the response for some period of time.
答案不止一个，不过就本章主旨而言，标准答案是实现缓存。
特别的，我们将要用到Flask-Cache拓展。这个拓展给我们提供一个可以用来缓存某个响应一段时间的装饰器。

You can configure Flask-Cache to work with whichever caching software you wish to use. A popular choice is Redis, which is easy to set-up and use. Assuming Flask-Cache is configured, here’s what our decorated view looks like.
你可以将Flask-Cache配置成跟你想用的缓存软件一起使用。一个普遍的选择是Redis，一个容易配置和使用的软件。
假设Flask-Cache已经配置好了，下面是我们的被装饰的视图的例子:

```
from flask.ext.cache import Cache
from flask import Flask

app = Flask()

# We'll ignore the configuration settings that you would normally include in this call
cache = Cache(app)

@app.route('/')
@cache.cached(timeout=60)
def index():
    [...] # Make a few database calls to get the information you need
    return render_template(
        'index.html',
        latest_posts=latest_posts,
        recent_users=recent_users,
        recent_photos=recent_photos
    )

```

Now the function will be run a maximum of once every 60 seconds. The response will be saved in our cache and pulled from there for any intervening requests.
现在这个函数将会在每60秒最多运行一次。响应的结果会被保存在缓存中，并可以让期间的每一个请求获取。

{ NOTE: Flask-Cache also lets us **memoize** functions — or cache the result of a function being called with certain parameters. You can even cache computationally expensive Jinja2 template snippets! }
{ NOTE: Flask-Cache同时允许我们**记住**函数 - 或缓存通过给定的参数调用的某个函数。你甚至可以缓存过于复杂的Jinja2模板片段! }

{ SEE MORE:
* Read more about Redis here: http://redis.io/
* Read about how to use Flask-Cache, and the many other things you can cache here: http://pythonhosted.org/Flask-Cache/
}
{ SEE MORE:
* 在这里可以读到关于Redis的更多内容: http://redis.io/
* 在这里可以知道怎样使用Flask-Cache，以及其他一些你可以缓存的内容: http://pythonhosted.org/Flask-Cache/
}

### Custom decorators
### 自定义装饰器

For this example, let's imagine we have an application that charges users each month. If a user’s account is expired, we’ll redirect them to the billing page and tell them to upgrade.
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

{ FIX LINE NUMBERS }

1: When a function is decorated with `@check_expired`, `check_expired()` is called and the decorated function is passed as a parameter.
1: 当用`@check_expired`装饰一个函数时，`check_expired()`被调用，被装饰的函数作为一个参数被传递进来。

2: @wraps is a decorator that tells Python that the function decorated_function() wraps around the view function func(). This isn’t strictly necessary, but it makes working with decorated functions a little more natural.
2: @wraps是一个装饰器，告知Python函数decorated_function()包装了视图函数func()。严格来说这不是必须的，但是这么做会使得装饰函数更加自然一些。

{ SEE MORE: Read more about what wraps() does here: http://docs.python.org/2/library/functools.html#functools.wraps }
{ SEE MORE: 在这里可以读到wraps()的工作机制: http://docs.python.org/2/library/functools.html#functools.wraps }

3: decorated_function will get all of the args and kwargs that were passed to the original view function func(). This is where we check if the user’s account is expired. If it is, we’ll flash a message and redirect them to the billing page.
3: decorated_function将截取原本传递给视图函数func()的args和kwargs。在这里我们检查用户的账户是否过期。如果是，我们将闪烁一则信息，并重定向到账单页面。

7: Now that we've done what we wanted to do, we run the original view func() with its original arguments.
4: 既然已经处理好自己的事情，我们把原来的参数交由视图函数func()去继续执行。

Here’s an example using our custom decorator and the `@login_required` decorator from the Flask-Login extension. We can use multiple decorators by stacking them.
下面这个例子用到了我们自定义的装饰器和来自Flask-Cache拓展的`@login_required`装饰器。我们可以将多个装饰器堆成栈来一起使用。

{ NOTE: The topmost decorator will run first, then call the next function in line: either the view function or the next decorator. The decorator syntax is just a little syntactic sugar.
{ NOTE: 位于最顶部的装饰器将最先运行，然后调用下一个函数:一个视图函数或下一个装饰器。装饰器语法只是一个语法糖而已。
This...
这样……
```
@foo
@bar
def bat():
    pass
```

...is the same is this:
……等同于这样:

```
def bat():
    pass
bat = foo(bar(bat))
```
}

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
    """This is where users go to use my amazing app."""

    return render_template('use_app.html')

@app.route('/account/billing')
@login_required
def account_billing():
    """This is where users go to update their billing info."""
    # [...]
    return render_template('account/billing.html')
```

Now when a user tries to access /use_app, check_expired() will make sure that there account hasn't expired before running the view function.
当一个用户试图访问/use\_app时，check_expired()将在执行视图函数之前确保相关的账户资料不会泄漏。

## URL Converters
## URL转换器

### Built-in converters
### 内建转换器

When you define a route in Flask, you can specify parts of it that will be converted into Python variables and passed to the view function. For example, you can specify that you are expecting a portion we’ll call “username” in the URL like so:
当你在Flask中定义一个路由时，你可以将指定的一部分转换成Python变量并传递给视图函数。
比如，你可以像这样在URL中指定一部分为"username":

```
@app.route('/user/<username>')
def profile(username):
    pass
```

Whatever is in the part of the URL labeled <username> will get passed to the view as the username parameter. You can also specify a converter to filter out what gets passed:
在URL中作为<username>的那一部分内容将作为username参数传递给视图函数。你也可以指定一个转换器过滤出特定的类型。

```
@app.route('/user/id/<int:user_id>')
def profile(user_id):
    pass
```

{ CHANCE TO ENCODE BACKER NAME }

With this example, the URL, http://myapp.com/user/id/tomato will return a 404 status code -- not found. This is because the part of the URL that is supposed to be an integer is actually a string.
在这个例子中，http://myapp.com/user/id/tomato 这个URL会返回一个404状态码 -- 此物无处觅。
这是因为URL中本应该是整数的部分实际上是一串字符串。

We could have a second view that looks for a string as well. That would be called for _/user/id/tomato/_ while the first would be called for _/user/id/124_.
我们可以有另外一个接受一个字符串的视图函数。*/usr/id/tomato/*将调用它，而前一个函数只会被*/user/id/124*所调用。

Here's a table from the Flask documentation showing the default converters:
下面是来自Flask文档的关于默认转换器的表格:

{ MAKE IT A TABLE }

string: accepts any text without a slash (the default)
string: 接受任何没有斜杠`/`的文本（默认）

int: accepts integers
int: 接受整数

float: like int but for floating point values
float: 类似于`int`，但是接受的是浮点数

path: like string but accepts slashes
path: 类似于`string`，但是接受斜杠`/`

### Customer converters

We can also make custom converters to suit our needs. On Reddit — a popular link sharing site — users create and moderate communities for theme-based discussion and link sharing. Some examples are /r/python and /r/flask, denoted by the path in the URL: reddit.com/r/python and reddit.com/r/flask respectively. An interesting feature of Reddit is that you can view the posts from multiple subreddits as one by seperating the names with a plus-sign in the URL, e.g. reddit.com/r/python+flask.

We can use a custom converter to implement this functionality in our Flask app. We’ll take an arbitrary number of elements separated by plus-signs, convert them to a list with our ListConverter class and pass the list of elements to the view function.

Here’s our implementation of the ListConverter class:

util.py
```
from werkzeug.routing import BaseConverter

class ListConverter(BaseConverter):

    def to_python(self, value):
        return value.split('+')

    def to_url(self, values):
        return '+'.join(BaseConverter.to_url(value)
                        for value in values)
```

We need to define two methods: `to_python()` and `to_url()`. As the titles suggest, `to_python()` is used to convert the path in the URL to a Python object that will be passed to the view and `to_url()` is used by `url_for()` to convert arguments to their appropriate forms in the URL.

To use our ListConverter, we first have to tell Flask that it exists.

/myapp/__init__.py
```
from flask import Flask

app = Flask(__name__)

from .util import ListConverter

app.url_map.converters['list'] = ListConverter
```

{ WARNING: This is another chance to run into some circular import problems if your util module has a `from . import app` line. That's why I waited until app had been initialized to import ListConverter. }

Now we can use our converter just like one of the built-ins. We specified the key in the dictionary as “list” so that’s how we use it in `@app.route()`.

views.py
```
from . import app

@app.route('/r/<list:subreddits>')
def subreddit_home(subreddits):
    """Show all of the posts for the given subreddits."""
    posts = []
    for subreddit in subreddits:
        posts.extend(subreddit.posts)

    return render_template('/r/index.html', posts=posts)
```

This should work just like Reddit’s multi-reddit system. This method can be used to make any URL converter you can think of.

## Summary

* The `@login_required` decorator from Flask-Login helps you limit views to authenticated users.
* The Flask-Cache extension gives you a bunch of decorators to implement various methods of caching.
* We can develop custom view decorators to help us organize our code and stick to DRY (Don’t Repeat Yourself) coding principals.
* Custom URL converters can be a great way to implement creative features involving URL’s.

# Static files
# 静态文件

As their name suggests, static files are the files that don't change. In your average app, this includes CSS files, JavaScript files and images. They can also include audio files and other things of that nature.

一如其名，静态文件是那些不会改变的文件。一般情况下，在你的应用中，这包括CSS文件，Javascript文件和图片。它也可以包括视频文件和其他可能的东西。

## Organizing your static files
## 组织你的静态文件

We'll create a directory for our static files called "static" inside our application package.

我们将在应用的包中创建一个叫"static"的文件夹放置我们的静态文件。

```
myapp/
    __init__.py
    static/
    templates/
    views/
    models.py
run.py
```

How you organize the files in _static/_ is a matter of personal preference. Personally, I get a little irked by having third-party libraries (e.g. jQuery, Bootstrap, etc.) mixed in with my own JavaScript and CSS files. To avoid this, I recommend separating third-party libraries out into a _lib/_ folder within the appropriate directory. Some projects use _vendor/_ instead of _lib/_. Here's an example of what an average app's _static/_ folder might look like.

*static/*里面的文件组织方式取决于个人的爱好。就我个人来说，如果第三方库（比如jQuery, Bootstrap等等）跟自己的Javascript和CSS文件混起来，我会因此而不爽。所以，我要将第三方库全放到一个*lib/*文件夹中。有时会用*vendor/*来代替*lib/*。下面是一个普通的应用的*static/*文件夹可能的样子。

```
static/
    css/
        lib/
        	bootstrap.css
        style.css
        home.css
        admin.css
    js/
    	lib/
        	jquery.js
        home.js
        admin.js
    img/
        logo.svg
        favicon.ico
```

### Serving a favicon
### 提供一个favicon

The files in your static directory will be served from yourapp.com/static/. By default web browsers and other software expects your favicon to be at yourapp.com/favicon.ico. To fix this discrepency, you can add the following in the `<head>` section of your site template.

用户将通过yourapp.com/static/访问你的静态文件夹中的文件。默认下浏览器和其他软件认为你的favicon是位于yourapp.com/favicon.ico。要想解决这种不一致。你可以在站点模板的`<head>`部分添加下面内容。

```
<link rel="shortcut icon" href="{{ url_for('static', filename='img/favicon.ico') }}">
```

## Manage static assets with Flask-Assets
## 用Flask-Assets管理静态文件

Flask-Assets is an extension for managing your static files. There are two really useful tools that Flask-Assets provides. First, it lets you define **bundles** of assets in your Python code that can be inserted together in your template. Second, it lets you pre-process those files. This means that you can combine and minify your CSS and JavaScript files so that the user only has to load two minified files (CSS and JavaScript) without forcing you to develop a complex asset pipeline. You can even compile your files from Sass, LESS, CoffeeScript and many other sources.

Flask-Assets是一个管理静态文件的插件。它提供了两种非常有用的特性。首先，它允许你在Python代码中定义*多组*（bundles）可以同时插入你的模板的静态文件。其次，它允许你预处理这些文件。这意味着你可以合并并压缩你的CSS和Javascript文件，这样用户就会仅仅得到两个压缩后的文件（CSS和Javascript）而免于花费太多带宽。你甚至可以从Sass，Less，CoffeeScript或别的源码里编译出最终产物。

Here's the basic the static directory we'll be working with in this chapter:

下面是这一章中也做例子的静态文件夹的基本结构。

_myapp/static/_
```
static/
    css/
    	lib/
        	reset.css
        common.css
        home.css
        admin.css
    js/
    	lib/
        	jquery-1.10.2.js
        	Chart.js
        home.js
        admin.js
    img/
        logo.svg
        favicon.ico
```

### Defining bundles
### 定义分组

Our app has two sections: the public site and the admin panel (referred to as "home" and "admin" respectively). We'll define four bundles to cover this: a JavaScript and CSS bundle for each section. We'll put these in an assets module inside our util package.

我们的应用有两部分：公共网站和管理面板（分别称作"home"和"admin"）。我们将定义四个分组来覆盖它：每个部分有一个Javascript和一个CSS分组。我们将它们放入util包里的assets模块。

_myapp/util/assets.py_
```
from flask.ext.assets import Bundle, Environment
from .. import app

bundles = {

    'home_js': Bundle(
        'js/lib/jquery-1.10.2.js',
        'js/home.js',
        output='gen/home.js),

    'home_css': Bundle(
        'css/lib/reset.css',
        'css/common.css',
        'css/home.css',
        output='gen/home.css),

    'admin_js': Bundle(
        'js/lib/jquery-1.10.2.js',
        'js/lib/Chart.js',
        'js/admin.js',
        output='gen/admin.js),

    'admin_css': Bundle(
        'css/lib/reset.css',
        'css/common.css',
        'css/admin.css',
        output='gen/admin.css)
}

assets = Environment(app)

assets.register(bundles)
```

{ WARNING: Flask-Assets combines your files in the order in which they are listed here. If _admin.js_ requires _jquery-1.10.2.js_, make sure jquery is listed first.// FIXME

{ WARNING: Flask-Assets按照被列出来的顺序合并你的文件。如果*admin.js*依赖*jquery-1.10.2.js*，确保jquery被列在前面。}

We're defining the bundles in a dictionary to make it easy to register them. webassets, the package behind Flask-Assets lets us register bundles in a number of ways, including passing a dictionary like the one we made in this snippet.

我们通过字典来定义分组，这样方便注册它们。webassets，在Flask-Assets背后支撑这一切的包提供了一系列方式来注册分组，包括上面我们演示的以字典作参数的方法。

{ SOURCE: https://github.com/miracle2k/webassets/blob/0.8/src/webassets/env.py#L380 }

Since we're registering our bundles in `util.assets`, all we have to do is import that module in __init__.py after our app has been initialized via `app = Flask(__name__)`.

既然我们已经在`util.assets`中注册了我们的分组，剩下的就是在__init__.py中，在app对象通过`app = Flask(__name__)`初始化之后，来导入这个模块。

myapp/__init__.py
```
# [...] Initialize the app

from .util import assets
```

### Using your bundles
### 使用你的分组

Here's the templates folder of our hypothetical application:

下面是我们的例子中的模板文件夹：

_myapp/templates/_
```
templates/
    home/
        layout.html
        index.html
        about.html
    admin/
        layout.html
        dash.html
        stats.html
```

To use our admin bundles, we'll insert them into the parent template for the admin section, _admin/layout.html_.

要使用我们的admin分组，我们将插入它们到admin部分的基础模板 - *admin/layout.html* - 中。

myapp/templates/admin/layout.html
```
<!DOCTYPE html>
<html lang="en">
    <head>
        {% assets "admin_js" %}
            <script type="text/javascript" src="{{ ASSET_URL }}"></script>
        {% endassets %}
        {% assets "admin_css" %}
            <link rel="stylesheet" href="{{ ASSET_URL }}" />
        {% endassets %}
    </head>
    <body>
    {% block body %}
    {% endblock %}
    </body>
</html>
```

We can do the same thing for the home bundles in _templates/home/layout.html_.

对于home分组，我们也同样在*templates/home/layout.html*做一样的处理。

### Using filters

We can use webassets filters to pre-process our static files. This is especially handy for minifying our JavaScript and CSS bundles. We will now modify our code to do just that.

myapp/util/assets.py
```
# [...]

bundles = {

    'home_js': Bundle(
        'lib/jquery-1.10.2.js',
        'js/home.js',
        output='gen/home.js',
        filters='jsmin'),

    'home_css': Bundle(
        'lib/reset.css',
        'css/common.css',
        'css/home.css',
        output='gen/home.css',
        filters='cssmin'),

    'admin_js': Bundle(
        'lib/jquery-1.10.2.js',
        'lib/Chart.js',
        'js/admin.js',
        output='gen/admin.js',
        filters='jsmin'),

    'admin_css': Bundle(
        'lib/reset.css',
        'css/common.css',
        'css/admin.css',
        output='gen/admin.css',
        filters='cssmin')
}

# [...]
```

{ NOTE: To use the `jsmin` and `cssmin` filters, you'll need to install the jsmin and cssmin packages (e.g. with `pip install jsmin cssmin`). Make sure to add them to _requirements.txt_ too. }

Flask-Assets will merge and compress our files the first time the template is rendered, and it'll automatically update the compressed file when one of the source files changes.

{ NOTE: If you set `ASSETS_DEBUG = True` in your config, Flask-Assets will output each source file individually instead of merging them. }

{ SEE ALSO: You can use Flask-Assets filters to automatically compile Sass, Less, CoffeeScript, and other pre-processors. Take a look at some of these other filters that you can use: http://elsdoerfer.name/docs/webassets/builtin_filters.html#js-css-compilers }

## Summary

* Static files go in the _static/_ directory.
* Separate third-party libraries from your own static files.
* Specify the location of your favicon in your templates.
* Use Flask-Assets to insert your static files in your templates.
* Flask-Assets can compile, combine and compress your static files.

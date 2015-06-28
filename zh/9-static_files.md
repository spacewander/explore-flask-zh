![静态文件](images/static.png)

# 静态文件

一如其名，静态文件是那些不会改变的文件。一般情况下，在你的应用中，这包括CSS文件，Javascript文件和图片。它也可以包括视频文件和其他可能的东西。

## 组织你的静态文件

我们将在应用的包中创建一个叫*static*的文件夹放置我们的静态文件。

```
myapp/
    __init__.py
    static/
    templates/
    views/
    models.py
run.py
```

*static/*里面的文件组织方式取决于个人的爱好。就我个人来说，如果第三方库（比如jQuery, Bootstrap等等）跟自己的Javascript和CSS文件混起来，我会因此而不爽。所以，我要将第三方库全放到一个*lib/*文件夹中。有时会用*vendor/*来代替*lib/*。

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

### 提供一个favicon

用户将通过yourapp.com/static/访问你的静态文件夹中的文件。默认下浏览器和其他软件认为你的favicon位于yourapp.com/favicon.ico。要想解决这种不一致。你可以在站点模板的`<head>`部分添加下面内容。

```
<link rel="shortcut icon" href="{{ url_for('static', filename='img/favicon.ico') }}">
```

## 用Flask-Assets管理静态文件

Flask-Assets是一个管理静态文件的插件。它提供了两种非常有用的特性。首先，它允许你在Python代码中定义*多组*（bundles）可以同时插入你的模板的静态文件。其次，它允许你预处理这些文件。这意味着你可以合并并压缩你的CSS和Javascript文件，这样用户就会仅仅得到两个压缩后的文件（CSS和Javascript）而免于花费太多带宽。你甚至可以从Sass，Less，CoffeeScript或别的源码里编译出最终产物。

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

### 定义分组

我们的应用有两部分：公共网站和管理面板（分别称作"home"和"admin"）。我们将定义四个分组来覆盖它：每个部分有一个Javascript和一个CSS分组。我们将它们放入`util`包里的assets模块。

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

Flask-Assets按照被列出来的顺序合并你的文件。如果*admin.js*依赖*jquery-1.10.2.js*，确保jquery被列在前面。

我们通过字典来定义分组，这样方便注册它们。[webassets](https://github.com/miracle2k/webassets/blob)，实际上是Flask-Assets的核心，提供了一系列方式来注册分组，包括上面我们演示的以字典作参数的方法。（译注：webassets之于Flask-Assets，正如SQLAlchemy之于Flask-SQLAlchemy。）

> **参见**
> webassets在这里注册了分组：
> <https://github.com/miracle2k/webassets/blob/0.8/src/webassets/env.py#L380>

既然我们已经在`util.assets`中注册了我们的分组，剩下的就是在\_\_init\_\_.py中，在app对象初始化之后，来导入这个模块。

myapp/\_\_init\_\_.py
```
# [...] Initialize the app

from .util import assets
```

### 使用你的分组

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

对于home分组，我们也同样在*templates/home/layout.html*做一样的处理。

### 使用过滤器

我们可以使用webassets过滤器来预处理我们的静态文件。这将方便我们压缩Javascript和CSS文件。现在修改下我们的代码来实现这一点。

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

> **注意**
> 要想使用`jsmin`和`cssmin`过滤器，你需要安装jsmin和cssmin包（使用`pip install jsmin cssmin`）。确保把它们也加入到*requirements.txt*。

一旦模板已经渲染好，Flask-Assets将在合并的同时压缩我们的文件，而且当其中一个源文件改变时，它会自动更新压缩文件。

> **注意**
> 如果你在配置中设置`ASSETS_DEBUG = True`， Flask-Assets将独立输出每一个源文件而不会合并它们。

> **参见**
> 你可以使用Flask-Assets过滤器来自动编译Sass，Less，CoffeeScript，和其他预处理器。来看下你还可以使用哪些过滤器： http://elsdoerfer.name/docs/webassets/builtin_filters.html#js-css-compilers

## 总结

* 静态文件归于*static/*文件夹。
* 将第三方库跟你自己的静态文件隔离开来。
* 在你的模板里指定你的favicon的路径。
* 使用Flask-Assets来在模板插入你的静态文件。
* Flask-Assets可以编译，合并以及压缩你的静态文件。

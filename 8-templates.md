![Templates](images/8.png)

# 模板

While Flask doesn't force you to use any particular templating language, it assumes that you're going to use Jinja. Most of the developers in the Flask community use Jinja, and I recommend that you do the same. There are a few extensions that have been written to let you use other templating languages, but unless you have a good reason (not knowing Jinja yet is not a good reason!) stick with the default; you'll save yourself a lot of time and headache.

尽管Flask并不强迫你使用某个特定的模板语言，它还是默认你会使用Jinja。在Flask社区的大多数开发者使用Jinja，并且我建议你也跟着做。有一些插件允许你用其他模板语言进行替代，但除非你有充分理由（不懂Jinja可不是一个充分的理由），否则请保持那个默认的选项；这样你会避免浪费很多时间来焦头烂额。

{ NOTE: Almost all resources imply Jinj2 when they refer to "Jinja." There was a Jinja1, but we won't deal with it here. When you see Jinja, we're talking about this: http://jinja.pocoo.org/ }

{ NOTE: 几乎所有提及Jinja的资源讲的都是Jinja2。Jinja1确实曾存在过，但在这里我们不会讲到它。当你看到Jinja时，我们讨论的是这个Jinja: http://jinja.pocoo.org/ }

{ SEE MORE: Here are a couple of those extensions for other templating languages.
* Flask-Genshi: http://pythonhosted.org/Flask-Genshi/
* Flask-Mako: http://pythonhosted.org/Flask-Mako/
}

{ SEE MORE: 下面是能让你使用其他模板语言的一些插件。
* Flask-Genshi: http://pythonhosted.org/Flask-Genshi/
* Flask-Mako: http://pythonhosted.org/Flask-Mako/
}

## Jinja快速入门

The Jinja documentation does a great job of explaining the syntax and features of the language. I won't reiterate it all here, but I do want to make sure that you see this important note:

Jinaja文档在解释这门语言的语法和特性这方面做得很棒。在这里我不会啰嗦一遍，但还是会再一次向你强调下面一点：

> There are two kinds of delimiters. `{% ... %}` and `{{ ... }}`. The first one is used to execute statements such as for-loops or assign values, the latter prints the result of the expression to the template.

> Jinja有两种定界符。`{% ... %}`和`{{ ... }}`。前者用于执行像for循环或赋值等语句，后者向模板输出一个表达式的结果。

{ SOURCE: http://jinja.pocoo.org/docs/templates/#synopsis }

## 怎样组织模板

So where do templates fit into our app? If you've been following along at home, you may have noticed that Flask is really flexible about where you put things. Templates are no exception. You may also notice that there's usually a recommended place to put things. Two points for you. For templates, that place is in the package directory.

所以要将模板放进我们的应用的哪里呢？如果你是从头开始阅读的本文，你可能注意到了Flask在对待你如何组织项目结构的事情上十分随意。模板也不例外。你大概已经注意到，总会有一个放置文件的推荐位置。记住两点。对于模板，这个最佳位置是放在包文件夹下。

```
myapp/
    __init__.py
    models.py
    views/
    templates/
    static/
run.py
requirements.txt
```

Let's take a closer look at that templates directory.

让我们打开模板文件夹看看。

```
templates/
    layout.html
    index.html
    about.html
    profile/
        layout.html
        index.html
	photos.html
    admin/
        layout.html
        index.html
        analytics.html
```

The structure of the templates parallels the structure of the routes. The template for route myapp.com/admin/analytics is _templates/admin/analytics.html_. There are also some extra templates in there that won't be rendered directly. The _layout.html_ files are meant to be inherited by the other templates.

模板的结构平行于路由的结构。对应于路由myapp.com/admin/analytics的模板是*templates/admin/analytics.html*。这里也有一些额外的模板不会被直接渲染。*layout.html*文件就是用于被其他模板继承的。

## 继承

Much like Batman’s backstory, a well organized templates directory relies heavily on inheritance. The **base template** usually defines a generalized structure that all of the **child templates** will work within. In our example, _layout.html_ is a base template and the other _.html_ files are child templates.

就像蝙蝠侠一样，一个组织良好的模板文件夹也离不开继承带来的好处。**基础模板**通常定义了一个适用于所有的*子模板*的主体结构。在我们的例子里，*layout.html*是一个基础模板，而其他的*html*文件都是子模板。

You’ll generally have one top-level _layout.html_ that defines the general layout for your application and one for each section of your site. If you take a look at the directory above, you’ll see that there is a top-level _myapp/templates/layout.html_ as well as _myapp/templates/profile/layout.html_ and _myapp/templates/admin/layout.html_. The last two files inherit and modify the first.

通常，你会有一个顶级的*layout.html*定义你的应用的主体布局，外加站点的每一个节点也有自己的一个*layout.html*。如果再看一眼上面的文件夹结构，你会看到一个顶级的*myapp/templates/layout.html*，以及*myapp/templates/profile/layout.html*和*myapp/templates/admin/layout.html*。后两个文件继承并修改第一个文件。

Inheritance is implemented with the `{% extends %}` and `{% block %}` tags. In the parent template, you can define blocks which will be populated by child templates.

继承是通过`{% extends %}`和`{% block %}`标签实现的。在双亲模板中，你可以定义要给子模板处理的block。

_myapp/templates/layout.html_
```
<!DOCTYPE html>
<html lang="en">
	<head>
    	<title>{% block title %}{% endblock %}</title>
    </head>
    <body>
    {% block body %}
    	<h1>This heading is defined in the parent.</h1>
    {% endblock %}
    </body>
</html>
```

In the child template, you can extend the parent template and define the contents of those blocks.

在子模板中，你可以拓展双亲模板并定义block里面的内容。

_myapp/templates/index.html_
```
{% extends "layout.html" %}
{% block title %}Hello world!{% endblock %}
{% block body %}
	{{ super() }}
    <h2>This heading is defined in the child.</h2>
{% endblock %}
```

The `super()` function lets us include the current contents of the block when we redefined them in the child.

`super()`函数让我们在子模板里重定义一个block的时候，加载这个block原有的内容。

{ SEE ALSO: For more information on inheritance, refer to the Jinja Template Inheritence documentation.
* http://jinja.pocoo.org/docs/templates/#template-inheritance
}

{ SEE ALSO: 若想了解更多关于继承的内容，请移步到Jinja模板继承方面的文档。
* http://jinja.pocoo.org/docs/templates/#template-inheritance
}

## 创建宏

We can implement DRY (Don't Repeat Yourself) principles in our templates by abstracting snippets of code that appear over and over into **macros**. If we're working on some HTML for our app's navigation, we might want to give a different class to the “active” link (i.e. the link to the current page). Without macros we'd end up with a block of if/else statements checking each link to find the acive one. Macros provide a way to modularize that code; they work like functions. Let's look at how we'd mark the active link using a macro.

凭借将反复出现的代码片段抽象成**宏**，我们可以实现DRY原则（Don't Repeat Yourself）。在撰写用于应用的导航功能的HTML时，我们可能会需要给“活跃”链接（比如，到当前页面的链接）一个不同的类。如果没有宏，我们将不得不使用一大堆if/else语句来从每个链接中过滤出“活跃”链接。宏提供了模块化模板代码的一种方式；它们就像是函数一样。让我们看一下如何使用宏来标记活跃链接。

myapp/templates/layout.html
```
{% from "macros.html" import nav_link with context %}
<!DOCTYPE html>
<html lang="en">
    <head>
    {% block head %}
        <title>My application</title>
    {% endblock %}
    </head>
    <body>
        <ul class="nav-list">
            {{ nav_link('home', 'Home') }}
            {{ nav_link('about', 'About') }}
            {{ nav_link('contact', 'Get in touch') }}
        </ul>
    {% block body %}
    {% endblock %}
    </body>
</html>
```

What we are doing is calling an undefined macro — `nav_link` — and passing it two parameters: the target endpoint (i.e. the function name for the target view) and the text we want to show.

现在我们调用了一个尚未定义的宏 - `nav_link` - 并传递两个参数给它：一个目标（比如目标视图的函数名）和我们想要展示的文本。

{ NOTE: You may notice that we specified “with context” in the import statement. The Jinja **context** consists of the arguments passed to the `render_template()` function as well as the Jinja environment context from our Python code. These variables are made available in the template that is being rendered. Some variables are explicitly passed by us, e.g. `render_template("index.html", color="red")`, but there are several variables and functions that Flask automatically includes in the context , e.g. `request`, `g` and `session`. When we say `{% from ... import ... with context %}` we are telling Jinja to make all of these variables available to the macro as well.
}

{ NOTE: 你可能到了我们在import语句中加入了“with context（上下文）”。Jinja**上下文**包括了通过`render_template()`函数传递的参数以及在我们的Python代码的Jinja环境上下文。这些变量能够被用于模板的渲染。一些变量是我们显式传递过去的，比如`render_template("index.html", color="red")`，但还有些变量和函数是Flask自动加入到上下文的，比如`request`，`g`和`session`。使用了`{% from ... import ... with context %}`，我们告诉Jinja让所有的变量也在宏里可用。
}

{ SEE ALSO:
* All of the global variables that are passed to the Jinja context by Flask: http://flask.pocoo.org/docs/templating/#standard-context}
* We can define variables and functions that we want to be merged into the Jinja context with context processors: http://flask.pocoo.org/docs/templating/#context-processors }

{ SEE ALSO:
* 所有的全局变量都是由Flask传递给Jinja上下文的: http://flask.pocoo.org/docs/templating/#standard-context}
* 通过上下文处理器（context processors），我们可以增加传递给Jinja上下文的变量和函数: http://flask.pocoo.org/docs/templating/#context-processors }

Now let’s take a look at the macro itself:

现在来看看宏的实现：

myapp/templates/macros.html
```
{% macro nav_link(endpoint, text) %}
{% if request.endpoint.endswith(endpoint) %}
    <li class="active"><a href="{{ url_for(endpoint) }}">{{text}}</a></li>
{% else %}
    <li><a href="{{ url_for(endpoint) }}">{{text}}</a></li>
{% endif %}
{% endmacro %}
```

Now we've defined the macro in _myapp/templates/macros.html_. What we're doing is using Flask's `request` object — which is available in the Jinja context by default — to check whether or not the current request was routed to the endpoint passed to `nav_link`. If it was, then we're currently on that page, and we can mark it as active.

现在我们已经在*myapp/templates/macros.html*中定义了一个宏。我们所做的，就是使用Flask的`request`对象 - 默认在Jinja上下文中可用 - 来检查当前路由是否是传递给`nav_link`的那个路由参数。如果是，我们就在目标链接指向的页面上，于是可以标记它为活跃的。

{ NOTE: The from x import y statement takes a relative path for x. If our template was in _myapp/templates/user/blog.html_ we would use `from "../macros.html" import nav_link with context`.
}

{ NOTE: `from x import y`语句中要求x是相对于y的相对路径。如果我们的模板位于*myapp/templates/user/blog.html*，我们需要使用`from "../macros.html" import nav_link with context`。
}

## 自定义过滤器

Jinja filters are functions that can be applied to the result of an expression in the `{{ ... }}` delimeters before that result is printed to the template. Here's a look at the syntax:

Jinja过滤器是在渲染成模板之前，作用于`{{ ... }}`中的表达式的值的函数。下面来看下它的语法：

```
<h2>{{ article.title|title }}</h2>
```

In this snippet, the `title` filter will take `article.title` and return a title-cased version, which will then be printed to the template. The syntax, and functionality, is very much like the UNIX practice of "piping" the output of one program to another.

在这个片段中，`title`过滤器接受`article.title`并返回一个标题格式的文本，用于输出到模板中。它的语法，以及功能，皆一如Unix中修改程序输出的“管道”一样。

{ SEE MORE: There are lots of built-in filters like `title`. See the full list here: http://jinja.pocoo.org/docs/templates/#builtin-filters }

{ SEE MORE: 除了`title`，还有许许多多别的内建的过滤器。在这里可以看到完整的列表： http://jinja.pocoo.org/docs/templates/#builtin-filters }

We can define our own filters for use in our Jinja templates. As an example, we’ll implement a simple `caps` filter to capitalize all of the letters in a string.

我们可以自定义用于Jinja模板的过滤器。作为例子，我们将实现一个简单的`caps`过滤器来使字符串中所有的字母大写。

{ NOTE: Jinja already has an `upper` filter that does this, as well as a `capitalize` filter that capitalizes the first character and lowercases the rest. These also handle unicode conversion, but we’ll keep our example focused on the concept at hand.}

{ NOTE: Jinja已经有一个`upper`过滤器能实现这一点，还有一个`capitalize`过滤器能大写第一个字符并小写剩余字符。这些过滤器还能处理Unicode转换，不过我们的这个例子将专注于阐述相关概念。}

We’re going to define our filter in a module located at _myapp/util/filters.py_. This gives us a `util` package in which to put other miscellaneous modules.

我们将在*myapp/util/filters.py*中定义我们的过滤器。这个`util`包可以用来放置各种杂项。

myapp/util/filters.py
```
from .. import app

@app.template_filter()
def caps(text):
    """Convert a string to all caps."""
    return text.uppercase()
```

We are registering our function as a Jinja filter by using the `@app.template_filter()` decorator. The default filter name is just the name of the function, but you can pass an argument to the decorator to change that:

通过`@app.template_filter()`装饰器，我们能将某个函数注册成Jinja过滤器。默认的过滤器名字就是函数的名字，但是通过传递一个参数给装饰器，你可以改变它：

```
@app.template_filter('make_caps')
def caps(text):
    """Convert a string to all caps."""
    return text.uppercase()
```

Now we can call `make_caps` in the template rather than `caps`:  `{{ "hello world!"|make_caps }}`.

现在我们可以在模板中调用`make_caps`而不是`caps`：`{{ "hello world!"|make_caps }}`。

To make our filter available in the templates, we just need to import it in our top-level ___init.py_. // FIXME

为了让我们的过滤器在模板中可用，我们仅需要在顶级*__init__.py*中import它。

myapp/__init__.py
```
# 确保app已经被初始化以免导致循环import
from .util import filters
```

## 总结

* Use Jinja for templating.
* Jinja has two kinds of delimeters: `{% ... %}` and `{{ ... }}`. The first one is used to execute statements such as for-loops or assign values, the latter prints the result of the contained expression to the template.
* Templates should go in _myapp/templates/_ — i.e. a directory inside of the application package.
* I recommend that the structure of the _templates/_ directory mirror the URL structure of the app.
* You should have a top-level _layout.html_ in _myapp/templates_ as well as one for each section of the site. The former extend the latter.//FIXME
* Macros are like functions made-up of template code.
* Filters are functions made-up of Python code and used in templates.

* 使用Jinja作为模板语言。
* Jinja有两种定界符：`{% ... %}`和`{{ ... }}`。前者用于执行类似循环或赋值的语句，后者向模板输出表达式求值的结果。
* 模板应该放在*myapp/templates/* - 一个在应用文件夹里面的目录。
* 我建议*template/*文件夹的结构应该与应用URL结构一一对应。
* 你应该在*myapp/templates*以及站点的每一部分放置一个*layout.html*作为布局模板。后者是前者的拓展。
* 可以用模板语言写类似于函数的宏。
* 可以用Python代码写应用在模板中的过滤器函数。

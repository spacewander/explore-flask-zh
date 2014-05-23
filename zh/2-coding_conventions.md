![Coding conventions](images/2.png)

# 代码约定

There are a number of conventions in the Python community to guide the way you format your code. If you’ve been developing with Python for a while, then you might already be familiar with some of these conventions. I’ll keep things brief and leave a few URLs where you can find more information if you haven’t come across these topics before.

在Python社区中有许多关于代码风格的约定。如果你写过一段时间Python了，那么也许对此已经有些了解。
我会简单介绍一下，同时给你一些URL链接，从中你可以找到关于这个话题的详细信息。

## 让我们提出一个PEP！

A **PEP** is a “Python Enhancement Proposal.” These proposals are indexed and hosted at python.org [http://www.python.org/dev/peps/]. In the index, PEPs are grouped into a number of categories, including meta-PEPs, which are more informational than technical. The technical PEPs, on the other hand, often describe things like improvements to Python’s internals.

**PEP**全称是“Python Enhancement Proposal”（Python增强提案）。你可以在[python.org](http://www.python.org/dev/peps/)上找到它们以及对应的索引目录。
PEP在索引目录中按照数字编号排列，包括了元PEP（meta-PEP，讨论关于PEP的细节）。与之对应的是技术PEP（technical PEP），思考的是诸如Python内部实现的改良这样的话题。

There are a few PEPs, like PEP 8 and PEP 257 that affect the way we write our code. PEP 8 contains coding style guidelines. PEP 257 contains guidelines for docstrings, the generally accepted method of documenting code.

有一些PEP，比如PEP 8和PEP 257，影响了Python代码风格的标准。
PEP 8包括了Python代码风格的规约。
而PEP 257包括了文档字符串（docstrings， 在Python中给代码加文档的标准方式）的规约。

### PEP 8: Python代码风格规约

PEP 8 is the official style guide for Python code. I recommend that you read it and apply its recommendations to your Flask projects (and all other Python code). Your code will be much more approachable when it starts growing to many files with hundreds, or thousands, of lines of code. The PEP 8 recommendations are all about having more readable code. Plus, if your project is going to be open source, potential contributors will likely expect and be comfortable with code written with PEP 8 in mind.

PEP 8是对Python代码风格的官方规约。
我建议你阅读它并将之付诸在Flask项目（以及其他Python项目）的开发实践中。
当项目规模膨胀到多个包含成百上千行代码的文件时，这样做会使你的代码更加工整、了然。毕竟PEP 8的建议都是围绕着实现更加可读的代码这个目标。
另外，如果你的项目准备开源，潜在的奉献者（contributors）会很高兴看到你的代码是遵循PEP 8的。

One particularly important recommendation is to use 4 spaces per indentation level. No real tabs. If you break this convention, it’ll be a burden on you and other developers when switching between projects. That sort of inconsistency is a pain in any language, but white-space is especially important in Python, so switching between real tabs and spaces could result in any number of errors that are very difficult to debug.

一个至关重要的建议是每级缩进使用4个空格。不要使用tab。
如果你打破了这个规约，它将会成为你（以及你的队友）在项目间切换的一个负担。
这种不一致一向是任意语言心中的痛，但是对于Python，一门着重留白的语言，这是一个不可承受之重。
因为tab与space之间的混搭会导致不可预期且难以排查的错误。

### PEP 257: 文档字符串规约

PEP 257 [LINK TO PEP] covers another Python standard: **docstrings**. You can read the definition and recommendations in the PEP itself, but here’s an example to give you an idea of what a docstring looks like:

PEP 257 [LINK TO PEP] 覆盖了Python的另一项标准:**docstrings**。
你可以阅读PEP中的定义和相关建议，不过这里会给一个例子来展示一个文档字符串应该是怎样的：

```
def launch_rocket():
    """主要的火箭发射调度器

    启动发射火箭所需的每一个步骤。
    """
    # [...]
```

These kinds of docstrings can be used by software such as [Sphinx](http://sphinx-doc.org/) to generate documentation files in HTML, PDF and other formats. They also contribute to making your code more approachable.

这种风格的文档字符串可以通过一些诸如[Sphinx](http://sphinx-doc.org/)的软件来生成不同格式的文档。
同时它们也有助于让你的代码更加工整。

## 相对形式的import

Relative imports make life a little easier when developing Flask apps. The premise is simple. Previously, you might have specified the app's package name when importing internal modules:

开发Flask应用时，使用相对形式的import会让你的生活更加轻松。
原因很简单。之前，当需要import一个内部模块时，你也许要显式指明应用的包名（the app's package name）。

```
from myapp.models import User
```
Using relative imports, you would indicate the relative location of the module using a dot notation where the first dot indicates the current directory and each subsequent dot represents the next parent directory.

用了相对形式的import后，你可以使用点标记法：第一个`.`来表示当前目录，之后的每一个`.`表示下一个父目录。

```
from ..models import User
```

The advantage of this method is that the package becomes a heck of a lot more modular. Now you can rename your package and re-use modules from other projects without the need to update the hard-coded import statements.

这种做法的好处在于使得package变得更加模块化了。
现在你可以重命名你的package并在别的项目中重用模块，而无需忍受更新被硬编码的包名之苦。

{ SEE MORE:
* You can read a little more about the syntax for relative imports from this section in PEP 328: http://www.python.org/dev/peps/pep-0328/#guido-s-decision
* Here’s a Tweet that I came across that makes a good testimonial for using relative imports: https://twitter.com/dabeaz/status/372059407711887360
}

{ SEE MORE:
* 你可以在PEP 328的这一节里读到更多关于相对形式的import的语法： http://www.python.org/dev/peps/pep-0328/#guido-s-decision
* 在这个Tweet上面，我看到了一个使用相对形式的import的好处： https://twitter.com/dabeaz/status/372059407711887360
}

## 总结

* Try to follow the coding style conventions laid out in PEP 8.
* Try to document your app with docstrings as defined in PEP 257.
* Use relative imports to import your apps internal modules.
* 尽量遵循PEP 8中的代码风格规约。
* 尽量遵循PEP 257中的文档字符串规约。
* 使用相对形式的import来import你的应用中的内部模块。

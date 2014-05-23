# 前言

This book is a collection of the best practices for using Flask. There are a lot of pieces to the average Flask application. You’ll often need to interact with a database and authenticate users, for example. In the coming pages I’ll do my best to explain the “right way” to do this sort of stuff. My recommendations aren’t always going to apply, but I’m hoping that they’ll be a good option most of the time.

本书旨在展示使用Flask的最佳实践。
开发一个普通的Flask应用需要跟形形色色的领域打交道。比如，你经常需要操作数据库，验证用户。
在接下来的几页里我将尽我所能来介绍处理这些事情时的“正确之道”。
我的建议并不总能有用，但我希望它们在大多数情况下都是一个好选择。

## 假设

In order to present you with more specific advice, I've written this book with a few fundamental assumptions. It's important to keep this in mind when you're reading and applying these recommendations to your own projects.

为了给你提供更贴切的建议，我将基于几个基本的假设撰写本书。当你阅读并在自己的项目中应用这些建议时，请勿忘这一点。

### 受众

The content of this book builds upon the information in the official documentation. I highly recommend that you go through the user guide and follow along with the tutorial [LINK TO USER GUIDE AND TUTORIAL]. This will give you a chance to become familiar with the vocabulary of Flask. You should understand what views are, the basics of Jinja templating and other fundamental concepts defined for beginners. I've tried to avoid overlap with the information already available in the user guide, so if you read this book first, there’s a good chance that you’ll find yourself lost (is that an oxymoron?).

本书的内容基于官方文档之上。我强烈建议你深入阅读官方用户指南和新手教程[]。这将给你一个更熟悉Flask的机会。你至少需要知道什么是view，Jinja模板的基础知识以及新手应有的其他基本概念。我会尽量避免重提用户指南中存在的信息，所以如果直接阅读本书，你就会有对阅读官方文档的急迫需求（这不错吧？）。

With all of that said, the topics in this book aren’t highly advanced. The goal is just to highlight best practices and patterns that will make development easier for you. While I'm trying to avoid too much overlap with the official documentation, you may find that I reiterate certain concepts to make sure that they’re familiar. You shouldn't need to have the beginner's tutorial open while you read this.

虽然这么说，本书涉及的主题并不高深。本书仅仅是强调减轻开发者负担的最佳实践和模式。尽量避免罗嗦官方文档中提到的内容的同时，我也会再次强调一些概念来加深印象。
在阅读这部分内容时，你不需要重读新手教程。

### 版本

#### Python 2 还是 Python 3

As I write this, the Python community is in the midst of a transition from Python 2 to Python 3. The official stance of the PSF is as follows:

当我写下此文， Python社区正处于从Python 2迁移到Python 3的动荡之中。PSF的官方态度如下：

> Python 2.x is the status quo, Python 3.x is the present and future of the language
> Citation: http://wiki.python.org/moin/Python2orPython3
> Python 2.x正在老去，Python 3.x才是这么语言的现在和未来
> 来源： http://wiki.python.org/moin/Python2orPython3

As of version 0.10, Flask runs with Python 3.3. When I asked Armin Ronacher about whether new Flask apps should begin using Python 3, he said they shouldn't:

到了版本0.10，Flask现在可以在Python 3.3上运行。就新的Flask应用是否需要使用Python 3的问题，我问过Armin Ronacher，他回答说，这不是必须的：

> I'm not using it myself currently, and I don't ever recommend to people things that I don't believe in myself, so I'm very cautious about recommending Python 3.
> 我自己现在并不用它，我也不会向别人推荐自己都不相信的东西，所以我不会推荐Python 3.

His main reason is that there are still things in Python 3 that don’t work yet. Another reason of his for not recommending that new projects use Python 3 is that many dependencies simply don't work with the new version yet. It's possible that eventually Flask will officially recommend Python 3 for new projects, but for now it’s all about Python 2.

他主要的理由在于Python 3并不足够完备。另一个理由是许多依赖并不兼容最新的Python版本。
也许总有一天Flask官方将推荐用Python 3开始新的项目，但是现在依然是Python 2的天下。

{ SEE ALSO:
* This site tracks which packages have been ported to Python 3: https://python3wos.appspot.com/ }

{ SEE ALSO:
* 这个网站记录了已经移植到Python 3的包: https://python3wos.appspot.com/ }

Since this book is meant to provide practical advice, I think it makes sense to write with the assumption of Python 2. Specifically, I'll be writing the book with Python 2.7 in mind. Future updates may very well change this to evolve with the Flask community, but for now 2.7 is where we stand.

既然本书需要提供实践上的建议，我将假定你正使用Python 2。
更准确地说，我将基于Python 2.7撰写本书。随着Flask社区的变迁，将来的更新会改变这一点，但是在当下，我们依然活在Python 2.7的世界里。

#### Flask 版本 0.10

At the time of writing this, 0.10 is the latest version of Flask (0.10.1 to be exact). Most of the lessons in this book aren’t going to change with minor updates to Flask, but it’s something to keep in mind nonetheless.

正当本书撰写之时，0.10是Flask的最新版本（准确说，是0.10.1版）。本书中大多数内容不会受到Flask的较小的变动的影响，但是你需要了解这一点。

## 年度审查

I’m hesitant to commit to any one update schedule, since there are a lot of variables that will determine the appropriate time for an update. Essentially, if it looks like things are getting out of date, I’ll work on releasing an update. Eventually I might stop, but I’ll make sure to announce that if it happens.

我不太能定下任何的更新计划，因为沧海桑田，世事难料。至少，当本书内容显得不合时宜，我将发布一个更新。
也许终有一日我将不再回首，不过到那时，我会写出公告。

## 本书用到的约定

### 各章独立成文

Each chapter in this book is an isolated lesson. Many books and tutorials are written as one long lesson. Generally this means that an example program or application is created and updated throughout the book to demonstrate concepts and lessons. Instead, examples are included in each lesson to demonstrate the concepts, but the examples from different chapters aren’t meant to be combined into one large project.

本书的每一章独立成文。许多书和教程通篇浑然一体。通常这意味着，一个示范程序或一个应用的创建和更新将贯穿全书来展示概念和主题。
本书的范例将散布于每一章节来展示概念，但不意味着这些范例可以组合成一个大的项目。

### 格式

Code blocks will be used to present example code.

示例代码将以代码块形式来呈现。

```
print “Hello world!”
```

Directory listings will sometimes be shown to give an overview of the structure of an application or directory.

目录列表有时会被用来展示一个应用或目录的大致结构。

```
static/
  style.css
  logo.png
  vendor/
    jquery.min.js
```

*Italic text* will be used to denote a file name.

*斜体*将用来表示文件名。

**Bold text** will be used to denote a new or important term.

**粗体**将用来表示新的或重要的内容。

Supplemental information may appear in one of several boxes:

补充信息将出现于下面的盒子中：

{ WARNING: Common pitfalls that could cause major problems may be shown in a warning box. }

{ WARNING: 这里会有容易掉进去的坑。}

{ NOTE: Tangential information may be presented in a "note" box. }

{ NOTE: 这里会有不怎么切题的信息。 }

{ SEE ALSO: I may provide some links with more information on a given topic in a "see also" box. }

{ SEE ALSO: 这里会有指向外部的相关链接。 }

## 总结

* This book contains recommendations for using Flask.
* I’m assuming that you’ve gone through the Flask tutorial.
* I’m using Python 2.7.
* I’m using Flask 0.10.
* I’ll do my best to keep the content of the book up-to-date with annual reviews.
* Each chapter in this book stands on its own.
* There are a few ways that I’ll use formatting to convey additional information about the content.
* Summaries will appear as concise lists of takeaways from the chapters.

* 本书包含了使用Flask的最佳实践。
* 我假定你通读了Flask教程
* 本书基于Python 2.7
* 本书基于Flask 0.10
* 通过年度审查，我尽量让本书的内容保持更新。
* 本书中每一章独立成文。
* 我通过一些约定来表达跟内容相关的附加信息。
* 每章的结尾都会出现对本章内容的总结。

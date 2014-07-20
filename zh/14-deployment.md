# 部署

You're finally ready to show your app to the world. It's time to deploy. This process can be a pain because there are so many moving parts. There are a lot of choices to make when it comes to your production stack as well. I'm going to try and point out the important pieces and some of the options you have with each.

最终，你终于可以向全世界展示你的应用了。是时候部署它了。这个过程总能让人感到受挫，因为有太多任务需要完成。同时在部署的过程中你需要做出太多艰难的决定。我会尝试指出一些关键的地方以及你的一些可能的选择。

## 托管主机

You're going to need a server somewhere. There are thousands of providers out there, but these are the three that I personally recommend. I'm not going to go over the details of how to get started with them, because that's out of the scope of this book. Instead I'll talk about their benefits with regards to hosting Flask applications.

首先，你需要一个服务器。世上服务器提供商成千，但我只取三家。我不会谈论如何开始使用它们的服务的细节，因为这超出本书的范围。相反，我只会谈论它们作为Flask应用托管商上的优点。

### Amazon Web Services EC2（因为国情问题，让我们直接看下一个吧）

Amazon Web Services is a collection of services provided by ... Amazon! There's a good chance that you've heard of them before as they are probably the most popular choice for new startups these days. The AWS service that we're most concerned with here is EC2, or Elastic Compute Cloud. The big selling point of EC2 is that you get virtual servers, or instances as they're called in AWS parlance, that spin up in seconds. If you need to scale your app quickly it's just a matter of spinning up a few more EC2 instances with your app running and sticking them behind a load balancer (you can even use the AWS Elastic Load Balancer).

Amazon Web Services指的是一套相关的服务，提供商是……~~卓越~~亚马逊！今日，许多著名的初创公司选择使用它，所以你或许已经听过它的大名。AWS服务中我们最关心的是EC2，全称是Elastic Compute Cloud。EC2的最大的卖点是你能够获得虚拟主机，或者说实例（这是AWS官方称呼），在仅仅几秒之内。如果你需要快速拓展你的应用，就只需启动多一点EC2实例给你的应用，并且用一个负载平衡器(load balancer)管理它们。（你可以试试AWS Elastic Load Balancer）

With regards to Flask, AWS is just a regular old virtual server. You can spin it up with your favorite linux distro and install your Flask app and your server stack without much overhead. It means that you're going to need a certain amount of systems administration knowledge though.

对于Flask而言，AWS就是一个常规的虚拟主机。付上一些费用，你可以用你喜欢的Linux发行版启动它，并安上你的Flask应用。之后你的服务器就起来了。不过它意味着你需要一些系统管理知识。

### Heroku

Heroku is an application hosting service that is built on top of AWS services like EC2. They let you take advantage of the convenience of EC2 without the requisite systems administration experience.

Heroku是一个应用托管网站，基于诸如EC2的AWS的服务。他们允许你获得EC2的便利，而无需系统管理经验。

With Heroku, you deploy your application with a `git push` to their server. This is really convenient when you don't want to spend you time SSHing into a server, installing and configuring software and coming up with a sane deployment procedure. This convenience comes at a price of course, though both AWS and Heroku offer a certain amount of free service.

对于Heroku，你通过`git push`来在它们的服务器上部署代码。这是非常便利的，如果你不想浪费时间ssh到服务器上，安装并配置软件，继续整个常规的部署流程。这种便利是需要花钱购买的，尽管AWS和Heroku都提供了一定量的免费服务。

{ SEE MORE: 

* Heroku has a tutorial on deploying Flask with their service: https://devcenter.heroku.com/articles/getting-started-with-python }


{ SEE MORE: 

* Heroku有一个如何在它们的服务器上部署Flask应用的教程： https://devcenter.heroku.com/articles/getting-started-with-python }

{ A NOTE ON DATABASES: Administrating your own databases can be time consuming and doing it well requires some experience. It's great to learn about database administration by doing it yourself for your side projects, but sometimes you'd like to save time and effort by outsourcing that to part professionals. Both Heroku and AWS have database management offerings. I don't have personal experience with either yet, but I've heard great things and it's worth considering if you want to make sure your data is being secured and backed-up without having to do it yourself.

- Heroku Postgres: https://www.heroku.com/postgres
- Amazon RDS: https://aws.amazon.com/rds/ }

{ A NOTE ON DATABASES: 管理你自己的数据库将会花上许多时间，而把它做好也需要一些经验。通过配置你自己的站点来学习数据库管理是好的，但有时候你会想要外包给专业团队来省下时间和精力。Heroku和AWS都提供有数据库管理服务。我个人还没试过，但听说它们不错。如果你想要保障数据安全以及备份，却又不想要自己动手，值得考虑一下它们。

- Heroku Postgres: https://www.heroku.com/postgres
- Amazon RDS: https://aws.amazon.com/rds/ }

### Digital Ocean

Digital Ocean is an EC2 competitor that has recently begun to take off. Like EC2, Digital Ocean lets you spin up virtual servers, now called droplets, quickly. All droplets run on SSDs, which isn't something you get at the lower levels of EC2. The biggest selling point for me is an interface that is far simpler and easier to use than the AWS control panel. Digital Ocean is my personal preference for hosting and I recommend that you take a look at them.

Digital Ocean是最近出现的EC2的竞争对手。一如EC2，Digital Ocean允许你快速地启动虚拟主机（在这里叫droplet）。所有的droplet都运行在SSD上，而在EC2，如果你不是用的高级服务，你是享受不到这种待遇的。对我而言，最大的卖点是它提供的控制接口比AWS控制面板简单和容易多了。Digital Ocean是我个人的最爱，我建议你考虑下它。

The Flask deployment experience on Digital Ocean is roughly the same as on EC2. You're starting with a clean linux distribution and installing your server stack from there.

在Digital Ocean，Flask应用部署方式就跟在EC2一样。你会得到一个全新的Linux发行版，然后需要安装你的全套软件。

## 安装软件

This section will cover some of the software that you'll need to install on your server to serve your Flask application to the world. The basic stack is a front server that reverse proxies requests to an application runner that is running your Flask app. You'll usually have a database too, so we'll talk a little about those options as well.

这一节将包括一些为了向别人提供服务，你需要安装在服务器上的软件。最基本的是一个前置服务器，用来反向代理请求给一个运行你的Flask应用的应用容器。你通常也需要一个数据库，所以我们也会略微谈论下这方面的内容。

### 应用容器

The server used to run Flask locally when you're developing your application isn't good at handling real requests. When you're actually serving your application to the public, you want to run it with an application runner like Gunicorn. Gunicorn handles requests and takes care of complicated things like threading.

在开发应用时，本地运行的那个服务器并不能处理真实的请求。当你真的需要向公众发布你的应用，你需要在类似Gunicorn的。。。上运行它。Gunicorn接待请求，并处理诸如线程的复杂事务。

To use Gunicorn, install the `gunicorn` package in your virtual environment with Pip. Running your app is a simple command away. For the sake of illustration, let's assume that this is our Flask app:

要想使用Gunicorn，需要通过pip安装`gunicorn`到你的虚拟环境中。运行你的应用只需简单的命令。为了简明起见，让我们假设这就是我们的Flask应用：

_rocket.py_
```
from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
	return "Hello World!"
```

A fine app indeed. Now, to serve it up with Gunicorn, we simply run this command:

哦，这真简明扼要。现在，使用Gunicorn来运行它吧，我们只需执行这个命令：

```
(myapp)$ gunicorn rocket:app
2014-03-19 16:28:54 [62924] [INFO] Starting gunicorn 18.0
2014-03-19 16:28:54 [62924] [INFO] Listening at: http://127.0.0.1:8000 (62924)
2014-03-19 16:28:54 [62924] [INFO] Using worker: sync
2014-03-19 16:28:54 [62927] [INFO] Booting worker with pid: 62927
```

You should see "Hello World!" at http://127.0.0.1:8000.

你应该能在 http://127.0.0.1:8000 看到“Hello World!”。

To run this server in the background (i.e. daemonize it), we can pass in the `-D` option to Gunicorn. That way it'll run even after you close your current terminal session. If you do that, you might have a hard time finding the process to close later on when you want to stop the server. We can tell Gunicorn to stick the process ID in a file so that we can stop or restart it later without searching through lists of running processess. We use the `-p <file>` option to do that. Altogther, our Gunicorn deployment command looks like this:

为了在后台运行这个服务器（也即使它变成守护进程），我们可以传递`-D`选项给Gunicorn。这下它会持续运行，即使你关闭了当前的终端会话。如果你这么做了，当你想要关闭服务器时就会困惑于到底应该关闭哪个进程。我们可以让Gunicorn把进程ID储存到文件中，这样如果想要停止或者重启服务器时，我们可以不用在一大串运行中的进程中搜索它。我们使用`-p <file>`选项来这么做。现在，我们的Gunicorn部署命令是这样：

```
(myapp)$ gunicorn rocket:app -p rocket.pid -D
(myapp)$ cat rocket.pid
63101
```

To restart and kill the server, we can run these commands respectively:

要想重新启动或者关闭服务器，我们可以运行对应的命令：

```
(myapp)$ kill -HUP `cat rocket.pid`
(myapp)$ kill `cat rocket.pid`
```

By default Gunicorn runs on port 8000. If that's taken by another application you can change the port by adding the `-b` bind option. It looks like this:

默认下Gunicorn会运行在8000端口。如果这已经被另外的应用占用了，你可以通过添加`-b`选项来指定端口。它看上去像这样：

```
(myapp)$ gunicorn rocket:app -p rocket.pid -b 127.0.0.1:7999 -D
```

#### 将Gunicorn摆上前台

{ WARNING: Gunicorn is meant to sit behind a reverse proxy. If you tell it to listen to requests coming in from the public, it makes an easy target for denial of service attacks. It is just not meant to handle those kinds of requests. Only allow outside connections for debugging purposes and make sure to switch it back to only allowing internal connections when you're done. }

{ WARNING: Gunicorn应该隐藏于反向代理之后。如果你直接让它监听来自外网的请求，它很容易成为拒绝服务攻击的目标。它不应该接受这样的考验。只有在debug的情况下你才能把Gunicorn摆上前台，而且完工之后，切记把它重新隐藏到幕后。 }

If you run Gunicorn like we have been on a server, you won't be able to access it from your local system. That's because by default Gunicorn binds to 127.0.0.1. This means that it will only listen to connections coming from the server itself. This is the behavior that you want when you have a reverse proxy server that is sitting between the public and your Gunicorn server. If, however, you need to make requests from outside of the server for debugging purposes, you can tell Gunicorn to bind to 0.0.0.0. This tells it to listen for all requests.

如果你像前面说的那样在服务器上运行Gunicorn，将不能从本地系统中访问到它。这是因为默认情况下Gunicorn绑定在127.0.0.1。这意味着它仅仅监听来自服务器自身的连接。所以通常使用一个反向代理来作为外网和Gunicorn服务器的中介。不过，假如为了debug，你需要直接从外网发送请求给Gunicorn，可以告诉Gunicorn绑定0.0.0.0。这样它就会监听所有请求。

```
(myapp)$ gunicorn rocket:app -p rocket.pid -b 0.0.0.0:8000 -D
```

{ SEE MORE:
- Read more about running and deploying Gunicorn from the docs: http://docs.gunicorn.org/en/latest/ 
- Fabric is a tool that lets you run all of these deployment and management commands from the comfort of your local machine without SSHing into every server: http://docs.fabfile.org/en/latest }

{ SEE MORE:
- 从文档中可以读到更多关于运行和部署Gunicorn的信息 : http://docs.gunicorn.org/en/latest/ 
- Fabric是一个可以允许你不通过SSH连接到每个服务器上就可以执行部署和管理命令的工具 : http://docs.fabfile.org/en/latest }

### Nginx Reverse Proxy
### Nginx反向代理

A reverse proxy handles public HTTP requests, sends them back to Gunicorn and gives the response back to the requesting client. Nginx can be used very effectively as a reverse proxy and Gunicorn "strongly advises" that we use it. To configure Nginx as a reverse proxy to Gunicorn running on 127.0.0.1:8000, we can create a file for our app in _/etc/nginx/sites-available_. We'll call it _exploreflask.com_.

反向代理处理公共的HTTP请求，发送给Gunicorn并将响应带回给发送请求的客户端。Nginx是一个优秀的客户端，何况Gunicorn强烈建议我们使用它。要想配置Nginx作为运行在127.0.0.1:8000的Gunicorn的反向代理，我们可以在*/etc/nginx/sites-available*下给应用创建一个文件。不如称之为*exploreflask.com*吧。

Here's a simple example configuration.

下面是一个关于配置的简单例子。

_/etc/nginx/sites-available/exploreflask.com_
```
# Redirect www.exploreflask.com to exploreflask.com
server {
        server_name www.exploreflask.com;
        rewrite ^ http://exploreflask.com/ permanent;
}

# Handle requests to exploreflask.com on port 80
server {
        listen 80;
        server_name exploreflask.com;

		# Handle all locations
        location / {
        		# Pass the request to Gunicorn
                proxy_pass http://127.0.0.1:8000;
                
                # Set some HTTP headers so that our app knows where the request really came from
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
}
```

Now create a symlink to this file in _/etc/nginx/sites-enabled_ and restart Nginx.

现在在*/etc/nginx/sites-enabled*下创建该文件的符号链接，接着重启Nginx。

```
$ sudo ln -s /etc/nginx/sites-available/exploreflask.com /etc/nginx/sites-enabled/exploreflask.com
```

You should now be able to make your requests to Nginx and receive the response from your app.

你现在应该可以发送请求给Nginx然后收到来自你的应用的响应。

{ SEE MORE:
- Nginx configuration section in the Gunicorn docs will give you more information about setting Nginx up for this purpose: http://docs.gunicorn.org/en/latest/deploy.html#nginx-configuration }
{ SEE MORE:
- Gunicorn文档中关于配置Nginx的部分会给你更多启动Nginx的信息: http://docs.gunicorn.org/en/latest/deploy.html#nginx-configuration }

#### ProxyFix

You main run into some issues with Flask not properly handling the proxied requests. It has to do with those headers we set in the Nginx configuration. We can use the Werkzeug ProxyFix to, ugh, fix the proxy.

有时，你会遇到Flask不能恰当处理转发的请求的情况。这也许是因为在Nginx中设置的某些HTTP报文头部造成的。我们可以使用Werkzeug的ProxyFix来fix转发请求。

_rocket.py_
```
from flask import Flask

# Import the fixer
from werkzeug.contrib.fixers import ProxyFix

app = Flask(__name__)

# Use the fixer
app.wsgi_app = ProxyFix(app.wsgi_app)

@app.route('/')
def index():
	return "Hello World!"
```

{ SEE MORE:
- Read more about ProxyFix in the Werkzeug docs: http://werkzeug.pocoo.org/docs/contrib/fixers/#werkzeug.contrib.fixers.ProxyFix }
{ SEE MORE:
- 在Werkzeug文档中可以读到更多关于ProxyFix的信息: http://werkzeug.pocoo.org/docs/contrib/fixers/#werkzeug.contrib.fixers.ProxyFix }

## 总结

* Three good choices for Flask application hosting are AWS EC2, Heroku and Digital Ocean.
* The basic deployment stack for a Flask application consists of the app, an application runner like Gunicorn and a reverse proxy like Nginx.
* Gunicorn should sit behind Nginx and listen in 127.0.0.1 (internal requests) not 0.0.0.0 (external requests).
* Use Werkzeug's ProxyFix to handle the appropriate proxy headers in your Flask application.

* 你可以把Flask应用托管到AWS EC2， Heroku和Digital Ocean。（译者注：建议托管到国内的云平台上）
* Flask应用的基本部署依赖包括一个应用容器（比如Gunicorn）和一个反向代理（比如Nginx）。
* Gunicorn应该退居Nginx幕后并监听127.0.0.1（内部请求）而非0.0.0.0（外部请求）
* 使用Werkzeug的ProxyFix来处理Flask应用遇到的特定的转发报文头部。

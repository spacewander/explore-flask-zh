# 开放REST API

## REST先行

REST is a pattern for making server-side resources available to client applications. The REST application pattern uses HTTP methods to perform operations on those resources. In this section we'll go over resources and methods.

REST是一种使得服务端资源可以被客户端应用获取的模式。REST应用使用HTTP方法来表示对资源的操作。在这一节我将解释什么是**资源**和**方法**。

### 资源

Resources are the things that users will be accessing. It's important to distinguish between a resource and a representation of that resource. The resource is the abstract concept of an object used by the application, e.g. a "user." When we're building an API, we will usually serve JSON representations of users (and other resources).

资源是允许用户获取的内容。分清资源和资源的表示方式是重要的。资源是应用所使用的对象的抽象表示，比如，一个“用户”。当我们建立一个API时，我们通常将使用JSON来代表用户（和其他资源）。

### 方法

HTTP methods, such as the familiar `GET` and `POST` methods are used to view and modify resources. We can perform an operation on a resource by calling a URL, such as `/api/user` with a method that signals our intentions. This is an outline of the basic methods we'll talk about in this section:

HTTP方法，比如人所皆知的`GET`和`POST`方法分别用来查看和修改资源。通过调用一个特定的URL，比如`/api/user`加一个表示我们的意图的方法，来实现对一个资源的操作。下面是我们将在本节讲到的基本方法的大纲：

{MAKE A TABLE}

url             HTTP Method  Operation
/api/v1.0/users      GET          获取全体用户的列表
/api/v1.0/users/:id  GET          获取id等于:id的用户
/api/v1.0/users      POST         新增一个用户并返回新用户的id的值
/api/v1.0/users/:id  PUT          用:id来更新用户的id
/api/v1.0/users/:id  DELETE       删除id等于:id的用户

There are other HTTP methods often used in RESTful APIs, but these are the key players. We can use this structure to back front-end frameworks like Backbone and Angular, or to make resources available to third-party developers.

在RESTful API中，还会用到其他的HTTP方法，但最主要是这几个。我们可以使用这个结构来跟诸如Backbone和Angular前端框架互动，或者向第三方开发者开放资源。

{ NOTE: You may have noticed the "v1.0" in those URLs. I'm including a version number in the URLs to account for backwards compatibility. If you decide to make API changes after developers have been working with the old API, you can just increment the version number for the new one and tell developers to update their applications to use the new API. There are a lot of different ways to handle versioning, but this is my preference. }

{ NOTE: 你可能注意到了URL中的"v1.0"。我通过在URL中加入一个版本号来实现向后兼容。在开发者正在使用旧版API时，如果你决定改变API，你仅需增加版本号并告知开发者更新他们的应用来使用新的API。有许多种不同的方法可以处理版本兼容的问题，不过这种是我的最爱。}

{ NOTE: I'm not going to get too concerned with keeping things "purely RESTful." Sometimes people get worked up about APIs not keeping with the REST philosophy. I'm not one of those people. }

{ NOTE: 我并不会坚持让一切都是“pure RESTful”。有些人会反感那些不是完全遵守REST教义的API。我不是他们中的一员。}

## Flask-RESTful

Flask-RESTful is a Flask extension developed at Twilio that makes defining REST APIs simple. It uses a feature of Flask called `MethodViews`. When a request is routed to a `MethodView` class, the HTTP method of that request is used to determine which class method will handle the request. The `MethodView` class could have a `get()` method as well as a `post()` method, for example. Flask-RESTful wraps `MethodView` and gives us tools to use it for building REST APIs.

Flask-RESTful是一个简化REST API的定义的Flask插件。它使用Flask的一个叫`MethodView`的特性。当一个请求被导向一个`MethodView`类时，该请求的HTTP方法将被用来决定哪个类方法将被调用来处理请求。举个例子，`MethodView()`类会有一个`get()`方法和`post()`方法。Flask-RESTful包装了`MethodView`并给我们利用它来建立REST API的工具。

{ SEE MORE:
* Flask-RESTful documentation: http://flask-restful.readthedocs.org/en/latest/index.html
* Flask documentation for `MethodView`: http://flask.pocoo.org/docs/views/ }

{ SEE MORE:
* Flask-RESTful文档： http://flask-restful.readthedocs.org/en/latest/index.html
* Flask文档中关于`MethodView`的部分： http://flask.pocoo.org/docs/views/ }

### 视图结构

Let's create a simple RESTful API that makes a `User` resource available.

让我们创建一个简单的RESTful API来让开放`User`资源。

```
from flask import Flask
from flask.ext import restful

app = Flask(__name__)
api = restful.Api(app)

class UserListAPI(restful.Resource):
	def get(self):
    	# 获取用户列表
        return users, 200

	def post(self):
    	# 新增一个用户，返回状态码“201 Created”
        return new_user, 201

class UserAPI(restful.Resource):
	def get(self, id):
    	# 获取用户
        return user, 200
    
    def put(self, id):
    	# 更新用户
        return updated_user, 200

	def delete(self, id):
    	# 删除用户，返回状态码“204 No Content”
        return '', 204

api.add_resource(UserListAPI, '/api/v1.0/users', endpoint='users')
api.add_resource(UserAPI, '/api/v1.0/users/<int:id>', endpoint='user')
```

I'll leave the implementation of each function as an exercise for the user, as it's a little out of the scope of this chapter. As you can see, it's trivial to define the methods that can be used to access your resources and how each type of request should be handled. We are also going to need to allow users to log in.

我会留下每个函数的实现作为练习，因为它略微超出了这一章的范围。如你所见，定义访问你的资源的方式和如何处理每种请求是十分容易的。我们也将需要处理用户登录的问题。

### 验证

We can keep things simple and use our old friend Flask-Login. Let's take a closer look at the `UserAPI` class.

我们可以简单起见，使用老朋友Flask-Login。让我们仔细看看`UserAPI`类。

```
class UserAPI(restful.Resource):
	def get(self, id):
    	# 获取用户
        return user, 200
    
    def put(self, id):
    	# 更新用户
        return updated_user, 200

	def delete(self, id):
    	# 删除用户，返回状态码“204 No Content”
        return '', 204
```

{ WARNING: ###AUTHORIZATION WARNING HERE### }

### CSRF防范

## 总结

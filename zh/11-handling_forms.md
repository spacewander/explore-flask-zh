# Handling forms
# 处理表单

The form is the basic element that lets users interact with your web application. Flask alone doesn't do anything to help you handle forms, but the Flask-WTF extension lets us use the popular WTForms package in our Flask applications. This package makes defining forms and handling submissions easy.

表单是允许用户跟你的web应用交互的基本元素。Flask自己不会帮你处理表单，但Flask-WTF插件允许用户在Flask应用中使用脍炙人口的WTForms包。这个包使得定义表单和处理表单功能变得轻松。

## Flask-WTF

The first thing you want to do with Flask-WTF (after installing it) is to define a form in a `myapp.forms` package.

你首要做的事（当然是在安装Flask-WTF之后），就是在`myapp.forms`包下定义一个表单类（form）。

_myapp/forms.py_
```
from flask.ext.wtforms import Form
from wtforms import TextField, PasswordField, Required, Email

class EmailPasswordForm(Form):
    email = TextField('Email', validators=[Required(), Email()])
    password = PasswordField('Password', validators=[Required()])
```

{ NOTE: Until version 0.9, Flask-WTF provided its own wrappers around the WTForms fields and validators. You may see a lot of code out in the wild that imports `TextField`, `PasswordField`, etc. from `flask.ext.wtforms` instead of `wtforms`. You should be importing that stuff straight from `wtforms`. }

{ NOTE: 直到0.9版，Flask-WTF为WTForms的fields和validators提供自己的包装。你可能见过许多代码直接从`flask.ext.wtforms`而不是`wtforms`中直接导入`TextField`，`PasswordField`等等。你应该直接从`wtforms`中导入它们。}

This form is going to be a user sign-in form. We could have called it `SignInForm()`, but by keeping things a little more abstract, we can re-use this same form class for other things, like a sign-up form. If we were to define purpose-specific form classes we'd end up with a lot of identical forms for no good reason. It's much cleaner to name forms based on the fields they contain, as that is what makes them unique. Of course, sometimes you'll have long, one-off forms that you might want to give a more context-specific name.

这个表单将用于用户注册表单。我们可以称之为`SignInForm()`，但是通过保持抽象，我们可以在别的地方重用它，比如作为登录表单。如果我们针对特定功能定义表单，最终就会得到许多相似却无法重用的表单。基于表单中包含的域 - 那些使得表单与众不同的元素 -进行命名，显然会清晰很多。当然，有时候你会有复杂的，只在一个地方用到的表单，你再给它起个独一无二的名字也不迟。

This form can do a few of things for us. It can secure our app against CSRF vulnerabilites, validate user input and render the appropriate markup for whatever fields we define here.

这个表单可以帮我们做一些事情。它可以保护我们的应用免遭CSRF伤害，验证用户输入，为我们定义的域渲染适当的标记。

### CSRF Protection and validation
### CSRF保护和验证

CSRF stands for cross site request forgery. CSRF attacks involve a third party forging a form submission by posting data to an app's server. A vulnerable server assumes that the data is coming from a form on its own site and takes action accordingly.

CSRF全称是cross site request forgery，跨站请求伪造。CSRF通过第三方伪造表单数据，post到应用服务器上。受害服务器以为这些数据来自于它自己的网站，于是大意地中招了。

As an example, let's say that your email provider lets you delete your account by submitting a form. The form sends a POST request to an `account_delete` endpoint on their server and deletes the account that was logged-in when the form was submitted. You can create a form on your own site that sends a POST request to the same `account_delete` endpoint. Now, if you can get someone to click 'submit' on your form (or do it via JavaScript when they load your page) their logged-in account with the email provider will be deleted. Unless of course your email provider knows not to assume that form submissions are coming from their own forms.

举个例子，假设你的邮件服务商允许你通过提交一个表单来注销账户。这个表单发送一个POST请求到他们服务器的`account_delete`页面，并且用户已经登录，就可以注销账户。你可以在你自己的网站中创建一个会发送到同一个`account_delete`页面的表单。现在，假如有个倒霉蛋点击了你的表单的'submit'（或者在他们加载你的页面的时候通过Javascript做到这一点），同时他们又登录了邮件账号，那么他们的账户就会被注销。除非你的邮件服务商发现提交过来的请求不是来自于自己的表单的。

So how do we stop assuming that POST requests come from our own forms? WTForms makes it possible by generating a unique token when rendering each form. That token is then passed along with the form data in the POST request and must be validated before the form is accepted. The key is that the token is tied to a value stored in the user's session (cookies) and expires after a certain amount of time (30 minutes by default). This way the only person who can submit a valid form is the person who loaded the page (or at least someone at the same computer), and they can only do it for 30 minutes after loading the page.

所以我们怎样判断一个POST请求是否来自我们自己的表单呢？WTForms在渲染每个表单时生成一个独一无二飞token，使得这一切变得可能。那个token将在POST请求中随表单数据一起传递，并且会在表单被接受之前进行验证。关键在于token的值取决于储存在用户的会话（cookies）中的一个值，而且会在一定时间之后过时（默认30分钟）。这样只有登录了页面的人（或至少是在那个设备之后的人）才能提交一个有效的表单，而且仅仅是在登录页面30分钟之内才能这么做。

{ SEE ALSO:

* Here's the documentation on how WTForms generates these tokens: http://wtforms.simplecodes.com/docs/1.0.1/ext.html#module-wtforms.ext.csrf.session 

* Here's some more information about CSRF: https://www.owasp.org/index.php/CSRF }

{ SEE ALSO:

* 这里是关于WTForms是怎么生成token的文档: http://wtforms.simplecodes.com/docs/1.0.1/ext.html#module-wtforms.ext.csrf.session 

* 这里有关于CSRF更多的信息: https://www.owasp.org/index.php/CSRF }

To start using Flask-WTF for CSRF protection, we'll need to define a view for our login page.

为了开始使用Flask-WTF做CSRF防护，我们得先给我们的登录页定义一个视图。

myapp/views.py
```
from flask import render_template, redirect, url_for

from . import app
from .forms import EmailPasswordForm

@app.route('/login', methods=["GET", "POST"])
def login():
    form = EmailPasswordForm()
    if form.validate_on_submit():
    
        # Check the password and log the user in
        # [...]
        
        return redirect(url_for('index'))
    return render_template('login.html', form=form)
```

We import our form from our `forms` package and instantiate it in the view. Then we run `form.validate_on_submit()`. This function returns `True` if the form has been both submitted (i.e. if the HTTP method is PUT or POST) and validated by the validators we defined in _forms.py_.

我们从`forms`包中导入form对象，并于视图内实例化。然后运行`form.validate_on_submit()`。如果表单已经submit了（比如通过HTTP方法PUT或POST），这个函数返回`True`并且用定义在*forms.py*中的验证函数来验证表单。

{ SEE ALSO: The documentation and source for validate_on_submit():
* http://pythonhosted.org/Flask-WTF/#flask.ext.wtf.Form.validate_on_submit
* https://github.com/ajford/flask-wtf/blob/v0.8.4/flask_wtf/form.py#L120 }

{ SEE ALSO: validate_on_submit()的文档和源码在此：
* http://pythonhosted.org/Flask-WTF/#flask.ext.wtf.Form.validate_on_submit
* https://github.com/ajford/flask-wtf/blob/v0.8.4/flask_wtf/form.py#L120 }

If the form has been submitted and is valid, we can continue with the login logic. If it hasn't been submitted (i.e. it's just a GET request), we want to pass the form object to our template so it can be rendered. Here's what the template looks like when we use CSRF protection.

如果一个form已经submit并且有效，我们可以开始处理登录逻辑的部分了。如果它还没有submit（比如，它只是一个GET请求），我们需要传递这个form对象给模板渲染。下面展示如何在模板中使用CSRF防护。

myapp/templates/login.html
```
{% extends "layout.html" %}
<html>
    <head>
        <title>Login Page</title>
    </head>
    <body>
        <form action="{{ url_for('login') }}" method="POST">
            <input type="text" name="email" />
            <input type="password" name="password" />
            {{ form.csrf_token }}
        </form>
    </body>
</html>
```

`{{ form.csrf_token }}` renders a hidden field containing one of those fancy CSRF tokens and WTForms looks for that field when it validates the form. We don't have to worry about including any special "is the token valid" logic. Hooray!

`{{ form.csrf_token }}`将渲染一个隐藏的包括防范CSRF的特殊token的域，而WTForms会在验证表单时查找这个与。我们不用操心添加任何特殊的验证token正确性的逻辑。万岁！

#### Protecting AJAX calls with CSRF tokens
#### 使用CSRFtoken来保护AJAX调用

Flask-WTF CSRF tokens aren't limited to protecting form submissions. If your app makes other requests that might be forged (especially AJAX calls) you can add CSRF protection there too! Check out the Flask-WTF documentation for the details: https://flask-wtf.readthedocs.org/en/latest/csrf.html#ajax

Flask-WTF的CSRF token不仅限于保护表单提交。如果你的应用需要接受其他可能被伪造的请求（特别是AJAX调用），你也可以给它们添加CSRF保护！想了解更多信息，请查看Flask-WTF的文档：https://flask-wtf.readthedocs.org/en/latest/csrf.html#ajax

### Custom validators
### 自定义验证函数

In addition to the built-in form validators provided by WTForms (e.g. `Required()`, `Email()`, etc.), you can create your own validators. I'll demonstrate this by making a `Unique()` validator that will check the database and make sure that the value provided by the user doesn't already exist. This could be used to make sure that a username or email address isn't already in use. Without WTForms, we'd probably be doing these checks in the view, but now we can abstract that away to the form itself.

Lets start by defining a simple sign-up form.

_myapp/forms.py_
```
from flask.ext.wtforms import Form
from wtforms import TextField, PasswordField, Required, Email

class EmailPasswordForm(Form):
    email = TextField('Email', validators=[Required(), Email()])
    password = PasswordField('Password', validators=[Required()])
```

Now we want to add a validator to make sure that email they provide isn't already in the database. We'll put the validator in a new `util` module, `util.validators`.

_myapp/util/validators.py_
```
from wtforms.validators import ValidationError

class Unique(object):
    def __init__(self, model, field, message=u'This element already exists.'):
        self.model = model
        self.field = field

    def __call__(self, form, field):
        check = self.model.query.filter(self.field == field.data).first()
        if check:
            raise ValidationError(self.message)
```

This validator assumes that you're using SQLAlchemy to define your models. WTForms expects validators to return some sort of callable (e.g. a callable class).

In *__init__.py* we can specify which arguments should be passed to the validator. In this case we want the relevant model (e.g. the `User` model in our case) and the field to check. When the validator is called, it will raise a `ValidationError` if any instance of the defined model matches the value submitted in the form. We've also made it possible to add a message with a generic default that will be included in the `ValidationError`.

Now we can modify `EmailPasswordForm` to use the `Unique` validator.

_myapp/forms.py_
```
from flask.ext.wtforms import Form
from wtforms import TextField, PasswordField, Required, Email

from .util.validators import Unique
from .models import User

class EmailPasswordForm(Form):
    email = TextField('Email', validators=[Required(), Email(), Unique(User, User.email, message='There is already an account with that email.'])
    password = PasswordField('Password', validators=[Required()])
```

{ NOTE: Your validator doesn't have to be a callable class. It could also be a factory that returns a callable or just a callable directly. See some examples here: http://wtforms.simplecodes.com/docs/0.6.2/validators.html#custom-validators }

### Rendering forms

WTForms can also help us render the HTML for the forms. The `Field` class implemented by WTForms renders an HTML representation of that field, so we just have to call the form fields to render them in our template. It's just like render the `csrf_token` field. Here's how the login template looks when we use WTForms to render our other fields too.

myapp/templates/login.html
```
{% extends "layout.html" %}
<html>
    <head>
        <title>Login Page</title>
    </head>
    <body>
        <form action="" method="POST">
            {{ form.email }}
            {{ form.password }}
            {{ form.csrf_token }}
        </form>
    </body>
</html>
```

We can customize how the fields are rendered by passing field properties as arguments to the field call. Here we add a `placeholder=` property to the email field:

```
<form action="" method="POST">
    {{ form.email.label }}: {{ form.email(placeholder='yourname@email.com') }}<br>
    {{ form.password.label }}: {{ form.password }}<br>
    {{ form.csrf_token }}
</form>
```

{ NOTE: If we want to pass the "class" HTML attribute, we have to use `class_=''` since "class" is a reserved keyword in Python. }

{ SEE ALSO: The documented list of available field properties: http://wtforms.simplecodes.com/docs/1.0.4/fields.html#wtforms.fields.Field.name}

{ NOTE: You may notice that we don't need to use Jinja's |safe filter. This is because WTForms renders HTML safe strings. See more here: http://pythonhosted.org/Flask-WTF/#using-the-safe-filter }

## Summary

* Forms can be scary from a security perspective.
* WTForms (and Flask-WTF) make it easy to define, secure and render your forms.
* Use the CSRF protection provided by Flask-WTF to secure your forms.
* You can use these Flask-WTF to protect AJAX calls against CSRF attacks too.
* Define custom form validators to keep validation logic out of your views.
* Use the WTForms field rendering to render your form's HTML so you don't have to update it every time you make some changes to the form definition.

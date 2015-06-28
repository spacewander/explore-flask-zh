![处理表单](images/forms.png)

# 处理表单

表单是允许用户跟你的web应用交互的基本元素。Flask自己不会帮你处理表单，但Flask-WTF插件允许用户在Flask应用中使用脍炙人口的WTForms包。这个包使得定义表单和处理表单功能变得轻松。

## Flask-WTF

你首要做的事（当然是在安装Flask-WTF之后），就是在`myapp.forms`包下定义一个表单类（form）。

_myapp/forms.py_
```python
from flask_wtf import Form
from wtforms import StringField, PasswordField
from wtforms.validators import DataRequired, Email

class EmailPasswordForm(Form):
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
```

> **注意**
> 直到0.9版，Flask-WTF为WTForms的fields和validators提供自己的包装。你可能见过许多代码直接从`flask.ext.wtforms`而不是`wtforms`中直接导入`TextField`，`PasswordField`等等。
> 而从0.9版之后，我们得直接从`wtforms`中导入它们。

这个表单将用于用户注册表单。我们可以称之为`SignInForm()`，但是通过保持抽象，我们可以在别的地方重用它，比如作为登录表单。如果我们针对特定功能定义表单，最终就会得到许多相似却无法重用的表单。基于表单中包含的域 - 那些使得表单与众不同的元素 - 进行命名，显然会清晰很多。当然，有时候你会有复杂的，只在一个地方用到的表单，你再给它起个独一无二的名字也不迟。

这个表单可以帮我们做一些事情。它可以保护我们的应用免遭CSRF伤害，验证用户输入，为我们定义的域渲染适当的标记。

### CSRF保护和验证

CSRF全称是cross site request forgery，跨站请求伪造。CSRF通过第三方伪造表单数据，post到应用服务器上。受害服务器以为这些数据来自于它自己的网站，于是大意地中招了。

举个例子，假设你的邮件服务商允许你通过提交一个表单来注销账户。这个表单发送一个POST请求到他们服务器的`account_delete`页面，并且用户已经登录，就可以注销账户。你可以在你自己的网站中创建一个会发送到同一个`account_delete`页面的表单。现在，假如有个倒霉蛋点击了你的表单的'submit'（或者在他们加载你的页面的时候通过Javascript做到这一点），同时他们又登录了邮件账号，那么他们的账户就会被注销。除非你的邮件服务商知道不能假定提交过来的请求都是来自于自己的页面。

所以我们怎样判断一个POST请求是否来自我们自己的表单呢？WTForms在渲染每个表单时生成一个独一无二的token，使得这一切变得可能。那个token将在POST请求中随表单数据一起传递，并且会在表单被接受之前进行验证。关键在于token的值取决于储存在用户的会话（cookies）中的一个值，而且会在一定时间之后过时（默认30分钟）。这样只有登录了页面的人（或至少是在那个设备之后的人）才能提交一个有效的表单，而且仅仅是在登录页面30分钟之内才能这么做。

> **参见**
> * 这里是关于WTForms是怎么生成token的文档: http://wtforms.simplecodes.com/docs/1.0.1/ext.html#module-wtforms.ext.csrf.session

> * 这里有关于CSRF更多的信息: https://www.owasp.org/index.php/CSRF

为了开始使用Flask-WTF做CSRF防护，我们得先给我们的登录页定义一个视图。

myapp/views.py
```python
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

我们从`forms`包中导入form对象，并于视图内实例化。然后运行`form.validate_on_submit()`。如果表单已经submit了（比如通过HTTP方法PUT或POST），这个函数返回`True`并且用定义在*forms.py*中的验证函数来验证表单。

> **参见**
> `validate_on_submit()`的文档和源码在此：
> * http://pythonhosted.org/Flask-WTF/#flask.ext.wtf.Form.validate_on_submit
> * https://github.com/ajford/flask-wtf/blob/v0.8.4/flask_wtf/form.py#L120

如果一个表单已经提交并且通过验证，我们可以开始处理登录逻辑的部分了。如果它还没有提交（比如，它只是一个GET请求），我们需要传递这个表单对象给模板来进行渲染。下面展示如何在模板中使用CSRF防护。

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

`{{ form.csrf_token }}`将渲染一个隐藏的包括防范CSRF的特殊token的域，而WTForms会在验证表单时查找这个域。我们不用操心添加的任何特殊的验证token正确性的逻辑。万岁！

#### 使用CSRFtoken来保护AJAX调用

Flask-WTF的CSRF token不仅限于保护表单提交。如果你的应用需要接受其他可能被伪造的请求（特别是AJAX调用），你也可以给它们添加CSRF保护！想了解更多信息，请查看Flask-WTF的文档：https://flask-wtf.readthedocs.org/en/latest/csrf.html#ajax

### 自定义验证函数

除了WTForms提供的内置表单验证函数（比如`Required()`，`Email()`等等），你可以创建自己的验证函数。通过创建一个可用于检查数据库并确保用户提供的值未曾存在的`Unique()`验证函数，我将展示这一点。这个函数可以确保一个用户名或邮件地址未被使用。如果没有WTForms，我们不得不在视图中完成这些检查，但现在我们可以抽象出来作为form类的一部分。

_myapp/forms.py_
```python
from flask_wtf import Form
from wtforms import StringField, PasswordField,
from wtforms.validators import DataRequired, Email

class EmailPasswordForm(Form):
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
```

现在我们想要添加一个验证函数来确认提供的邮件地址未曾出现在数据库中。我们将把验证函数放在一个新的`util`模块里，即`util.validators`。

_myapp/util/validators.py_
```
from wtforms.validators import ValidationError

class Unique(object):
    def __init__(self, model, field, message=u'该内容已经存在。'):
        self.model = model
        self.field = field

    def __call__(self, form, field):
        check = self.model.query.filter(self.field == field.data).first()
        if check:
            raise ValidationError(self.message)
```

这个验证函数假定你是用SQLAlchemy来定义你的模型。WTForms要求验证函数返回可调用的(callable)类型（比如一个可调用的类）。

在*\_\_init\_\_.py*中，我们可以指定哪些参数应该传递给验证函数。在这个例子中我们需要检查相关的模型（比如`User`模型）和域。当验证函数被调用时，如果表单提交的值跟定义的模型的某个实例重复了，它会抛出一个`ValidationError`。我们也提供一个带默认值的信息参数，作为`ValidationError`的一部分。

现在我们给`EmailPasswordForm`添加`Unique`验证器。

_myapp/forms.py_
```
from flask_wtf import Form
from wtforms import StringField, PasswordField,
from wtforms.validators import DataRequired, Email

from .util.validators import Unique
from .models import User

class EmailPasswordForm(Form):
    email = StringField('Email', validators=[DataRequired(), Email(), Unique(User, User.email, message='该邮箱已被用于注册'])
    password = PasswordField('Password', validators=[DataRequired()])
```

> **注意**
> 你的验证函数不一定需要是可调用的类。它也可以是一个返回可调用对象的工厂类或者可调用对象。看这里的一些例子：
> http://wtforms.simplecodes.com/docs/0.6.2/validators.html#custom-validators

### 渲染表单

WTForms也可以帮助我们给我们只需要表单渲染HTML。WTForms实现的`Field`类能根据域的形式渲染对应的HTML，所以我们只需要在模板中调用它们。就像是渲染`csrf_token`域一样。下面是当我们使用WTForms来渲染我们的其他域时，login模板大概的样子。

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

通过传递域的性质(properties)作为调用域的参数，我们可以自定义域的渲染形式。下面我们添加一个`placeholder=`性质给email域：

```
<form action="" method="POST">
    {{ form.email.label }}: {{ form.email(placeholder='yourname@email.com') }}<br>
    {{ form.password.label }}: {{ form.password }}<br>
    {{ form.csrf_token }}
</form>
```

> **注意**
> 如果我们想要传递HTML属性“class”， 我们得使用`class_=''`，因为“class”是Python的保留关键字。

> **参见**
> 这个文档列出了所有可用的域性质：
> http://wtforms.simplecodes.com/docs/1.0.4/fields.html#wtforms.fields.Field.name

> **注意**
> 你大概注意到了我们不需要使用Jinja的`|safe`过滤器。这是因为WTForms自己会处理掉HTML转义的问题。在这里了解更多信息：
> http://pythonhosted.org/Flask-WTF/#using-the-safe-filter

## 总结

* 表单可能会是安全上的阿喀琉斯之踵。
* WTForms（以及Flask-WTF）使得定义，保护和渲染你的表单更加轻松。
* 使用Flask-WTF提供的CSRF防范来保护你的表单。
* 你也可以使用Flask-WTF来防止AJAX调用遭到CSRF攻击。
* 定义自定义的表单验证函数，避免在视图函数中写入验证逻辑。
* 使用WTForms的域渲染功能来渲染你的表单的HTML，这样每次修改表单的定义时，你不需要更新模板。

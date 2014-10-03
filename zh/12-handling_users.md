![用户管理的规范](images/users.png)

# 用户管理的规范

One of the most common things that modern web applications need to do is handle users. An application with basic account features needs to handle a lot of things like registration, email confirmation, securely storing passwords, secure password reset, authentication and more. Since a lot of security issues present themselves when it comes to handling users, it's generally best to stick to standard patterns in this area.

用户管理是现代Web应用都需要做的事情之一。一个仅有基本的账户功能的应用也需要处理一大堆诸如注册，邮件确认，安全地存储密码，重置密码，用户验证以及更多。考虑到许多安全问题都出现在管理用户时，在这个领域最好遵循普遍的规范。

{ NOTE: In this chapter I'm going to assume that you're using SQLAlchemy models and WTForms to handle your form input. If you aren't using those, you'll need to adapt these patterns to your preferred methods.}

{ NOTE: 在本章中我会假定你已经在用SQLAlchemy模型和WTForms来处理你的表单输入。如果你不使用它们，你需要修改这些规范来适应你喜欢的方法。}

## 邮件确认

When a new user gives you their email, you generally want to confirm that they gave you the right one. Once you have made that confirmation, you can confidently send password reset links and other sensitive information to your users without wondering who is on the receiving end.

当一个新用户给你他们的邮件地址，你通常需要确认该地址是否是正确的。一旦你完成了验证，你就可以安心地发送密码重置链接和其他敏感信息给该邮箱，不用担心位于接收端的会是谁。

One of the most common patterns for confirming emails is to send a password reset link with a unique URL that, when visited, confirms that user's email address. For example, john@gmail.com signs up at your application. Your application registers him in the database with an `email_confirmed` column set to `False` and fires off an email to john@gmail.com with a unique URL. This URL usually contains a unique token, e.g. http://myapp.com/accounts/confirm/kj3kjhj3hj3. When John gets that email, he clicks the link. Your app sees the token, knows which email to confirm and sets John's `email_confirmed` column to `True`.

邮件确认的一个通常的规范是发送一个当前独一无二的URL密码重置链接，来确认用户的电子邮件地址。举个例子，john@gmail.com注册了你的应用。你的应用把他登记在数据库中，设置`email_confirmed`列为`False`并发送一封带特定URL的邮件给john@gmail.com。这个URL通常包括一个独一无二的token，比如<http://myapp.com/accounts/confirm/kj3kjhj3hj3>。当John收到那封邮件时，他点击链接。你的应用看到了token，知道是哪封邮件并设置John的`email_confirmed`列为`True`。

How do we know which email to confirm with a given token? One way would be to store the token in the database when it is created and check the database when we receive the confirmation request. That's a lot of overhead and, lucky for us, it's unnecessary.

那我们怎么知道给定的token对应的是哪封邮件？一个方法是在创建token时把它存储到数据库中，在我们收到一个确认请求时检索数据库来找到那个token。这需要做很多事情，而幸运的是，我们不必这么做。

We're going to create a token that actually includes the email address. It'll also contain a timestamp to let us set a time limit on how long the token is valid. To do this, we'll use the `itsdangerous` package. This package gives us tools to send sensitive data into untrusted environments (like sending an email confirmation token to an unconfirmed email). In this case, we're going to use a `URLSafeTimedSerializer`.

我们将创建一个包括了邮件地址的token。它还包括一个时间戳，表示这个token的有效期。为了做到这一点，我们要使用`itsdangerous`包。这个包提供了在无法信赖的环境中发送敏感信息的工具。（比如发送邮件确认token给未验证的邮件地址）。在这个例子里，我们将使用`URLSafeTimedSerializer`。

_myapp/util/security.py_
```
from itsdangerous import URLSafeTimedSerializer

from .. import app

ts = URLSafeTimedSerializer(app.config["SECRET_KEY"])
```

Now we can use that serializer to generate a confirmation token when a user gives us their email address. We'll implement a simple account creation process using this method.

现在当用户给我们邮件地址时，我们可以使用这个序列器来生成验证token。通过这种方式，我们来实现一个简单的账户注册流程。

_myapp/views.py_
```
from flask import redirect, render_template, url_for

from . import app, db
from .forms import EmailPasswordForm
from .util import ts, send_email

@app.route('/accounts/create', methods=["GET", "POST"])
def create_account():
    form = EmailPasswordForm()
    if form.validate_on_submit():
        user = User(
            email = form.email.data,
            password = form.password.data
        )
        db.session.add(user)
        db.session.commit()

        # Now we'll send the email confirmation link
        subject = "Confirm your email"

        token = ts.dumps(self.email, salt='email-confirm-key')

        confirm_url = url_for(
            'confirm_email',
            token=token,
            _external=True)

        html = render_template(
            'email/activate.html',
            confirm_url=confirm_url)

		# We'll assume that send_email has been defined in myapp/util.py
        send_email(user.email, subject, html)

        return redirect(url_for("index"))

    return render_template("accounts/create.html", form=form)
```

This handles the creation of the user and sends off an email to the given email address. You may notice that we're using a template to generate the HTML for the email. We can take a look at an example email template.

这段代码实现了创建用户并发送邮件到给定的邮件地址。你可能注意到了，我们使用一个模板来给电子邮件生成HTML。我们来看看这个电子邮件模板的例子。

_myapp/templates/email/activate.html_
```
你的账户已经成功创建<br>
请点击打开以下链接来激活你的邮箱：

<p>
<a href="{{ confirm_url }}">{{ confirm_url }}</a>
</p>

<p>
--<br>
如果对本邮件有疑问或者有话想说，发邮件给hello@myapp.com.
</p>
```

Okay, so now we just need to implement a view that handles the confirmation link in that email.

OK，所以现在我们只需要实现一个处理那个邮件中的验证链接的视图。

_myapp/views.py_
```
@app.route('/confirm/<token>')
def confirm_email(token):
    try:
        email = ts.loads(token, salt="email-confirm-key", max_age=86400)
    except:
        abort(404)

    user = User.query.filter_by(email=email).first_or_404()

    user.email_confirmed = True

    db.session.add(user)
    db.session.commit()

    return redirect(url_for('signin'))
```

This view is a simple form view. We just add the `try ... except` bit at the beginning to check that the token is valid. The token contains a timestamp, so we can tell `ts.loads()` to raise an exception if it is older than `max_age`. In this case, we're setting `max_age` to 86400 seconds, i.e. 24 hours.

这个视图只是一个简单的表单视图。我们仅仅在开头添加了`try ... except`来检查这个token是否有效。这个token包括一个时间戳，所以我们可以调用`ts.loads()`，如果它比`max_age`还大，就抛出一个异常。在这个例子，我们设置`max_age`为86400秒，也即24小时。

{ NOTE: You can use very similar methods to implement an email reset feature. Just send a confirmation link to the new email address with a token that contains both the old and the new addresses. If the token is valid, update the old address with the new one. }

{ NOTE: 你可以用差不多的方法实现一个邮件重置的功能。仅需要发送带旧邮件地址和新地址的token的验证链接到新的邮件地址。如果token是有效的，用新的地址更新旧地址。 }

## 存储密码

Rule number one of handling users is to hash passwords with the Bcrypt algorithm before storing them. You never store passwords in plain text. It's a massive security issue and it's unfair to your users. All of the hard work has already been done and abstracted away for us, so there's no excuse for not following the best practices here.

用户管理的第一条军规是在存储它们之前使用Bcrypt算法hash密码。你绝不可明文存储密码。这会是严重的安全问题并且它损害了你的用户。所有的繁重工作都已经有第三方的包来完成，所以没有任何不遵循这个最佳实践的理由。

{ SEE MORE: OWASP is one of the industry's most trusted source for information regarding web application security. Take a look at some of their recommendations for secure coding here: https://www.owasp.org/index.php/Secure_Coding_Cheat_Sheet#Password_Storage }

{ SEE MORE: OWASP是业界最值得信赖的关于Web应用安全的信息来源之一。看一下他们推荐的一些安全编程规范： https://www.owasp.org/index.php/Secure_Coding_Cheat_Sheet#Password_Storage }

We'll go ahead and use the Flask-Bcrypt extension to implement the bcrypt package in our application. This extension is basically just a wrapper around the `py-bcrypt` package, but it does handle a few things that would be annoying to do ourselves (like checking string encodings before comparing hashes).

我们将继续前进，使用Flask-Bcrypt插件来实现应用中的bcrypt包。这个插件只是基于`py-bcypt`包的包装，但是它帮我们处理了一些琐碎的事（比如在比较hash结果之前检查字符串编码）。

myapp/__init__.py
```
from flask.ext.bcrypt import Bcrypt

bcrypt = Bcrypt(app)
```

One of the reasons that the Bcrypt algorithm is so highly recommended is that it is "future adaptable." This means that over time, as computing power becomes cheaper we can make it more and more difficult to brute force the hash by guessing millions of possible passwords. The more "rounds" we use to hash the password, the longer it will take to perform one iteration of a guess. If we hash our passwords 20 times with the algorithm before storing them the attacker has to hash each of their guesses 20 times.

Bcrypt算法之所以深受欢迎，其中一个原因是它的“未来拓展性”。这意味着随着时间的迁移，当计算能力越来越廉价时，我们可以让它越来越难通过暴力算法来测试成百上千万密码组合来破解。我们用于hash密码的"rounds"越多，花费在完成一次测试的时间就越长。如果在存储密码前，我们把它hash了20次，骇客也不得不hash他们的每次猜测20次。

Keep in mind that if we're hashing our passwords 20 times then our application is going to take a long time to return a response that depends on that process completing. This means that when choosing the number of rounds to use, we have to balance security and usability. The number of rounds you can complete in a given amount of time will depend on the computational resources available to your application, so it's best to test out some different numbers and shoot for between 0.25 and 0.5 seconds to hash a password. Try to use at least 12 rounds though.

记住如果我们hash密码20次，需要等到计算结束之后，我们的应用才会做出响应。这意味着，在选择计算的次数时，我们要取得安全性和可用性的一个平衡点。在给定时间内你能计算的次数取决于你拥有的计算资源，所以最好测试不同的数字，找到能在0.25到0.5秒间完成一个密码的hash的值。至少，先从12次（12 rounds）开始尝试吧。

To test the time it takes to hash a password, you can time a quick Python script that, well, hashes a password.

要想测试hash一个密码的时间，你可以`time`一个简单的，用于hash一个密码的Python脚本看看。

_benchmark.py_
```
from flask.ext.bcrypt import generate_password_hash

# 改变round的次数（第二个参数），直到运行时间在0.25到0.5之间。
generate_password_hash('password1', 12) 
```

Now we can keep timing our changes with the UNIX `time` utility.

现在我们可以用`time`命令测几次看看。

```
$ time python test.py 

real    0m0.496s
user    0m0.464s
sys     0m0.024s
```

I did a quick benchmark on a small server that I have handy and 12 rounds seemed to take the right amount of time, so I'll configure our example to use that. 

我曾在一个小的服务器做过快速的基准测试，发现12 rounds正好能花费恰当的时间，所以我在这个例子中这么配置。

config.py
```
BCRYPT_LOG_ROUNDS = 12
```

Now that Flask-Bcrypt is configured, it's time to start hashing passwords. We could do this manually in the view function that receives the sign-up form, but we would have to repeat that code in the password reset and password change views. Instead, what we'll do is abstract away the hashing so that our app does it without us even thinking about it. We'll use a **setter** so that when we set `user.password = 'password1'`, it is automatically hashed with BCrypt before being stored.

既然Flask-Bcrypt已经配置完毕了，是时候开始hash密码。我们本可以在接受注册表单的视图函数中手工完成，但是将来在密码重置和密码修改视图中，同样的代码还得一再重复。所以，我们需要抽象hash的过程，这样即使我们忘记了，我们的应用也会悄悄完成它。秘诀在于我们写了个**setter**，这样当设置`user.password = 'password1'`时，密码在存储之前就会被用BCrypt自动hash了。

myapp/models.py
```
from sqlalchemy.ext.hybrid import hybrid_property

from . import bcrypt, db

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(64), unique=True)
    _password = db.Column(db.String(128))

    @hybrid_property
    def password(self):
        return self._password

    @password.setter
    def _set_password(self, plaintext):
        self._password = bcrypt.generate_password_hash(plaintext)
```

We're using SQLAlchemy's hybrid extension to define a property with several different functions called from the same interface.. Our setter is called when we assign a value to the `user.password` property. In it, we hash the plaintext password and store it in the `_password` column of the user table. Since we're using a hybrid property we can then access the hashed password via the same `user.password` property.

我们使用SQLAlchemy的hybird（混合）拓展来定义一个同时供众多函数调用的接口属性。当赋值给`user.password`属性时，我们的setter会被自动调用。而在setter内，我们会hash纯文本密码并存储在用户表里的`_password`列里。既然我们定义`user.password`为混合属性，那么就可以通过这个属性来获取`_password`的值。

Now we can implement a sign-up view for an app using this model.

现在我们用这个模型来实现注册视图。

myapp/views.py
```
from . import app, db
from .forms import EmailPasswordForm
from .models import User

@app.route('/signup', methods=["GET", "POST"])
def signup():
    form = EmailPasswordForm()
    if form.validate_on_submit():
        user = User(username=form.username.data, password=form.password.data)
        db.session.add(user)
        db.session.commit()
        return redirect(url_for('index'))

    return render_template('signup.html', form=form)
```

## 验证

Now that we've got a user in the database, we can implement authentication. We'll want to let a user submit a form with their username and password (though this might be email and password for some apps), then make sure that they gave us the correct password. If it all checks out, we'll mark them as authenticated by setting a cookie in their browser. The next time they make a request we'll know that they have already logged in by looking for that cookie.

既然把用户加入到数据库中了，就可以实现验证功能了。我们想要让用户通过表单提交他们的用户名和密码（当然，有些时候是邮箱和密码），然后验证他们提供的密码是否正确。如果一切安好，我们将通过设置浏览器的cookie来标记他们是已验证的用户。下一次他们再提交请求时，通过查看cookie，我们就知道他们已经登录过了。

Let's start by defining a `UsernamePassword` form with WTForms.

先从用WTForms定义一个`UsernamePassword`开始吧。

myapp/forms.py
```
from flask.ext.wtforms import Form
from wtforms import TextField, PasswordField, Required

class UsernamePasswordForm(Form):
    username = TextField('Username', validators=[Required()])
    password = PasswordField('Password', validators=[Required()])
```

Next we'll add a method to our user model that compares a string with the hashed password stored for that user.

接下来我们将往我们的用户模型添加一个方法，拿一个字符串跟已存储的hash过的用户密码作比较。

myapp/models.py
```
from . import db

class User(db.Model):

    # [...] columns and properties

    def is_correct_password(self, plaintext)
        if bcrypt.check_password_hash(self._password, plaintext):
            return True

        return False
```

### Flask-Login

Our next goal is to define a sign-in view that serves and accepts our form. If the user enters the correct credentials, we will authenticate them using the Flask-Login extension. This extension simplifies the process of handling user sessions and authentication.

我们下一个目标是定义一个使用我们的表单类的登录视图。如果用户输入正确的账号，我们将使用Flask-Login插件来验证它们。这个插件简化了处理用户会话和验证的操作。

We need to do a little bit of configuration to get Flask-Login ready to roll.

我们只需做少量的配置就能让Flask-Login用起来了。

In *__init__.py* we will define the Flask-Login `login_manager`.

我们先在*__init__.py*定义Flask-Login的`login_manager`。

*myapp/__init__.py*
```
from flask.ext.login import LoginManager

# 创建并配置应用
# [...]

from .models import User

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view =  "signin"

@login_manager.user_loader
def load_user(userid):
    return User.query.filter(User.id == userid).first()
```

Here we created an instance of the `LoginManager`, initialized it with our `app` object, defined the login view and told it how to get a user object with a user's `id`. This is the baseline configuration you should have for Flask-Login.

我们在这里创建一个叫`LoginManager`的实例，用我们的`app`对象初始化它，定义登录视图并告诉它如何通过`id`获取用户类。这是使用Flask-Login的基本配置。

{ SEE MORE: You can see more ways to customize Flask-Login here: https://flask-login.readthedocs.org/en/latest/#customizing-the-login-process } 

{ SEE MORE: 你可以在这里找到自定义Flask-Login的更多信息： https://flask-login.readthedocs.org/en/latest/#customizing-the-login-process } 

Now we can define the `signin` view that will handle authentication.

现在我们来定义处理验证的`signin`视图。

_myapp/views.py_
```
from flask import redirect, url_for

from flask.ext.login import login_user

from . import app
from .forms import UsernamePasswordForm()

@app.route('signin', methods=["GET", "POST"])
def signin():
    form = UsernamePasswordForm()

    if form.validate_on_submit():
        user = User.query.filter_by(username=form.username.data).first_or_404()
        if user.is_correct_password(form.password.data):
            login_user(user)

            return redirect(url_for('index'))
        else:
            return redirect(url_for('signin'))
    return render_template('signin.html', form=form)
```

We simply import the `login_user` function from Flask-Login, check a user's login credentials and call `login_user(user)`. You can log the current user out with `logout_user()`.

我们仅需要从Flask-Login import `login_user`函数，检查用户的验证信息，并调用`login_user(user)`。你使用`logout_user()`登出当前用户。

_myapp/views.py_
```
from flask import redirect, url_for
from flask.ext.login import logout_user

from . import app

@app.route('/signout')
def signout():
    logout_user()

    return redirect(url_for('index'))
```

## 忘了密码？

You'll generally want to implement a "Forgot your password" feature that lets a user who recover their account by email. This area has a plethora of potential vulnerabilities because the whole point is to let an unauthenticated user take over an account. We'll implement our password reset using some of the same techniques as our email confirmation. We'll need a form to request a reset for a given account based on that account's email and a form to choose a new password once we've confirmed that the unauthenticated user has access to the account email address. This assumes that our user model has an email and a password, where the password is a hybrid property as we previously created.

你总会需要实现一个“忘记密码？”功能来允许用户通过邮件重置自己的账号密码。这个地方可能会有潜在安全隐患，因为你不得不让一个未验证的用户接管一个账户。我们将会使用类似于邮件验证的方式来实现密码重置的功能。我们将需要一个表单类来请求对给定账户的重置，还有一个表单来选择一个新的密码（前提是未验证用户访问了账户邮箱）。这里假设我们的用户模型有一个email和一个password，而password是我们之前设置过的混合属性。

{ WARNING: Don't send password reset links to an unconfirmed email address! You want to be sure that you are sending this link to the right person. }

{ WARNING: 不要发送密码重置链接给未确认的邮箱！你要确保发送链接给正确的人。 }

We're going to need two forms. One is to request a reset link be sent to a certain email and the other is to change the password.

我们将需要两个表单。一个用于请求一个重置链接，另一个用于修改密码。

myapp/forms.py
```
from flask.ext.wtforms import Form

from wtforms import TextField, PasswordField, Required, Email

class EmailForm(Form):
    email = TextField('Email', validators=[Required(), Email()])

class PasswordForm(Form):
    password = PasswordField('Email', validators=[Required()])
```

I'm assuming that our password reset form just needs one field for the password. Many apps require the user to enter their new password twice to confirm that they haven't made a typo. To do this, we'd simply add another `PasswordField` and add the `EqualTo` WTForms validator to the main password field.

我将假设我们的密码重置表单只需要密码这一栏。许多应用需要用户两次输入他们的新密码，确保没有打错。为了实现这个，我们仅需添加另一个`PasswordField`，并加一个WTForms验证函数`EqualTo`到主密码域。

{ SEE ALSO: There a lot of interesting discussions in the User Experience (UX) community about the best way to handle this in sign-up forms. I personally like the thoughts of one Stack Exchange user (Roger Attrill) who said, "We should not ask for password twice - we should ask for it once and make sure that the 'forgot password' system works seamlessly and flawlessly."

* You can read more about this topic in this thread on the User Experience Stack Exchange: http://ux.stackexchange.com/questions/20953/why-should-we-ask-the-password-twice-during-registration/21141

* There are also some cool ideas for simplifying the sign-up and sign-in forms in this Smashing Magazine article: http://uxdesign.smashingmagazine.com/2011/05/05/innovative-techniques-to-simplify-signups-and-logins/ }

{ SEE ALSO: 很多人站在用户体验的角度，对什么是设计注册表单的最佳方式有过许多有趣的讨论。我个人喜欢Stack Exchange用户 Roger Attrill说的一番话：“我们不应该一再要求用户输入密码 - 我们应该要求输入一次，然后确保‘忘记密码’能无缝且正确地运行。”

* 你可以在User Experience Stack Exchange读到更多关于这个话题的内容:<http://ux.stackexchange.com/questions/20953/why-should-we-ask-the-password-twice-during-registration/21141>

* 在Smashing Magazine的文章中，你可以读到一些简化注册和登录表单的酷想法：<http://uxdesign.smashingmagazine.com/2011/05/05/innovative-techniques-to-simplify-signups-and-logins/> }

Now we'll implement the first view of our process, where a user can request that a password reset link be sent for a given email address.

现在我们将开始迈出第一步，让用户可以请求

myapp/views.py
```
from flask import redirect, url_for, render_template

from . import app
from .forms import EmailForm
from .models import User
from .util import send_email, ts

@app.route('/reset', methods=["GET", "POST"])
def reset():
    form = EmailForm()
    if form.validate_on_submit()
        user = User.query.filter_by(email=form.email.data).first_or_404()

		subject = "Password reset requested"
        # Here we use the URLSafeTimedSerializer we created in `util` at the beginning of the chapter
        token = ts.dumps(self.email, salt='recover-key')

        recover_url = url_for(
            'reset_with_token',
            token=token,
            _external=True)

        html = render_template(
            'email/recover.html',
            recover_url=recover_url)
            
        # Let's assume that send_email was defined in myapp/util.py
        send_email(user.email, subject, html)

        return redirect(url_for('index'))
    return render_template('reset.html', form=form)
```

When the form receives an email address, we grab the user with that email address, generate a reset token and send them a password reset URL. That URL routes them to a view that will validate the token and let them reset the password.

当表单接受到一个邮件地址时，我们取出对应的用户，生成一个重置token，再发送一个重置密码URL给用户。这个URL将引导用户前往验证token的视图，并让用户重置密码。

myapp/views.py
```
from flask import redirect, url_for, render_template

from . import app, db
from .forms import PasswordForm
from .models import User
from .util import ts

@app.route('/reset/<token>', methods=["GET", "POST"])
def reset_with_token(token):
    try:
        email = ts.loads(token, salt="recover-key", max_age=86400)
    except:
        abort(404)

    form = PasswordForm()

    if form.validate_on_submit():
        user = User.query.filter_by(email=email).first_or_404()

        user.password = form.password.data

        db.session.add(user)
        db.session.commit()

        return redirect(url_for('signin'))

    return render_template('reset_with_token.html', form=form, token=token)
```

We are using the same token validation method as we did to confirm the user's email address. The view passes the token to the template so tha the form submits to the correct URL. Let's have a look at what that template might look like.

我们将使用验证用户邮箱时用的那个token验证方式。这个视图传递token给模板，所以表单会提交到正确的URL。让我们看看这个模板到底长啥样。

_myapp/templates/reset_with_token.html_
```
{% extends "layout.html" %}

{% block body %}
<form action="{{ url_for('reset_with_token', token=token) }}" method="POST">
    {{ form.password.label }}: {{ form.password }}<br>
    {{ form.csrf_token }}
    <input type="submit" value="Change my password" />
</form>
{% endblock %}
```

## 总结

- Use the itsdangerous package to create and validate tokens sent to an email address.
- You can use these tokens to validate emails when a user creates an account, changes their email or forgets their password.
- Authenticate users using the Flask-Login extension to avoid dealing with a bunch of session management stuff yourself.
- Always think about how a malicious user could abuse your app to do things that you didn't intend.

- 使用itsdangerous包来创建和验证送往邮箱的token。
- 你可以使用token来验证邮箱，无论是在用户注册账户，还是修改邮箱，或者忘记密码的时候。
- 使用Flask-Login插件来验证用户，这样能避免处理一堆会话管理的麻烦事。
- 总是设想会有恶意的用户试图从应用中挖掘漏洞。

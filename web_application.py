from flask import Flask
from flask import render_template
from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import DataRequired
import os

app = Flask(__name__)
app.config["SECRET_KEY"] = os.getenv("SECRET_KEY")


class SubmitForm(FlaskForm):
    word = StringField('Word', validators=[DataRequired()])
    submit = SubmitField('Submit')


@app.route('/')
def index():
    form = SubmitForm()
    return render_template("index.html", form=form)


@app.route('/search', methods=['POST'])
def search_word():
    form = SubmitForm()
    output = None

    if form.validate_on_submit():
        print(form.word.data)
        output = ['hi', 'mom', '!']
    # database query needs to go here
    # It currently only prints the input
    # print(request.form['word'])
    # output = ['hi', 'mom', '!']
    return render_template("index.html", form=form, output=output)


if __name__ == '__main__':
    app.run()

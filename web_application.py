from flask import Flask
from flask import render_template
from flask import request
from language_model import SimilarWords
app = Flask(__name__)


@app.route('/')
def index():
    return render_template("index.html")

@app.route('/search', methods=['POST'])
def search_word():
    # database query needs to go here
    # It currently only prints the input
    word=request.form['word']
    output=SimilarWords (word)
    return render_template("index.html", output=output)


if __name__ == '__main__':
    app.run()

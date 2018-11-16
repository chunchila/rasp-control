from flask import Flask
app = Flask(__name__)
import os

fileName = "tmpfile.txt"

if not os.path.exists(fileName):
    with open(fileName, "w+") as file:
        file.write("0")
@app.route('/')
def hello():
    with open(fileName, "r") as file:
        data = file.read()

    with open(fileName, "w+") as file:
        if data == "1":
            val = "0"
            file.write(val)
        else:
            val = "1"
            file.write(val)
    return data

if __name__ == '__main__':
    app.run()


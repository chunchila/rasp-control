from flask import Flask
app = Flask(__name__)
import os

fileName = "tmpfile.txt"

if not os.path.exists(fileName):
    with open(fileName, "w+") as file:
        file.write("0")


@app.route('/change',methods=['POST', 'GET'])
def change_func_page():
    with open(fileName, "r") as file:
        data = file.read()

    with open(fileName, "w+") as file:
        if data == "1":
            val = "0"
            file.write(val)
        else:
            val = "1"
            file.write(val)
    return (val)

@app.route('/')
def hello():
    with open(fileName, "r") as file:
        data = file.read()
    return data

if __name__ == '__main__':
    app.run(debug=True, port=5000, host="0.0.0.0")


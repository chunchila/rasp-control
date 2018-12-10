# Copy of http://stackoverflow.com/a/20104705
from flask import Flask, render_template
from flask_sockets import Sockets

app = Flask(__name__)
app.debug = True

sockets = Sockets(app)


@sockets.route('/echo')
def echo_socket(ws):
    while True:
        print("im in ")
        message = ws.receive()
        ws.send(message[::-1])


@app.route('/')
def hello():
    return 'Hello World!'


@app.route('/echo_test', methods=['GET'])
def echo_test():
    return "roman"


if __name__ == '__main__':

    app.run(host="10.100.102.4" ,port=5000)
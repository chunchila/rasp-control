from flask import Flask
from flask_sockets import Sockets
app = Flask(__name__)
import time

sockets = Sockets(app)

import os
import logging

fileName = "tmpfile.txt"

html = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Bootstrap Example</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
</head>
<body>
  
  <form action="/change" method="get">
<div class="container">
  <h1>Click The Button To Change The Status</h1>        
  <button type="submit" class="btn btn-success btn-lg">Primary</button>
</div>

</body>
</html>
'''

changed_html = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Bootstrap Example</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
</head>
<body>

  <form action="/change" method="get">
<div class="container">
  <h1>Status Changed To {0}</h1>        
  <h1>Click The Button To Change The Status</h1>        
  <button type="submit" class="btn btn-success btn-lg">Primary</button>
</div>

</body>
</html>

'''

if not os.path.exists(fileName):
    with open(fileName, "w+") as file:
        file.write("0")


@app.route('/change',methods=['POST', 'GET'])
def change_func_page():
    with open(fileName, "r") as file:
        data = file.read()

    with open(fileName, "w+") as file:
        if "1" in data:
            val = "0"
            file.write(val)
        else:
            val = "1"
            file.write(val)
    return changed_html.replace("{0}" , val)

@app.route('/')
def hello():
    with open(fileName, "r") as file:
        data = file.read()
    return html


@sockets.route('/register')
def reg(ws):
    while not ws.closed:
        # Sleep to prevent *constant* context-switches.
        #time.sleep(0.1)
        #message = ws.receive()
        with open(fileName, "r") as file:
            data = file.read()
        ws.send("hello from ws :) : ", data)


if __name__ == '__main__':

    #app.run(debug=True, port=5000, host="0.0.0.0")
    from gevent import pywsgi
    from geventwebsocket.handler import WebSocketHandler

    server = pywsgi.WSGIServer(('', 5000), app, handler_class=WebSocketHandler)
    server.serve_forever()


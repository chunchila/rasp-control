
import websocket
from websocket import create_connection
ws = create_connection("ws://127.0.0.1:12345/echo")
ws.send("hello world")
ws.recv()
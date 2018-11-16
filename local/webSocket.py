from lomond import WebSocket
from lomond.persist import persist
websocket = WebSocket('wss://still-crag-29020.herokuapp.com/register')
for event in persist(websocket):
    if event.name == 'text':
        print(event.text)
        #websocket.send(event.text)

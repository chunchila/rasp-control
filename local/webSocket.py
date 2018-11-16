from lomond import WebSocket
from lomond.persist import persist
websocket = WebSocket('wss://echo.example.org')
for event in persist(websocket):
    if event.name == 'text':
        websocket.send_text(event.text)
        
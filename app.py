from flask import Flask
from stompest.config import StompConfig
from stompest.protocol import StompSpec
from stompest.sync import Stomp

ACTIVEMQ_QUEUE = '/queue/flask-activemq'
ACTIVEMQ_SERVER = 'activemq-service.flask.svc.cluster.local:61613'

app = Flask(__name__)

def send_message(message):
    config = StompConfig(ACTIVEMQ_SERVER)
    client = Stomp(config)
    client.connect()
    client.send(ACTIVEMQ_QUEUE, message.encode())
    client.disconnect()

@app.route('/')
def hello_world():
    send_message("A user accessed the homepage")
    return 'Hello, World!'

if __name__ == '__main__':
    app.run(debug=True)


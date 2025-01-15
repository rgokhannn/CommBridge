from flask import Flask, request, jsonify
from pymongo import MongoClient
import redis
import pika
import json
import threading
import time

app = Flask(__name__)

# MongoDB Configuration
mongo_client = MongoClient('mongodb://mongo:27017/')
db = mongo_client['producer_consumer_db']
collection = db['messages']

# Redis Configuration
redis_client = redis.Redis(host='redis', port=6379, decode_responses=True)

# RabbitMQ Configuration
def setup_rabbitmq():
    while True:
        try:
            credentials = pika.PlainCredentials('guest', 'guest')
            connection = pika.BlockingConnection(pika.ConnectionParameters('rabbitmq', credentials=credentials))
            channel = connection.channel()
            channel.queue_declare(queue='message_queue', durable=True)
            return connection, channel
        except pika.exceptions.AMQPConnectionError:
            print("RabbitMQ bağlantısı başarısız. Tekrar deneniyor...")
            time.sleep(5)

# Initialize RabbitMQ connection and channel
rabbit_connection, rabbit_channel = setup_rabbitmq()
def ensure_connection():
    global rabbit_connection, rabbit_channel
    if rabbit_connection.is_closed or rabbit_channel.is_closed:
        rabbit_connection, rabbit_channel = setup_rabbitmq()

@app.route('/produce', methods=['POST'])
def produce():
    ensure_connection()

    data = request.json
    if not data or 'message' not in data:
        return jsonify({'error': 'Message is required'}), 400

    message = data['message']

    # Save to MongoDB
    collection.insert_one({'message': message})

    # Publish to RabbitMQ
    rabbit_channel.basic_publish(
        exchange='',
        routing_key='message_queue',
        body=json.dumps({'message': message}),
        properties=pika.BasicProperties(delivery_mode=2)  # Make message persistent
    )

    return jsonify({'status': 'Message produced successfully'}), 200

# Consumer Logic
def consume():
    def callback(ch, method, properties, body):
        data = json.loads(body)
        # Do something with the message
        print(f"Consumed message: {data['message']}")
    while True:
        try:
            ensure_connection()  # Ensure connection before consuming
            rabbit_channel.basic_consume(queue='message_queue', on_message_callback=callback, auto_ack=True)
            rabbit_channel.start_consuming()
        except pika.exceptions.StreamLostError:
            print("Kanal kaybedildi, yeniden bağlanılıyor...")
            time.sleep(5)
if __name__ == '__main__':
    # Start the consumer in a separate thread
    threading.Thread(target=consume, daemon=True).start()
    app.run(host='0.0.0.0', port=5000)
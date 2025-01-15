import os
from flask import Flask, request, jsonify
from pymongo import MongoClient
import redis
import pika
import json
import threading
import time
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# MongoDB Configuration
mongo_user = os.getenv('MONGO_USER')
mongo_password = os.getenv('MONGO_PASS')
mongo_host = os.getenv('MONGODB_HOST', 'mongodb')
if mongo_user and mongo_password:
    mongo_client = MongoClient(
            f'mongodb://{mongo_user}:{mongo_password}@{mongo_host}:27017/'
    )
else:
    mongo_client = MongoClient(f'mongodb://{mongo_host}:27017/')
db = mongo_client['producer_consumer_db']
collection = db['messages']

# Redis Configuration
redis_password = os.getenv('REDIS_PASSWORD')
redis_client = redis.Redis(host='redis', port=6379, password=redis_password, decode_responses=True)

# RabbitMQ Configuration
def setup_rabbitmq():

    while True:
        try:
            rabbitmq_user = os.getenv("RABBITMQ_USER")
            rabbitmq_password = os.getenv("RABBITMQ_PASS")

            if not rabbitmq_user or not rabbitmq_password:
                print("Kullanıcı adı veya şifre eksik!")
                return None, None

            credentials = pika.PlainCredentials(rabbitmq_user,rabbitmq_password)
            connection = pika.BlockingConnection(pika.ConnectionParameters('rabbitmq', credentials=credentials))
            channel = connection.channel()
            channel.queue_declare(queue='message_queue', durable=True)
            return connection, channel
        except pika.exceptions.AMQPConnectionError:
            print("RabbitMQ bağlantısı başarısız. Tekrar deneniyor...")
            time.sleep(5)

# Initialize RabbitMQ connection and channel
rabbit_connection, rabbit_channel = setup_rabbitmq()
#def ensure_connection():
#    global rabbit_connection, rabbit_channel
#    if rabbit_connection.is_closed or rabbit_channel.is_closed:
#        rabbit_connection, rabbit_channel = setup_rabbitmq()
def ensure_connection():
    global rabbit_connection, rabbit_channel
    # Eğer rabbit_connection veya rabbit_channel None ise, yeniden bağlantı kurmaya çalış
    if rabbit_connection is None or rabbit_channel is None or rabbit_connection.is_closed or rabbit_channel.is_closed:
        print("RabbitMQ bağlantısı kapalı veya None. Bağlantı kuruluyor...")
        rabbit_connection, rabbit_channel = setup_rabbitmq()
        # Bağlantı kurulamadıysa, işlem yapma
        if rabbit_connection is None or rabbit_channel is None:
            print("RabbitMQ bağlantısı kurulamadı.")
            return  # veya başka bir hata yönetimi
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

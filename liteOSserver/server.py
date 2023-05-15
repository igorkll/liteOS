import traceback
import socket
import json
import time

def callback(data):
    # здесь можно определить свой функционал и обработать полученный пакет
    print("request", data)
    data = json.loads(data)
    
    ret = {}
    if data["type"] == "ping":
        ret = {
            "type": "pong"
        }

    
    print("response", ret)
    return json.dumps(ret).encode()

def run_server():
    # создаем TCP сокет и связываем его с портом 8291
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.bind(('0.0.0.0', 8291))
        sock.listen()

        print('Сервер запущен на порту 8291...')

        while True:
            try:
                while True:
                    conn, addr = sock.accept()
                    data = conn.recv(1024).split(b"\n", 1)[0]

                    response = callback(data.decode("utf-8"))
                    conn.send(response)

                    conn.close()
            except Exception as str:
                print("СЕРВАК ПОЛЁГ: ")
                traceback.print_exc()

            print("ПЕРЕЗАПУСК.")
        

if __name__ == '__main__':
    run_server()
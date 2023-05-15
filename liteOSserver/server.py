import traceback
import socket
import json

def callback(data):
    # здесь можно определить свой функционал и обработать полученный пакет
    data = json.loads(data)
    
    ret = {}
    if data.type == "ping":
        ret = {
            "type": "pong"
        }

    return json.dumps(ret)

def run_server():
    # создаем TCP сокет и связываем его с портом 8291
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.bind(('0.0.0.0', 8291))
        sock.listen()

        print('Сервер запущен на порту 8291...')

        while True:
            try:
                while True:
                    # принимаем новое соединение
                    conn, addr = sock.accept()
                    print(f'Установлено соединение с {addr[0]}:{addr[1]}')

                    # читаем данные из сокета
                    data = conn.recv(1024)

                    # вызываем функцию обратного вызова и отправляем ее результат обратно клиенту
                    response = callback(data)
                    conn.send(response)

                    # закрываем соединение
                    conn.close()
                    print(f'Соединение с {addr[0]}:{addr[1]} закрыто')
            except Exception as str:
                print("СЕРВАК ПОЛЁГ: ")
                traceback.print_exc()

            print("ПЕРЕЗАПУСК.")
        

if __name__ == '__main__':
    run_server()
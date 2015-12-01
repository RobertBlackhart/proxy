import 'dart:io';

// Configuration
int GAME_SERVER_PORT = 25565;
String WEB_ADDRESS = 'localhost';


class Host {
    Socket game;
    WebSocket ws;

    refresh() async {
        //setup websocket
        ws = await WebSocket.connect('ws://$WEB_ADDRESS:8080');
        print('websocket connected');

        // game server
        game = await Socket.connect('0.0.0.0', GAME_SERVER_PORT);
        print('game server connected');

        // sync
        ws.listen((data) {
            print('websocket: ' + new String.fromCharCodes(data));
            game.add(data);
        });
        game.listen((data) {
            print('game: ' + new String.fromCharCodes(data));
            ws.add(data);
        });
    }
}

class Server {
    List<Socket> clients = [];

    refresh() async {
        // websockets
        ServerSocket http = await ServerSocket.bind('0.0.0.0', 8080);
        print('bound to 8080');
        http.listen((Socket s) async {
            ServerSocket clientServer = await ServerSocket.bind('0.0.0.0', 8081);
            print('bound to 8081');

            clientServer.listen((Socket socket) async {
                print('got a client connection');
                clients.add(socket);
                socket.listen((data) => s.add(data));
            });

            s.listen((data) => passToClient(data));
        });
    }

    passToClient(data) {
        clients.forEach((Socket wsClient) {
            wsClient.add(data);
        });
    }
}

class Client {
    refresh() async {
        // game client
        ServerSocket game = await ServerSocket.bind('0.0.0.0', GAME_SERVER_PORT + 1);
        print('bound to ${GAME_SERVER_PORT+1}');
        game.listen((socket) async {
            Socket ws = await Socket.connect(WEB_ADDRESS, 8081);
            socket.listen((data) => ws.add(data));
            ws.listen((data) {
                socket.add(data);
            });
        });
    }
}

import 'dart:io';

// Configuration
int     GAME_SERVER_PORT = 25565;
String  WEB_ADDRESS = 'localhost';


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
      print('game: ' +new String.fromCharCodes(data));
      ws.add(data);
    });
  }
}

class Server {

  refresh() async {
    // websockets
    HttpServer http = await HttpServer.bind('0.0.0.0', 8080);
    http.listen((request) async {
      WebSocket wsServer = await WebSocketTransformer.upgrade(request);

      http = await HttpServer.bind('0.0.0.0', 8081);
      request = await http.first;
      http.listen((request) async {
        WebSocket wsClient = await WebSocketTransformer.upgrade(request);

        wsClient.listen((data) => wsServer.add(data));
        wsServer.listen((data) => wsClient.add(data));
      });

    });
  }
}

class Client {
  refresh() async {
    // game client
    ServerSocket game = await ServerSocket.bind('0.0.0.0', GAME_SERVER_PORT+1);
    game.listen((socket) async {
      WebSocket ws = await WebSocket.connect('ws://$WEB_ADDRESS:8081');
      socket.listen((data) => ws.add(data));
      ws.listen((data) {
        socket.add(data);
      });
    });
  }
}

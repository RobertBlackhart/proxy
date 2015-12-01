import 'dart:io';

class Server {
  Socket game;
  WebSocket webSocket;

  refresh() async {
    // setup websocket server
    HttpServer http = await HttpServer.bind('localhost', 8080);
    print('bound server websocket');
    HttpRequest request = await http.first;
    webSocket = await WebSocketTransformer.upgrade(request);

    // connect to game;
    game = await Socket.connect("localhost", 21025);
    print('bound game proxy');

    // sync
    webSocket.listen((data) => game.add(data));
    game.listen((data) => webSocket.add(data));
  }

}

class Client {
  refresh() async {
    // setup websocket
    WebSocket ws = await WebSocket.connect('ws://localhost:8080');

    // setup game client socket
    ServerSocket game = await ServerSocket.bind('localhost', 21023);
    Socket gameSocket = await game.first;

    // sync data
    gameSocket.listen((data) => ws.add(data));
    ws.listen((data) {
      //print(new String.fromCharCodes(data));
      gameSocket.add(data);
    });
  }
}

import 'dart:io';

int GAME_SERVER_PORT = 7777;


class Host {
  Socket game;
  WebSocket ws;

  refresh() async {
    // setup websocket
    ws = await WebSocket.connect('ws://localhost:8080');

    // game server
    game = await Socket.connect("localhost", GAME_SERVER_PORT);

    // sync
    ws.listen((data) => game.add(data));
    game.listen((data) => ws.add(data));
  }
}

class Server {
  Socket game;
  WebSocket wsServer;
  WebSocket wsClient;

  refresh() async {
    // websockets
    HttpServer http = await HttpServer.bind('localhost', 8080);
    HttpRequest request = await http.first;
    wsServer = await WebSocketTransformer.upgrade(request);

    http = await HttpServer.bind('localhost', 8081);
    request = await http.first;
    wsClient = await WebSocketTransformer.upgrade(request);

    // sync
    wsClient.listen((data) => wsServer.add(data));
    wsServer.listen((data) => wsClient.add(data));
  }
}

class Client {
  refresh() async {
    // websockets
    WebSocket ws = await WebSocket.connect('ws://localhost:8081');

    // game client
    ServerSocket game = await ServerSocket.bind('localhost', GAME_SERVER_PORT);
    Socket gameSocket = await game.first;

    // sync data
    gameSocket.listen((data) => ws.add(data));
    ws.listen((data) {
      gameSocket.add(data);
    });
  }
}

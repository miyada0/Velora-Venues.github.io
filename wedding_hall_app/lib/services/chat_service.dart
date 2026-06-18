import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;

  void connect(String baseUrl) {
    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();
  }

  void sendMessage(
    String senderId,
    String hallId,
    String message,
  ) {
    socket.emit("sendMessage", {
      "senderId": senderId,
      "hallId": hallId,
      "message": message,
    });
  }

  void onMessage(Function(dynamic) callback) {
    socket.on("receiveMessage", callback);
  }

  void disconnect() {
    socket.disconnect();
  }
}

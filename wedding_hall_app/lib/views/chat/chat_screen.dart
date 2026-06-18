import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/chat_service.dart';
import '../../viewmodels/auth_vm.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String hallId;

  const ChatScreen({super.key, required this.hallId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ChatService chatService = ChatService();
  final TextEditingController controller = TextEditingController();

  List messages = [];

  @override
  void initState() {
    super.initState();

    chatService.connect("http://YOUR_IP:5000");

    chatService.onMessage((data) {
      setState(() {
        messages.add(data);
      });
    });
  }

  @override
  void dispose() {
    chatService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.read(authProvider)?["user"]?["_id"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg["sender"] == userId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["message"],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Type message...",
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  chatService.sendMessage(
                    userId,
                    widget.hallId,
                    controller.text,
                  );

                  controller.clear();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

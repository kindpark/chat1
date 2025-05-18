import 'package:flutter/material.dart';
import 'package:chat1/service/chatservice.dart'; // 실제 경로로 바꿔주세요
import 'package:flutter/foundation.dart';

class ChatPage extends StatefulWidget {
  final String senderId;
  final String receiverId;

  const ChatPage({
    super.key,
    required this.senderId,
    required this.receiverId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver{
  late ChatService chatService;
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    chatService = ChatService(widget.senderId);
    _listenMessages();
  }
  void _listenMessages(){
    chatService.getMessages().listen((msg) {
      setState(() {
        messages.add(msg);
      });
    });
  }
  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add({
        'sender': widget.senderId,
        'receiver': widget.receiverId,
        'content': text,
      });
    });
    chatService.sendMessage(
      chatRoomId: 2,
      senderId: widget.senderId,
      receiverId: widget.receiverId,
      message: text,
    );
    _controller.clear();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    chatService.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('앱이 포그라운드로 복귀함, WebSocket 재연결 시도');
      chatService.dispose();
      chatService = ChatService(widget.senderId); // 다시 연결
      _listenMessages();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅 (${widget.senderId} → ${widget.receiverId})'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sender'] == widget.senderId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: '메시지 입력'),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
class ChatService {
  WebSocketChannel? _channel;
  final String userId;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  ChatService(this.userId){
    _connect();
  }
  void _connect(){
    debugPrint("websocket 연결 시도..");
    _channel = WebSocketChannel.connect(
      Uri.parse(
          kIsWeb
              ? 'ws://localhost:8080/ws/chat?userId=$userId'
              : 'ws://10.0.2.2:8080/ws/chat?userId=$userId'
      ),
    );
    _channel!.stream.listen(
        (event){
          final data = jsonDecode(event);
          if(data is Map<String, dynamic>){
            _messageController.add(data);
          }
        },
      onError: (error){
          debugPrint("websocket error.. : $error");
          //백그라운드, 포그라운드 전환시 연결이 끊길때 재연결하는 메서드
          _reconnectWithDelay();
          },
      cancelOnError: true,
    );
  }
  void _reconnectWithDelay() async{
    await Future.delayed(const Duration(seconds :1));
    //딜레이 후 재연결
    _connect();
  }
  Stream<Map<String, dynamic>> getMessages(){
    return _messageController.stream;
  }
  void sendMessage({
    required int chatRoomId,
    required String senderId,
    required String receiverId,
    required String message,
  }) {
    final jsonMessage = jsonEncode({
      "sender": senderId,
      "receiver": receiverId,
      "content": message,
      "chatRoomId" : 1,
      //chatRoomId - 동적으로 설정하셔야 합니다.
    });
    _channel?.sink.add(jsonMessage);
  }
  void dispose() {
    _channel?.sink.close();
    _messageController.close();
  }
}

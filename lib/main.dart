import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chat1/page/chatpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;
// --dart-define으로 전달된 값 읽어오기
const String userId = String.fromEnvironment('USER_ID', defaultValue: 'sender');

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 백그라운드 메시지 수신 처리
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _showNotification(message);
}

/// 알림 표시 함수
void _showNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_channel',
          '채팅 알림',
          channelDescription: '상대방의 채팅 메시지를 표시합니다',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  log("🧑‍💻 USER_ID: $userId");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Android 알림 채널 초기화
  const initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  FirebaseMessaging.instance.getToken().then((token) {
    if (token != null) {
      final url = Uri.parse('http://10.0.2.2:8080/api/token');
      http.post(url, body: {
        'userId': userId,
        'token': token,
      });
    }
  });
  // 알림 권한 요청
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  log('🔔 알림 권한 상태: ${settings.authorizationStatus}');
  final token = await FirebaseMessaging.instance.getToken();
  log("🔑 FCM Token: $token");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // 여기서 푸시 알림을 표시하지 않으면 포그라운드에서는 푸시가 안 뜸
    // 하지만 WebSocket으로는 이미 메시지를 받고 있으므로 UI에는 뜸
    debugPrint('포그라운드 상태이므로 푸시 알림 표시 안함. 메시지: ${message.data}');
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 사용자 ID가 sender이면 receiver를, 반대라면 sender를 설정
    final receiverId = userId == 'sender' ? 'receiver' : 'sender';

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: ChatPage(
        senderId: userId,
        receiverId: receiverId,  // senderId와 receiverId를 다르게 설정
      ),
    );
  }
}

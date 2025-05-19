import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart'; // chat 프로젝트에서 가져오기
import 'package:chat1/model/menuitem.dart';
import 'package:chat1/page/menupage.dart';
import 'package:chat1/page/cartpage.dart';
import 'package:chat1/page/paymentpage.dart';
import 'package:chat1/page/paymentcompletepage.dart';
import 'page/chatpage.dart'; // chat 프로젝트에서 가져오기

const String userId = String.fromEnvironment('USER_ID', defaultValue: 'receiver');
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _showNotification(message);
}

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

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDaVvezeNjB9n9b4cWgBBZI0Fg1Ib3Qxu8",
        authDomain: "cart-ab0f6.firebaseapp.com",
        projectId: "cart-ab0f6",
        storageBucket: "cart-ab0f6.firebasestorage.app",
        messagingSenderId: "929235912304",
        appId: "1:929235912304:web:1f93b5babd464affcd56b5",
        measurementId: "G-KFLJK3NGJP",
      ),
    );
  } else {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final token = await FirebaseMessaging.instance.getToken();
  log("🔑 FCM Token: $token");

  if (token != null) {
    final url = Uri.parse('http://10.0.2.2:8080/api/token');
    http.post(url, body: {'userId': userId, 'token': token});
  }

  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  log('🔔 알림 권한 상태: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('포그라운드 푸시 수신: ${message.data}');
  });

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<MenuItem> cart = [];
  bool isTakeOut = false;
  String request = '';

  void _addToCart(MenuItem item) {
    setState(() {
      final existing = cart.firstWhere(
            (e) => e.name == item.name,
        orElse: () => MenuItem(name: '', price: 0),
      );
      if (existing.name.isEmpty) {
        cart.add(item);
      } else {
        existing.quantity += item.quantity;
      }
    });
  }

  void _updateItem(MenuItem item, String details, int quantity) {
    setState(() {
      item.details = details;
      item.quantity = quantity;
    });
  }

  void _clearCart() {
    setState(() => cart.clear());
  }

  void _goToCart() {
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => CartPage(
          cart: cart,
          onUpdate: _updateItem,
          onNext: () {
            navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (_) => PaymentPage(
                  total: cart.fold(0, (sum, e) => sum + e.price * e.quantity),
                  isTakeOut: isTakeOut,
                  request: request,
                  onTakeOutChanged: (val) => setState(() => isTakeOut = val),
                  onRequestChanged: (val) => setState(() => request = val),
                  onConfirm: () async {
                    final orderData = {
                      'items': cart.map((e) => {
                        'name': e.name,
                        'price': e.price,
                        'quantity': e.quantity,
                        'details': e.details,
                      }).toList(),
                      'total': cart.fold(0, (sum, e) => sum + e.price * e.quantity),
                      'isTakeOut': isTakeOut,
                      'request': request,
                    };

                    try {
                      final response = await http.post(
                        Uri.parse('http://10.0.2.2:8080/order'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode(orderData),
                      );

                      if (response.statusCode == 200) {
                        _clearCart();
                        navigatorKey.currentState!.pushReplacement(
                          MaterialPageRoute(builder: (_) => PaymentCompletePage()),
                        );
                      } else {
                        showDialog(
                          context: navigatorKey.currentContext!,
                          builder: (_) => AlertDialog(
                            title: Text('오류'),
                            content: Text('서버에 요청을 전송하지 못했습니다.'),
                            actions: [TextButton(onPressed: () => Navigator.pop(_), child: Text('확인'))],
                          ),
                        );
                      }
                    } catch (e) {
                      print('예외 발생: $e');
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _goToChat() {
    final receiverId = userId == 'sender' ? 'receiver' : 'sender';
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => ChatPage(senderId: userId, receiverId: receiverId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('메뉴'),
          actions: [
            IconButton(
              icon: Icon(Icons.chat_bubble_outline),
              onPressed: _goToChat,
              tooltip: '채팅하기',
            ),
          ],
        ),
        body: MenuPage(
          onAdd: _addToCart,
          onGoToCart: _goToCart,
        ),
      ),
    );
  }
}

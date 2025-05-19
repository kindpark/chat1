import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chat1/model/menuitem.dart';
class ApiService {
  static const String _host = '10.0.2.2';
  static const int    _port = 8080;
  static const String _base = 'http://$_host:$_port/shop/cart';

  ///장바구니 서버에 전송
  static Future<void> sendCart(List<MenuItem> cart) async {
    final url = Uri.parse('$_base/api/cart');
    final body = jsonEncode(cart.map((item) => item.toJson()).toList());

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('장바구니 전송 실패: ${response.body}');
    }
  }

  /// 결제 요청
  static Future<void> sendPayment(int total, bool isTakeOut, String request) async {
    final url = Uri.parse('$_base/api/payment');
    final body = jsonEncode({
      'total': total,
      'takeOut': isTakeOut,
      'request': request,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('결제 요청 실패: ${response.body}');
    }
  }

  /// FCM 토큰 저장 (선택)
  static Future<void> sendFcmToken(String token) async {
    final url = Uri.parse('$_base/api/fcm/token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode != 200) {
      throw Exception('FCM 토큰 저장 실패: ${response.body}');
    }
  }
}

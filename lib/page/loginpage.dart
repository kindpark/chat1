
import 'dart:convert';

import 'package:chat1/page/menupage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();

void login(BuildContext context) async {
  var response = await http.post(
    Uri.parse('http://your_server_ip:8080/api/users/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': emailController.text,
      'password': passwordController.text,
    }),
  );

  if (response.statusCode == 200) {
    var user = jsonDecode(response.body);
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MenuPage(userId: user['id']),
    ));
  } else {
    // 로그인 실패 처리
  }
}

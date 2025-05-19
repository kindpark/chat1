import 'package:flutter/material.dart';

class PaymentCompletePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('결제 완료')),
      body: Center(
        child: Text('결제가 완료되었고 음식을 준비 중입니다!', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
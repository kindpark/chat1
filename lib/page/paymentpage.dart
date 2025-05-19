import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final int total;
  final bool isTakeOut;
  final String request;
  final ValueChanged<bool> onTakeOutChanged;
  final ValueChanged<String> onRequestChanged;
  final VoidCallback onConfirm;

  PaymentPage({
    required this.total,
    required this.isTakeOut,
    required this.request,
    required this.onTakeOutChanged,
    required this.onRequestChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: request);
    return Scaffold(
      appBar: AppBar(title: Text('결제')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('총 결제 금액: $total원', style: TextStyle(fontSize: 20)),
            Row(
              children: [
                Checkbox(value: isTakeOut, onChanged: (v) => onTakeOutChanged(v!)),
                Text('포장 여부'),
              ],
            ),
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: '요청사항 입력'),
              onChanged: onRequestChanged,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: onConfirm,
                child: Text('결제 완료'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
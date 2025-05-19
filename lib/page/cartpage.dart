import 'package:flutter/material.dart';

import 'package:chat1/model/menuitem.dart';

class CartPage extends StatelessWidget {
  final List<MenuItem> cart;
  final void Function(MenuItem, String, int) onUpdate;
  final VoidCallback onNext;

  CartPage({required this.cart, required this.onUpdate, required this.onNext});

  void _editItem(BuildContext context, MenuItem item) {
    final controller = TextEditingController(text: item.details);
    final quantityController = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('세부 정보 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: '요청 사항'),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '수량'),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              onUpdate(item, controller.text, int.tryParse(quantityController.text) ?? 1);
              Navigator.pop(context);
            },
            child: Text('수정'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = cart.fold(0, (sum, e) => sum + e.price * e.quantity);
    return Scaffold(
      appBar: AppBar(title: Text('장바구니')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: cart
                  .map((item) => ListTile(
                leading: Icon(Icons.fastfood),
                title: Text(item.name),
                subtitle: Text('${item.price} x ${item.quantity} = ${item.price * item.quantity}원'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editItem(context, item),
                ),
              ))
                  .toList(),
            ),
          ),
          SizedBox(height: 10),
          Text('총액: $total원', style: TextStyle(fontSize: 20)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('메뉴로 이동')),
                ElevatedButton(onPressed: onNext, child: Text('결제 페이지로 이동')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
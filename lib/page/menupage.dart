import 'package:flutter/material.dart';

import 'package:chat1/model/menuitem.dart';

class MenuPage extends StatelessWidget {
  final int userId;
  final void Function(MenuItem) onAdd;
  final VoidCallback onGoToCart;

  MenuPage({required this.onAdd, required this.onGoToCart});

  final items = [
    MenuItem(name: '햄버거', price: 5000),
    MenuItem(name: '피자', price: 8000),
    MenuItem(name: '콜라', price: 2000),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: items
                .map((item) => ListTile(
              title: Text(item.name),
              subtitle: Text('${item.price}원'),
              trailing: ElevatedButton(
                onPressed: () => onAdd(MenuItem(name: item.name, price: item.price)),
                child: Text('추가'),
              ),
            ))
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: onGoToCart,
            child: Text('장바구니로 이동'),
          ),
        ),
      ],
    );
  }
}

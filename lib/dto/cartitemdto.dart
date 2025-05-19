import 'package:chat1/dto/productdto.dart';

class CartItemDto {
  final int cartItemId;
  final int quantity;
  final String custom;
  final ProductDto product;

  CartItemDto({
    required this.cartItemId,
    required this.quantity,
    required this.custom,
    required this.product,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> json) {
    return CartItemDto(
      cartItemId:    json['cartItemId'],
      quantity:      json['quantity'],
      custom:        json['custom'] ?? '',
      product:       ProductDto.fromJson(json['product']),
    );
  }
}
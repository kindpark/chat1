class ProductDto {
  final int    id;
  final String name;
  final int    price;
  final String imageUrl;

  ProductDto({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id:       json['id'],
      name:     json['name'],
      price:    json['price'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
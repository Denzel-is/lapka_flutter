class Product {
  final int id;
  final String imageUrl;
  final String title;
  final String price;

  Product({required this.id, required this.imageUrl, required this.title, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      title: json['title'] ?? 'Без названия',
      price: json['price']?.toString() ?? '0',
    );
  }
}

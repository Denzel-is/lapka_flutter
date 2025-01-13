// models/product.dart
class Product {
  final int id;
  final String imageUrl;
  final String title;
  final String price;

  /// Добавляем поле, указывающее, что товар уже в корзине
  /// Оно не обязательно должно храниться в базе;
  /// но в клиентской части помогает отобразить состояние на UI.
  bool isInCart;

  Product({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.isInCart = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      imageUrl: json["imageUrl"] ?? '',
      title: json['name'] ?? 'Без названия',
      price: json['price']?.toString() ?? '0',
      // Если сервер не присылает информации о том, в корзине ли товар,
      // можно оставить по умолчанию false или
      // парсить другое поле, если оно есть в JSON
      isInCart: false,
    );
  }

  /// Для удобства, если нужно отправлять объект на сервер
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'price': price,
      'imageUrl': imageUrl,
      // isInCart обычно не нужен на сервере, поэтому не передаём
    };
  }
}

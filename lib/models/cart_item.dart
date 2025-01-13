// models/cart_item.dart
import 'product.dart';

class CartItem {
  final Product product;
  int? quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  /// Если нужно, можно добавить фабрику для парсинга с JSON,
  /// например при получении списка из БД:
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  /// И метод, чтобы отправлять на сервер
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}

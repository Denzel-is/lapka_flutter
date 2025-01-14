import 'product_model.dart';
import 'order_model.dart';

class UserModel {
  String email;
  String password;
  String name;
  String phone;
  String avatarUrl; // URL аватарки

  List<Product> cart;
  String cardNumber;
  String cardHolder;
  String cardExpDate;
  String address;
  List<OrderModel> orders;

  UserModel({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.avatarUrl,
    required this.cart,
    required this.cardNumber,
    required this.cardHolder,
    required this.cardExpDate,
    required this.address,
    required this.orders,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'cart': cart.map((p) => p.toMap()).toList(),
      'cardNumber': cardNumber,
      'cardHolder': cardHolder,
      'cardExpDate': cardExpDate,
      'address': address,
      'orders': orders.map((o) => o.toMap()).toList(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      cart: (map['cart'] as List).map((pMap) => Product.fromMap(pMap)).toList(),
      cardNumber: map['cardNumber'] ?? '',
      cardHolder: map['cardHolder'] ?? '',
      cardExpDate: map['cardExpDate'] ?? '',
      address: map['address'] ?? '',
      orders: (map['orders'] as List)
          .map((oMap) => OrderModel.fromMap(oMap))
          .toList(),
    );
  }
}

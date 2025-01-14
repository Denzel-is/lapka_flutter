// Модель "Товар" (Product)
class Product {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      categoryId: map['categoryId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

// Модель "Заказ" (OrderModel)
class OrderModel {
  final String id;
  final DateTime createdAt;
  final List<Product> items;
  final double total;
  final String address;
  final String status;

  OrderModel({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.total,
    required this.address,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((p) => p.toMap()).toList(),
      'total': total,
      'address': address,
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toString()),
      items: (map['items'] as List)
          .map((itemMap) => Product.fromMap(itemMap))
          .toList(),
      total: (map['total'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      status: map['status'] ?? '',
    );
  }
}

// Модель "Пользователь" (UserModel)
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

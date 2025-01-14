import 'package:flutter/material.dart';
import 'product_model.dart';

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

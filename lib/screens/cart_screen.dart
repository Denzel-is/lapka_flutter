import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../widgets/cart_product_card.dart';

class CartScreen extends StatelessWidget {
  final List<CartItem> cart;
  final Function(Product, int) onUpdateCart;
  final Function(Product) onRemoveFromCart;

  const CartScreen({
    Key? key,
    required this.cart,
    required this.onUpdateCart,
    required this.onRemoveFromCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: cart.isEmpty
          ? const Center(
        child: Text(
          'Корзина пуста',
          style: TextStyle(fontSize: 24),
        ),
      )
          : ListView.builder(
        itemCount: cart.length,
        itemBuilder: (context, index) {
          final cartItem = cart[index];
          return CartProductCard(
            cartItem: cartItem,
            onUpdateCart: onUpdateCart,
            onRemoveFromCart: onRemoveFromCart,
          );
        },
      ),
    );
  }
}

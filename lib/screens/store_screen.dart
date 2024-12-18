import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'category_list_screen.dart';
import 'cart_screen.dart';
import 'user_profile_screen.dart';

class StoreScreen extends StatefulWidget {
  final String token;

  StoreScreen({required this.token});

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _selectedIndex = 0;
  List<CartItem> cart = [];
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      Center(child: Text("Главная")),
      CategoryListScreen(onAddToCart: _addToCart),
      CartScreen(cart: cart, onUpdateCart: _updateCart, onRemoveFromCart: _removeFromCart),
      UserProfileScreen(token: widget.token),
    ];
    _loadCart();
  }

  Future<void> _loadCart() async {
    final url = 'http://localhost:3000/cart';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> cartItems = json.decode(response.body);
      setState(() {
        cart = cartItems.map((item) {
          return CartItem(
            product: Product.fromJson(item),
            quantity: item['quantity'],
          );
        }).toList();
      });
    }
  }

  Future<void> _addToCart(Product product) async {
    final url = 'http://localhost:3000/cart';
    await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'productId': product.id,
        'quantity': 1,
      }),
    );
    _loadCart();
  }

  Future<void> _updateCart(Product product, int quantity) async {
    final url = 'http://localhost:3000/cart';
    await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'productId': product.id,
        'quantity': quantity,
      }),
    );
    _loadCart();
  }

  Future<void> _removeFromCart(Product product) async {
    final url = 'http://localhost:3000/cart/${product.id}';
    await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    _loadCart();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zoo Store', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Категории'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Корзина'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final int categoryId;
  final Function(Product) onAddToCart;

  const ProductListScreen({
    Key? key,
    required this.categoryId,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/categories/${widget.categoryId}/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          products = data.map((json) => Product.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Ошибка загрузки продуктов');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Ошибка: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Продукты', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          ? const Center(child: Text('Продукты не найдены'))
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            imageUrl: product.imageUrl,
            title: product.title,
            price: product.price,
            isInCart: product.isInCart,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    product: product,
                    onAddToCart: widget.onAddToCart,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

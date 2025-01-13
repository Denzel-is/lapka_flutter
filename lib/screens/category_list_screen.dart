import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/category.dart';
import 'product_list_screen.dart';
import '../models/product.dart';

class CategoryListScreen extends StatefulWidget {
  final Function(Product) onAddToCart;

  const CategoryListScreen({Key? key, required this.onAddToCart}) : super(key: key);

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data.map((json) => Category.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Ошибка загрузки категорий');
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
        title: const Text('Категории', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category.name),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductListScreen(
                    categoryId: category.id,
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

import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/user_model.dart';
import '../widgets/product_card.dart';

class ProductsPage extends StatefulWidget {
  final Category category;
  final UserModel currentUser;
  const ProductsPage({
    super.key,
    required this.category,
    required this.currentUser,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _searchCtrl = TextEditingController();
  late List filteredProducts;

  @override
  void initState() {
    super.initState();
    filteredProducts = mockProducts
        .where((p) => p?.categoryId == widget.category.id)
        .toList();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredProducts = mockProducts
            .where((p) => p.categoryId == widget.category.id)
            .toList();
      } else {
        filteredProducts = mockProducts
            .where((p) =>
        p.categoryId == widget.category.id &&
            p!.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Добавим AppBar с полем поиска
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Поиск...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: filteredProducts.isEmpty
          ? Center(
        child: Text(
          'Товаров нет :(',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return ProductCard(
            product: product,
            currentUser: widget.currentUser,
          );
        },
      ),
    );
  }
}

extension on Object? {
  get categoryId => null;
  
  get name => null;
}

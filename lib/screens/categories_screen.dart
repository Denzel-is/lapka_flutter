import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/user_model.dart';
import 'products_screen.dart';

class CategoriesPage extends StatelessWidget {
  final UserModel currentUser;
  const CategoriesPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: mockCategories.length,
        itemBuilder: (context, index) {
          final cat = mockCategories[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductsPage(
                      category: cat,
                      currentUser: currentUser,
                    ),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Ink.image(
                    image: NetworkImage(cat.imageUrl),
                    fit: BoxFit.cover,
                    height: 160,
                  ),
                  Container(
                    color: Colors.black54,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.category, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          cat.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

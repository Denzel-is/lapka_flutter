import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final VoidCallback onTap;

  CategoryCard({required this.categoryName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        title: Text(
          categoryName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        leading: Icon(Icons.pets, color: Colors.blueAccent, size: 30),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

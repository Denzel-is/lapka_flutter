import 'dart:convert'; // для jsonEncode/jsonDecode

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/product_model.dart';

// Фейковая "база данных" пользователей (в памяти)
List<UserModel> mockUsersDb = [];

// Загрузка из SharedPreferences
Future<void> loadUsersDbFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final usersJson = prefs.getString('usersDb') ?? '';
  if (usersJson.isEmpty) return;
  try {
    final decoded = jsonDecode(usersJson) as List;
    mockUsersDb.clear();
    for (var userMap in decoded) {
      mockUsersDb.add(UserModel.fromMap(userMap));
    }
  } catch (_) {
    // игнорируем ошибку
  }
}

// Сохранение в SharedPreferences
Future<void> saveUsersDbToPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final data = mockUsersDb.map((u) => u.toMap()).toList();
  final jsonStr = jsonEncode(data);
  await prefs.setString('usersDb', jsonStr);
}

// ============================================================================
// Категории
// ============================================================================
class Category {
  final String id;
  final String name;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

List<Category> mockCategories = [
  Category(
    id: 'cat1',
    name: 'Корма',
    imageUrl: 'https://i.postimg.cc/JhZ6VGF3/korm1.png',
  ),
  Category(
    id: 'cat2',
    name: 'Игрушки',
    imageUrl: 'https://i.postimg.cc/W4L8ns4d/igruskka1.jpg',
  ),
  Category(
    id: 'cat3',
    name: 'Уход и гигиена',
    imageUrl: 'https://i.postimg.cc/tJMtVjfC/hair1.jpg',
  ),
  Category(
    id: 'cat4',
    name: 'Одежда',
    imageUrl: 'https://i.postimg.cc/XqmdYgGr/kurt3.jpg',
  ),
];

// ============================================================================
// Товары
// ============================================================================
List<Product> mockProducts = [
  Product(
    id: 'prod1',
    categoryId: 'cat1',
    name: 'Сухой корм для кошек',
    description: 'Сухой корм, 2 кг, для взрослых кошек.',
    price: 2200.0,
    imageUrl: 'https://i.postimg.cc/JhZ6VGF3/korm1.png',
  ),
  Product(
    id: 'prod2',
    categoryId: 'cat1',
    name: 'Влажный корм для собак',
    description: 'Консервы с мясом и овощами, 400 г.',
    price: 580.0,
    imageUrl: 'https://i.postimg.cc/02jV5t3y/korm2.jpg',
  ),
  Product(
    id: 'prod3',
    categoryId: 'cat2',
    name: 'Игрушка "Мышка"',
    description: 'Мягкая игрушка для кошек.',
    price: 800.0,
    imageUrl: 'https://i.postimg.cc/W4L8ns4d/igruskka1.jpg',
  ),
  Product(
    id: 'prod4',
    categoryId: 'cat2',
    name: 'Мячик с пищалкой',
    description: 'Резиновый мячик, пищит.',
    price: 1000.0,
    imageUrl: 'https://i.postimg.cc/8CRHXxFt/igruskka2.jpg',
  ),
  Product(
    id: 'prod5',
    categoryId: 'cat3',
    name: 'Шампунь для собак',
    description: 'Бережный уход за шерстью.',
    price: 1200.0,
    imageUrl: 'https://i.postimg.cc/tJMtVjfC/hair1.jpg',
  ),
  Product(
    id: 'prod6',
    categoryId: 'cat1',
    name: 'Сухой корм для собак',
    description: '3 кг, для взрослых собак.',
    price: 3000.0,
    imageUrl: 'https://i.postimg.cc/HsNBrwD4/korm3.jpg',
  ),
  Product(
    id: 'prod7',
    categoryId: 'cat3',
    name: 'Средство для чистки ушей',
    description: 'Безопасный лосьон для питомцев.',
    price: 1500.0,
    imageUrl: 'https://i.postimg.cc/nh7YMN1p/hair2.jpg',
  ),
  Product(
    id: 'prod8',
    categoryId: 'cat3',
    name: 'Зубная щётка для собак',
    description: 'Для гигиены ротовой полости.',
    price: 700.0,
    imageUrl: 'https://i.postimg.cc/X7tkjnds/hair3.jpg',
  ),
  Product(
    id: 'prod9',
    categoryId: 'cat2',
    name: 'Плюшевая игрушка',
    description: 'Большая мягкая игрушка для собак.',
    price: 2300.0,
    imageUrl: 'https://i.postimg.cc/mDTSvVCR/igruskka3.jpg',
  ),
  Product(
    id: 'prod10',
    categoryId: 'cat4',
    name: 'Курточка для собак',
    description: 'Тёплая куртка, размер M.',
    price: 4500.0,
    imageUrl: 'https://i.postimg.cc/wvxhfMYj/kurt1.jpg',
  ),
  Product(
    id: 'prod11',
    categoryId: 'cat4',
    name: 'Кофточка для кошек',
    description: 'Свитерок для кошек, размер S.',
    price: 2200.0,
    imageUrl: 'https://i.postimg.cc/6qyCKP3s/kurt2.jpg',
  ),
  Product(
    id: 'prod12',
    categoryId: 'cat4',
    name: 'Комбинезон для собак',
    description: 'Лёгкий, для дождливой погоды.',
    price: 3900.0,
    imageUrl: 'https://i.postimg.cc/XqmdYgGr/kurt3.jpg',
  ),
];

// Акции (промо)
final mockPromos = [
  {
    'title': 'Скидка 10% на корма',
    'desc': 'Только до конца недели!',
    'imageUrl': 'https://i.postimg.cc/KvTg5B35/act1.png',
  },
  {
    'title': 'Игрушки 1+1=3',
    'desc': 'Купи две — получи третью в подарок!',
    'imageUrl': 'https://i.postimg.cc/9Qjwg0GH/act2.jpg',
  },
  {
    'title': 'Скидка 15% для постоянных клиентов',
    'desc': 'Подробности уточняйте в профиле',
    'imageUrl': 'https://i.postimg.cc/sg9QkzcQ/act3.webp',
  },
  {
    'title': 'Одежда для питомцев',
    'desc': 'Коллекция осень-зима 2025!',
    'imageUrl': 'https://i.postimg.cc/KY0KY5Cm/act4.png',
  },
];

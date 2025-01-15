import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // для jsonEncode/jsonDecode

// ============================================================================
// МОДЕЛИ
// ============================================================================

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

// ============================================================================
// ФЕЙКОВЫЙ СПИСОК ПОЛЬЗОВАТЕЛЕЙ (синхронизируем с SharedPreferences)
// ============================================================================
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
// Категории (все картинки одинаковые, упрощённо)
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
    name: 'Яблоки',
    imageUrl: 'https://i.postimg.cc/jjNnJKTs/maxresdefault.jpg',
  ),
  Category(
    id: 'cat2',
    name: 'Бананы',
    imageUrl:
        'https://i.postimg.cc/Kj91y8P5/image-processing20201213-1514-12uhdlp.jpg',
  ),
  Category(
    id: 'cat3',
    name: 'Мандарины',
    imageUrl: 'https://i.postimg.cc/DyMSjmyv/6265357744.jpg',
  ),
  Category(
    id: 'cat4',
    name: 'Киви',
    imageUrl: 'https://i.postimg.cc/Kjs8Hsbq/010-018.jpg',
  ),
];

// ============================================================================
// Товары (12 штук), одна картинка
// ============================================================================
List<Product> mockProducts = [
  Product(
    id: 'prod1',
    categoryId: 'cat1',
    name: 'Августовское Желтое',
    description:
        'Августовское Желтое – это один из самых популярных сортов в России. Он получил широкое распространение благодаря своей урожайности, высокой устойчивости к болезням и прекрасным вкусовым качествам.',
    price: 2200.0,
    imageUrl: 'https://i.postimg.cc/GpQrfSJF/avgustovskoe-zheltoe.jpg',
  ),
  Product(
    id: 'prod2',
    categoryId: 'cat1',
    name: 'Алтайская красавица',
    description:
        'Алтайская красавица полностью оправдывает свое название. Сорт весьма декоративен. При этом он радует садоводов высокими урожаями и восхитительным десертным вкусом плодов.',
    price: 580.0,
    imageUrl: 'https://i.postimg.cc/fLRZQjB6/altajskaya-krasavica.jpg',
  ),
  Product(
    id: 'prod3',
    categoryId: 'cat2',
    name: 'Зеленый Банан',
    description: 'Особый сорт бананов, отличающийся особым зеленым цветом',
    price: 800.0,
    imageUrl: 'https://i.postimg.cc/NLhWF1kG/scale-1200.jpg',
  ),
  Product(
    id: 'prod4',
    categoryId: 'cat2',
    name: 'Нендрум',
    description:
        'также называется здесь керальский. Крупный, остроконечный, желтый. Мякоть оранжевая, плотная, почти хрустящая, с твердой сердцевиной. Сладкий, ароматный, с небольшой кислинкой — очень вкусный!',
    price: 1000.0,
    imageUrl:
        'https://i.postimg.cc/jdHsN5w3/1506246654-manfaat-pisang-960x720.jpg',
  ),
  Product(
    id: 'prod5',
    categoryId: 'cat3',
    name: 'Ковано Васе',
    description:
        'Ковано Васе – это популярный комнатный мандарин, который многие выбирают для выращивания в домашних условиях.',
    price: 1200.0,
    imageUrl: 'https://i.postimg.cc/YqH7pHn6/kovano-vase.jpg',
  ),
  Product(
    id: 'prod6',
    categoryId: 'cat1',
    name: 'Альва',
    description:
        'Альва – это интересный и перспективный сорт со своеобразным вкусом и привлекательным внешним видом плодов.',
    price: 3000.0,
    imageUrl: 'https://i.postimg.cc/W4XL8qTS/alva.jpg',
  ),
  Product(
    id: 'prod7',
    categoryId: 'cat3',
    name: 'Муркотт',
    description:
        'Мандарин Муркотт, также известный как Honey tangerine, был создан в 1913 году американскими селекционерами W. T. Swingle, Charles Murcott Smith и J. Ward Smith путем скрещивания мандарина Sweet и танжерина C. reticulata Blanco. Этот сорт является одним из самых популярных видов мандаринов благодаря своей нежной мякоти и сладкому вкусу.',
    price: 1500.0,
    imageUrl: 'https://i.postimg.cc/xT3284hW/murkott.jpg',
  ),
  Product(
    id: 'prod8',
    categoryId: 'cat3',
    name: 'Сентябрьский',
    description:
        'Плоды мандарина имеют округло-плосковатую форму с вдавленной вершиной. Кожура является тонкой, гладкой и имеет ярко-оранжевый цвет. Мякоть плода сочная, нежная и имеет оранжевый цвет. Вкус мандарина сладко-кисловатый, что делает его очень вкусным и популярным среди любителей этого фрукта.',
    price: 700.0,
    imageUrl: 'https://i.postimg.cc/7ZBrMTx9/sentyabrskij.jpg',
  ),
  Product(
    id: 'prod9',
    categoryId: 'cat2',
    name: 'Красный банан',
    description:
        'Крупный, толстый. Шкура очень тонкая и отделяется вместе с верхним слоем мякоти. Мякоть желтая, очень мягкая, сладкая, ароматная.',
    price: 2300.0,
    imageUrl:
        'https://i.postimg.cc/QCprp4tK/af7f91b89c52f9271a86e3f933852bcc.jpg',
  ),
  Product(
    id: 'prod10',
    categoryId: 'cat4',
    name: 'Киви Голд',
    description:
        'Плоды киви Голд имеют средние размеры. Они имеют желто-зеленый оттенок и сладкий вкус со спелой кислинкой. Кожура плода тонкая.',
    price: 4500.0,
    imageUrl: 'https://i.postimg.cc/k4Srm1WY/gold-2.jpg',
  ),
  Product(
    id: 'prod11',
    categoryId: 'cat4',
    name: 'Киви Соло',
    description:
        'Плоды киви крупные, с массой до 50 граммов. Они имеют сладкий вкус и среднепоздний период созревания – октябрь. При этом плоды хранятся достаточно долго после сбора.',
    price: 2200.0,
    imageUrl: 'https://i.postimg.cc/5tTcDdQF/solo-5.jpg',
  ),
  Product(
    id: 'prod12',
    categoryId: 'cat4',
    name: 'Киви Монти',
    description:
        'Плоды киви Монти мелкие, невыровненной формы и темно-коричневого цвета. Их кожура густо опушена мягкими волосками, а мякоть ярко-зеленая. Вкус плода кисло-сладкий, с тонким ароматом ананаса.',
    price: 3900.0,
    imageUrl: 'https://i.postimg.cc/L5krqJCz/monti-1.jpg',
  ),
];

final mockPromos = [
  {
    'title': 'Скидка 10% на яблоки',
    'desc': 'Только до конца недели!',
    'imageUrl': 'https://i.postimg.cc/0N6FYWX5/priority-promotion.png',
  },
  {
    'title': 'Бананы 1+1=3кг',
    'desc': 'Купи два — получи третий в подарок!',
    'imageUrl': 'https://i.postimg.cc/Zq1gV8X8/235810077-1-1.jpg',
  },
  {
    'title': 'Скидка 15% на все мандарины',
    'desc': 'Подробности уточняйте в профиле',
    'imageUrl': 'https://i.postimg.cc/2yYtfzk3/C62-GJEp-Fw6-M.jpg',
  },
  {
    'title': 'Особые скидки на мандарины до 50%',
    'desc': 'Купите мандарины за пол цены!',
    'imageUrl':
        'https://i.postimg.cc/05G30JnS/1626265084-2-kartinkin-com-p-fon-skidki-krasivo-3.jpg',
  },
];

// ============================================================================
// MAIN
// ============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Загружаем пользователей из SharedPreferences
  await loadUsersDbFromPrefs();
  runApp(const MyApp());
}

// ============================================================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserModel? currentUser;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  // Пытаемся авто-логин
  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('savedEmail') ?? '';
    final savedPass = prefs.getString('savedPass') ?? '';
    if (savedEmail.isNotEmpty && savedPass.isNotEmpty) {
      final user = mockUsersDb.firstWhere(
        (u) => u.email == savedEmail && u.password == savedPass,
        orElse: () => UserModel(
          email: '',
          password: '',
          name: '',
          phone: '',
          avatarUrl: '',
          cart: [],
          cardNumber: '',
          cardHolder: '',
          cardExpDate: '',
          address: '',
          orders: [],
        ),
      );
      if (user.email.isNotEmpty) {
        setState(() {
          currentUser = user;
        });
      }
    }
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Banana Store - фрукты',
      theme: ThemeData(
        useMaterial3: true,
        // Меняем основную тему на желтую
        colorSchemeSeed: Colors.amber,
      ),
      home: currentUser == null
          ? LoginScreen(
              onLoginSuccess: (user, rememberMe) async {
                setState(() {
                  currentUser = user;
                });
                final prefs = await SharedPreferences.getInstance();
                if (rememberMe) {
                  prefs.setString('savedEmail', user.email);
                  prefs.setString('savedPass', user.password);
                } else {
                  prefs.remove('savedEmail');
                  prefs.remove('savedPass');
                }
              },
            )
          : MainScreen(
              currentUser: currentUser!,
              onLogout: () async {
                setState(() {
                  currentUser = null;
                });
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('savedEmail');
                prefs.remove('savedPass');
              },
            ),
    );
  }
}

// ============================================================================
// ЛОГИН
// ============================================================================
class LoginScreen extends StatefulWidget {
  final void Function(UserModel user, bool rememberMe) onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _rememberMe = false;

  String? _errorMsg;

  void _login() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() {
        _errorMsg = 'Введите email и пароль';
      });
      return;
    }
    final user = mockUsersDb.firstWhere(
      (u) => u.email == email && u.password == pass,
      orElse: () => UserModel(
        email: '',
        password: '',
        name: '',
        phone: '',
        avatarUrl: '',
        cart: [],
        cardNumber: '',
        cardHolder: '',
        cardExpDate: '',
        address: '',
        orders: [],
      ),
    );
    if (user.email.isEmpty) {
      setState(() {
        _errorMsg = 'Неверный email или пароль';
      });
    } else {
      widget.onLoginSuccess(user, _rememberMe);
    }
  }

  void _goRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(
          onRegisterSuccess: (newUser, rememberMe) {
            widget.onLoginSuccess(newUser, rememberMe);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Градиент + карточка (заменили цветовую гамму на желтую)
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF9C4), Color(0xFFFFF59D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                color: Colors.white.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        // Сделаем кружок более "банановым"
                        backgroundColor: Colors.orange,
                        child: const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Вход',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscurePass,
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Меняем иконку на коричневую/оранжевую
                              Icons.visibility,
                              color: Colors.orange,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePass = !_obscurePass;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val ?? false;
                              });
                            },
                          ),
                          const Text('Запомнить меня'),
                        ],
                      ),
                      if (_errorMsg != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMsg!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _login,
                        icon: const Icon(Icons.login),
                        label: const Text('Войти'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _goRegister,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Создать аккаунт'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// РЕГИСТРАЦИЯ
// ============================================================================
class RegisterScreen extends StatefulWidget {
  final void Function(UserModel, bool) onRegisterSuccess;

  const RegisterScreen({super.key, required this.onRegisterSuccess});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _rememberMe = false;
  String? _errorMsg;

  void _register() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final pass2 = _pass2Ctrl.text.trim();

    if (name.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        pass.isEmpty ||
        pass2.isEmpty) {
      setState(() {
        _errorMsg = 'Заполните все поля';
      });
      return;
    }
    if (!email.contains('@')) {
      setState(() {
        _errorMsg = 'Некорректный email';
      });
      return;
    }
    if (pass != pass2) {
      setState(() {
        _errorMsg = 'Пароли не совпадают';
      });
      return;
    }
    // Проверка наличия
    final alreadyExists = mockUsersDb.any((u) => u.email == email);
    if (alreadyExists) {
      setState(() {
        _errorMsg = 'Пользователь с таким email уже существует';
      });
      return;
    }

    final newUser = UserModel(
      email: email,
      password: pass,
      name: name,
      phone: phone,
      avatarUrl: '',
      cart: [],
      cardNumber: '',
      cardHolder: '',
      cardExpDate: '',
      address: '',
      orders: [],
    );
    mockUsersDb.add(newUser);
    await saveUsersDbToPrefs();

    widget.onRegisterSuccess(newUser, _rememberMe);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Градиент заменили на желтые оттенки
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF59D), Color(0xFFFFF176)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Регистрация'),
          backgroundColor: Colors.orange.withOpacity(0.6),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: Colors.white.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Создание аккаунта',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Имя',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Телефон',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure1,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure1 ? Icons.visibility : Icons.visibility_off,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscure1 = !_obscure1;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _pass2Ctrl,
                      obscureText: _obscure2,
                      decoration: InputDecoration(
                        labelText: 'Повторите пароль',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure2 ? Icons.visibility : Icons.visibility_off,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscure2 = !_obscure2;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? false;
                            });
                          },
                        ),
                        const Text('Запомнить меня'),
                      ],
                    ),
                    if (_errorMsg != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMsg!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _register,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Зарегистрироваться'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MAIN SCREEN (BOTTOM NAV)
class MainScreen extends StatefulWidget {
  final UserModel currentUser;
  final VoidCallback onLogout;

  const MainScreen(
      {super.key, required this.currentUser, required this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      CategoriesPage(currentUser: widget.currentUser),
      CartPage(currentUser: widget.currentUser),
      ProfilePage(user: widget.currentUser),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Категории',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Профиль',
          ),
        ],
      ),
      // Меняем название AppBar на Banana Store
      appBar: AppBar(
        title: const Text('Banana Store'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: 'Выйти',
          ),
        ],
        backgroundColor: Colors.orange, // Верх AppBar тоже в желто-оранжевых тонах
      ),
    );
  }
}

// ============================================================================
// HOME PAGE (со *минималистичной* анимацией Fade)
class HomePage extends StatefulWidget {
  HomePage({super.key});

  final List<Map<String, String>> promos = mockPromos;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Верх: fade-анимация текста "Добро пожаловать в Banana Store"
    // Ниже: прокрутка акций
    return Container(
      decoration: const BoxDecoration(
        // Меняем градиент на желтый
        gradient: LinearGradient(
          colors: [Color(0xFFFFF9C4), Color(0xFFFFF59D), Color(0xFFFFF176)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _fadeAnim,
              child: Text(
                'Добро пожаловать в\nBanana Store',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.promos.length,
                itemBuilder: (context, index) {
                  final promo = widget.promos[index];
                  return Card(
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 6,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        if (promo['imageUrl'] != null)
                          Ink.image(
                            image: NetworkImage(promo['imageUrl']!),
                            fit: BoxFit.cover,
                            height: 200,
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_offer,
                                // Цвет иконки - оранжевый
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  promo['title'] ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (promo['desc'] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, size: 18),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    promo['desc'] ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// КАТЕГОРИИ
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

// ============================================================================
// СПИСОК ТОВАРОВ + ПОИСК ВНУТРИ КАТЕГОРИИ
// ============================================================================
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
  late List<Product> _filteredProducts;

  @override
  void initState() {
    super.initState();
    // Сначала в списке все товары данной категории
    _filteredProducts =
        mockProducts.where((p) => p.categoryId == widget.category.id).toList();

    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  // Обработка изменений поля поиска
  void _onSearchChanged() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        // Если поле пустое, показываем все товары категории
        _filteredProducts = mockProducts
            .where((p) => p.categoryId == widget.category.id)
            .toList();
      } else {
        // Иначе фильтруем по названию (name)
        _filteredProducts = mockProducts
            .where((p) =>
                p.categoryId == widget.category.id &&
                p.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Добавим AppBar с полем поиска (зальем его цветом оранжевым)
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Поиск...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _filteredProducts.isEmpty
          ? Center(
              child: Text(
                'Товаров нет :(',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ProductCard(
                  product: product,
                  currentUser: widget.currentUser,
                );
              },
            ),
    );
  }
}

// ============================================================================
// КАРТОЧКА ТОВАРА (на гриде)
class ProductCard extends StatelessWidget {
  final Product product;
  final UserModel currentUser;
  const ProductCard(
      {super.key, required this.product, required this.currentUser});

  void _showProductDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ProductDetailsDialog(
        product: product,
        currentUser: currentUser,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showProductDetails(context),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Text(
                '${product.price.toStringAsFixed(0)} тг',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// МОДАЛЬ: Детали товара
class ProductDetailsDialog extends StatelessWidget {
  final Product product;
  final UserModel currentUser;
  const ProductDetailsDialog(
      {super.key, required this.product, required this.currentUser});

  void _addToCart(BuildContext context) async {
    currentUser.cart.add(product);
    await saveUsersDbToPrefs();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Товар "${product.name}" добавлен в корзину')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(product.description),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'Цена: ${product.price.toStringAsFixed(0)} тг',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ElevatedButton.icon(
                onPressed: () => _addToCart(context),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Добавить в корзину'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// КОРЗИНА
// ============================================================================
class CartPage extends StatefulWidget {
  final UserModel currentUser;
  const CartPage({super.key, required this.currentUser});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get totalPrice {
    return widget.currentUser.cart.fold(0.0, (sum, p) => sum + p.price);
  }

  void _removeItem(Product product) async {
    setState(() {
      widget.currentUser.cart.remove(product);
    });
    await saveUsersDbToPrefs();
  }

  void _checkout() async {
    if (widget.currentUser.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Корзина пуста!')),
      );
      return;
    }
    final result = await showDialog<String>(
      context: context,
      builder: (_) => CheckoutDialog(user: widget.currentUser),
    );
    if (result == 'ok') {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.currentUser.cart;
    if (cartItems.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Ваша корзина пуста'),
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cartItems.length,
        itemBuilder: (ctx, i) {
          final product = cartItems[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Картинка слева
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                // Описание
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${product.price.toStringAsFixed(0)} тг',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeItem(product),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок "Итого:"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Итого:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${totalPrice.toStringAsFixed(0)} тг',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _checkout,
              icon: const Icon(Icons.check_circle),
              label: const Text('Оформить'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ЧЕКАУТ (с бизнес-логикой акций) 
class CheckoutDialog extends StatefulWidget {
  final UserModel user;
  const CheckoutDialog({super.key, required this.user});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  Future<void> _pickup() async {
    double sum = widget.user.cart.fold(0.0, (s, p) => s + p.price);

    // Логика акций:
    // 1) Если есть товар из cat2 ("Игрушки") => -10%
    // (Согласно исходному коду, cat2 — "Бананы",
    //  но оставляем как есть, ничего лишнего не трогаем)
    final hasToys = widget.user.cart.any((p) => p.categoryId == 'cat2');
    if (hasToys) {
      sum *= 0.9;
    }
    // 2) Если sum > 5000 => ещё -5%
    if (sum > 5000) {
      sum *= 0.95;
    }

    final order = OrderModel(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      items: [...widget.user.cart],
      total: sum,
      address: 'Самовывоз',
      status: 'Готов к самовывозу',
    );
    widget.user.orders.add(order);
    widget.user.cart.clear();
    await saveUsersDbToPrefs();

    Navigator.pop(context, 'ok');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Заказ (самовывоз) оформлен!\nИтог: ${sum.toStringAsFixed(0)} тг (с учётом акций)',
        ),
      ),
    );
  }

  Future<void> _delivery() async {
    // Перед доставкой — покажем форму
    await showDialog(
      context: context,
      builder: (_) => DeliveryFormDialog(user: widget.user),
    );

    double sum = widget.user.cart.fold(0.0, (s, p) => s + p.price);

    // Логика акций (та же)
    final hasToys = widget.user.cart.any((p) => p.categoryId == 'cat2');
    if (hasToys) {
      sum *= 0.9;
    }
    if (sum > 5000) {
      sum *= 0.95;
    }

    final order = OrderModel(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      items: [...widget.user.cart],
      total: sum,
      address: widget.user.address.isNotEmpty ? widget.user.address : '...',
      status: 'В пути',
    );
    widget.user.orders.add(order);
    widget.user.cart.clear();
    await saveUsersDbToPrefs();

    Navigator.pop(context, 'ok');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Заказ (доставка) оформлен!\nИтог: ${sum.toStringAsFixed(0)} тг (с учётом акций)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выберите способ получения'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.store_mall_directory),
            title: const Text('Самовывоз'),
            onTap: _pickup,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text('Доставка'),
            onTap: _delivery,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ФОРМА ДОСТАВКИ
class DeliveryFormDialog extends StatefulWidget {
  final UserModel user;
  const DeliveryFormDialog({super.key, required this.user});

  @override
  State<DeliveryFormDialog> createState() => _DeliveryFormDialogState();
}

class _DeliveryFormDialogState extends State<DeliveryFormDialog> {
  final _addressCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _cardHolderCtrl = TextEditingController();
  final _cardExpCtrl = TextEditingController();

  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _addressCtrl.text = widget.user.address;
    _cardNumberCtrl.text = widget.user.cardNumber;
    _cardHolderCtrl.text = widget.user.cardHolder;
    _cardExpCtrl.text = widget.user.cardExpDate;
  }

  Future<void> _confirm() async {
    final address = _addressCtrl.text.trim();
    final cardNum = _cardNumberCtrl.text.trim();
    final cardHolder = _cardHolderCtrl.text.trim();
    final cardExp = _cardExpCtrl.text.trim();

    if (address.isEmpty) {
      setState(() {
        _errorMsg = 'Введите адрес доставки';
      });
      return;
    }
    if (cardNum.isEmpty || cardHolder.isEmpty || cardExp.isEmpty) {
      setState(() {
        _errorMsg = 'Заполните данные карты';
      });
      return;
    }
    widget.user.address = address;
    widget.user.cardNumber = cardNum;
    widget.user.cardHolder = cardHolder;
    widget.user.cardExpDate = cardExp;
    await saveUsersDbToPrefs();

    Navigator.pop(context, 'ok');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Доставка и оплата'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Адрес',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cardNumberCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Номер карты',
                prefixIcon: Icon(Icons.credit_card),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cardHolderCtrl,
              decoration: const InputDecoration(
                labelText: 'Владелец карты',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cardExpCtrl,
              decoration: const InputDecoration(
                labelText: 'Срок действия (MM/YY)',
                prefixIcon: Icon(Icons.date_range),
              ),
            ),
            if (_errorMsg != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMsg!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton.icon(
          onPressed: _confirm,
          icon: const Icon(Icons.done),
          label: const Text('Подтвердить'),
        ),
      ],
    );
  }
}

// ============================================================================
// ПРОФИЛЬ
class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// Маски (для карты)
String maskCardNumber(String cardNumber) {
  if (cardNumber.isEmpty) return 'Не указана';
  if (cardNumber.length <= 4) return '****';
  final visible = cardNumber.substring(cardNumber.length - 4);
  final hiddenCount = cardNumber.length - 4;
  final stars = List.filled(hiddenCount, '*').join();
  String grouped = '';
  for (int i = 0; i < stars.length; i++) {
    if (i > 0 && i % 4 == 0) grouped += ' ';
    grouped += stars[i];
  }
  return '$grouped $visible';
}

String maskExpDate(String exp) {
  if (exp.isEmpty) return 'Не указана';
  return '**/**';
}

class _ProfilePageState extends State<ProfilePage> {
  void _changePassword() async {
    await showDialog(
      context: context,
      builder: (_) => ChangePasswordDialog(user: widget.user),
    );
    setState(() {});
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => OrderDetailsDialog(order: order),
    );
  }

  void _changeAvatar() async {
    final urlCtrl = TextEditingController(text: widget.user.avatarUrl);

    final newUrl = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Изменить аватарку'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ссылка на аватарку (URL)',
                  prefixIcon: Icon(Icons.image),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, urlCtrl.text.trim());
              },
              icon: const Icon(Icons.save),
              label: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (newUrl != null && newUrl.isNotEmpty) {
      widget.user.avatarUrl = newUrl;
      await saveUsersDbToPrefs();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF9C4), Color(0xFFFFF59D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Card(
            color: Colors.white.withOpacity(0.9),
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Аватар
                    InkWell(
                      onTap: _changeAvatar,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.orange,
                        backgroundImage: (user.avatarUrl.isNotEmpty)
                            ? NetworkImage(user.avatarUrl)
                            : null,
                        child: (user.avatarUrl.isEmpty)
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name.isNotEmpty ? user.name : '(Без имени)',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          user.phone.isNotEmpty ? user.phone : '-',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.email_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          user.email,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _changePassword,
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Изменить пароль'),
                    ),
                    const Divider(height: 32),
                    // Данные карты
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: const [
                          Icon(Icons.credit_card, color: Colors.orange),
                          SizedBox(width: 6),
                          Text(
                            'Данные карты:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.cardNumber.isNotEmpty
                          ? maskCardNumber(user.cardNumber)
                          : 'Карта не указана',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (user.cardHolder.isNotEmpty)
                      Text(
                        'Владелец: ${user.cardHolder}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    if (user.cardExpDate.isNotEmpty)
                      Text(
                        'Срок действия: ${maskExpDate(user.cardExpDate)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    const Divider(height: 32),
                    // Заказы
                    if (user.orders.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: const [
                            Icon(Icons.list_alt, color: Colors.orange),
                            SizedBox(width: 6),
                            Text(
                              'Мои заказы:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: user.orders.reversed.map((order) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                'Заказ #${order.id}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${order.status} — ${order.total.toStringAsFixed(0)} тг\n${order.createdAt.toLocal()}',
                              ),
                              onTap: () => _showOrderDetails(order),
                            ),
                          );
                        }).toList(),
                      ),
                    ] else
                      const Text('Заказов пока нет'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// МОДАЛЬ: Детали заказа
class OrderDetailsDialog extends StatelessWidget {
  final OrderModel order;
  const OrderDetailsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Заказ #${order.id}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Дата: ${order.createdAt}'),
            const SizedBox(height: 6),
            Text('Статус: ${order.status}'),
            const SizedBox(height: 6),
            Text('Адрес: ${order.address}'),
            const SizedBox(height: 6),
            Text('Сумма: ${order.total.toStringAsFixed(0)} тг'),
            const Divider(),
            const SizedBox(height: 6),
            const Text('Товары в заказе:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                      '- ${item.name} (${item.price.toStringAsFixed(0)} тг)'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}

// ============================================================================
// DIALOG: Изменить пароль
class ChangePasswordDialog extends StatefulWidget {
  final UserModel user;
  const ChangePasswordDialog({super.key, required this.user});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _newPass2Ctrl = TextEditingController();

  String? _errorMsg;
  bool _obscureOld = true;
  bool _obscureNew1 = true;
  bool _obscureNew2 = true;

  void _save() async {
    final oldPass = _oldPassCtrl.text.trim();
    final newPass = _newPassCtrl.text.trim();
    final newPass2 = _newPass2Ctrl.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || newPass2.isEmpty) {
      setState(() {
        _errorMsg = 'Заполните все поля';
      });
      return;
    }
    if (oldPass != widget.user.password) {
      setState(() {
        _errorMsg = 'Старый пароль неверный';
      });
      return;
    }
    if (newPass != newPass2) {
      setState(() {
        _errorMsg = 'Новые пароли не совпадают';
      });
      return;
    }
    if (newPass.length < 4) {
      setState(() {
        _errorMsg = 'Слишком короткий пароль (мин. 4 символа)';
      });
      return;
    }

    widget.user.password = newPass;
    await saveUsersDbToPrefs();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Пароль успешно изменён')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Изменить пароль'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Старый
            TextField(
              controller: _oldPassCtrl,
              obscureText: _obscureOld,
              decoration: InputDecoration(
                labelText: 'Старый пароль',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureOld ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureOld = !_obscureOld;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Новый
            TextField(
              controller: _newPassCtrl,
              obscureText: _obscureNew1,
              decoration: InputDecoration(
                labelText: 'Новый пароль',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureNew1 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureNew1 = !_obscureNew1;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Повтор
            TextField(
              controller: _newPass2Ctrl,
              obscureText: _obscureNew2,
              decoration: InputDecoration(
                labelText: 'Повторите новый пароль',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureNew2 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureNew2 = !_obscureNew2;
                    });
                  },
                ),
              ),
            ),
            if (_errorMsg != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMsg!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('Сохранить'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class StoreScreen extends StatefulWidget {
  final String token;

  const StoreScreen({Key? key, required this.token}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Screen'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Добро пожаловать в Store Screen!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Логика для действия 1
                print('Действие 1 выполнено!');
              },
              child: const Text('Действие 1'),
            ),
            ElevatedButton(
              onPressed: () {
                // Логика для действия 2
                print('Действие 2 выполнено!');
              },
              child: const Text('Действие 2'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StoreScreen(token: 'dummyToken'),
    );
  }
}

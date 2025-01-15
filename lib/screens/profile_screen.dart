import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../screens/dialogs/change_password_dialog.dart';
import '../screens/dialogs/order_details_dialog.dart';
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

class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
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
      await widget.user.saveToDb(); // не забудем поправить (см. ниже)
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
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
                        backgroundColor: Colors.deepPurple,
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
                          Icon(Icons.credit_card, color: Colors.deepPurple),
                          SizedBox(width: 6),
                          Text(
                            'Данные карты:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
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
                            Icon(Icons.list_alt, color: Colors.deepPurple),
                            SizedBox(width: 6),
                            Text(
                              'Мои заказы:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
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
                                style: const TextStyle(fontWeight: FontWeight.bold),
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

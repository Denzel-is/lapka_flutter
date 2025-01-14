import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../data/mock_data.dart';
import 'delivery_form_dialog.dart';

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
    // Перед доставкой покажем форму
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
      address:
      widget.user.address.isNotEmpty ? widget.user.address : '...',
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

import 'package:flutter/material.dart';

import '../../../models/order_model.dart';

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
            const Text(
              'Товары в заказе:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '- ${item.name} (${item.price.toStringAsFixed(0)} тг)',
                  ),
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

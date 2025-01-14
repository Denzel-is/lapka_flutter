import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../data/mock_data.dart';

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

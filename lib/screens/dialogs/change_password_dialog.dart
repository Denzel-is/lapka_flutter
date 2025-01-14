import 'package:flutter/material.dart';

import '../../../models/user_model.dart';
import '../../../data/mock_data.dart';

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
      const SnackBar(
        content: Text('Пароль успешно изменён'),
      ),
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
            // Старый пароль
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
            // Новый пароль
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
            // Повтор нового пароля
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

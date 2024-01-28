import 'package:flutter/material.dart';
import 'usermodel.dart';

class UserProfDialog extends StatelessWidget {
  final UserModel user;
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  UserProfDialog({required this.user}) {
    nameController.text = user.name;
    emailController.text = user.email;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'ユーザー情報',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '名前：',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Eメール：',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('更新'),
              onPressed: () {
                user.updateProfile(nameController.text, user.email);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

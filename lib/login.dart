import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'usermodel.dart';

class LoginPage extends ConsumerStatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _emailError = ''; // Emailのエラーメッセージ
  String _passwordError = ''; // パスワードのエラーメッセージ

  void _signIn() async {
    // 入力チェック
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _emailError = _emailController.text.isEmpty ? 'Emailを入力してください。' : '';
        _passwordError =
            _passwordController.text.isEmpty ? 'パスワードを入力してください。' : '';
      });
      return; // 早期リターン
    }

    try {
      await ref.read(userModelProvider.notifier).signIn(
            _emailController.text,
            _passwordController.text,
          );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _emailError = '';
        _passwordError = '';
        // FirebaseAuthのエラーメッセージを適切なフィールドに設定
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          _emailError = 'Emailまたはパスワードが間違っています。';
        } else {
          _emailError = e.message ?? 'ログインに失敗しました。';
        }
      });
    } catch (e) {
      setState(() {
        _emailError = '';
        _passwordError = '予期せぬエラーが発生しました。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Image.asset('assets/images/icon.png',
                fit: BoxFit.cover), // アイコンを表示
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: _emailError.isEmpty
                          ? null
                          : _emailError, // エラーメッセージを設定
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: _passwordError.isEmpty
                          ? null
                          : _passwordError, // エラーメッセージを設定
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _signIn,
                    child: const Text('ログイン'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

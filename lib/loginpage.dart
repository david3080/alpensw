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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/icon.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Eメール',
                      border: const OutlineInputBorder(),
                      errorText: _emailError.isEmpty ? null : _emailError,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'パスワード',
                      border: const OutlineInputBorder(),
                      errorText: _passwordError.isEmpty ? null : _passwordError,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // 角度を調整
                            ),
                          ),
                          onPressed: _signIn,
                          child: const Text('ログイン'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // 角度を調整
                            ),
                          ),
                          onPressed: _signInAnonymously,
                          child: const Text('匿名ﾛｸﾞｲﾝ'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  void _signInAnonymously() async {
    try {
      await ref.read(userModelProvider.notifier).anonSignIn();
    } catch (e) {
      setState(() {
        _emailError = '';
        _passwordError = '匿名ログインに失敗しました。';
      });
    }
  }
}

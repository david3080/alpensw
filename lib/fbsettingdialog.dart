import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebaseholder.dart';

class FBSettingsDialog extends StatelessWidget {
  final firebaseHolder = FirebaseHolder();
  final _apiKeyController = TextEditingController();
  final _authDomainController = TextEditingController();
  final _projectIdController = TextEditingController();
  final _messagingSenderIdController = TextEditingController();
  final _appIdController = TextEditingController();

  void _saveOptions() async {
    final options = FirebaseOptions(
      apiKey: _apiKeyController.text,
      authDomain: _authDomainController.text,
      projectId: _projectIdController.text,
      messagingSenderId: _messagingSenderIdController.text,
      appId: _appIdController.text,
    );
    await FirebaseHolder().saveFirebaseOptions(options);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseHolder().loadFirebaseOptions(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          FirebaseOptions options = snapshot.data;
          _apiKeyController.text = options.apiKey;
          _authDomainController.text = options.authDomain ?? '';
          _projectIdController.text = options.projectId;
          _messagingSenderIdController.text = options.messagingSenderId;
          _appIdController.text = options.appId;

          return AlertDialog(
            title: const Text('Firebase Options'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(hintText: 'API Key'),
                  ),
                  TextField(
                    controller: _authDomainController,
                    decoration: const InputDecoration(hintText: 'Auth Domain'),
                  ),
                  TextField(
                    controller: _projectIdController,
                    decoration: const InputDecoration(hintText: 'Project ID'),
                  ),
                  TextField(
                    controller: _messagingSenderIdController,
                    decoration:
                        const InputDecoration(hintText: 'Messaging Sender ID'),
                  ),
                  TextField(
                    controller: _appIdController,
                    decoration: const InputDecoration(hintText: 'App ID'),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _saveOptions();
                  Navigator.of(context).pop();
                },
                child: const Text('保存'),
              ),
            ],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

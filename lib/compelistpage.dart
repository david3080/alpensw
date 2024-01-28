import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'usermodel.dart';
import 'stopwatchpage.dart';

class CompeListPage extends ConsumerStatefulWidget {
  @override
  _CompeListPageState createState() => _CompeListPageState();
}

class _CompeListPageState extends ConsumerState<CompeListPage> {
  final _formKey = GlobalKey<FormState>();
  int num = 1;

  @override
  Widget build(BuildContext context) {
    final userModel = ref.watch(userModelProvider.notifier);
    userModel.readCompes();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '測定リスト',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
          onPressed: () {
            ref.read(userModelProvider.notifier).signOut();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {
              final nameCtrl = TextEditingController();
              final emailCtrl = TextEditingController();
              // ユーザ情報を取得
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userModel.email)
                  .get()
                  .then((doc) {
                if (doc.exists) {
                  nameCtrl.text = doc.data()?['name'] ?? '';
                  emailCtrl.text = doc.data()?['email'] ?? '';
                }
              });
              showDialog(
                context: context,
                builder: (context) {
                  return _buildEditUserProfDialog(
                    context,
                    nameCtrl,
                    emailCtrl,
                    ref,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        itemCount: userModel.compes?.length ?? 0,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          final compe = userModel.compes![index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StopwatchPage(compe: compe),
                ),
              );
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('測定名: ${compe.name}'),
                    Text('測定メモ: ${compe.memo}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final nameCtrl = TextEditingController();
          final memoCtrl = TextEditingController();
          showDialog(
            context: context,
            builder: (context) {
              return _buildAddCompeDialog(
                context,
                nameCtrl,
                memoCtrl,
                ref,
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAddCompeDialog(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController memoController,
    WidgetRef ref,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '新規の測定エリアを追加',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '測定名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '測定名を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: memoController,
                decoration: const InputDecoration(
                  labelText: '備考',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButton<int>(
                value: num,
                onChanged: (int? newValue) {
                  setState(() {
                    num = newValue!;
                  });
                },
                items: List<int>.generate(10, (i) => i + 1)
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final compe = Compe(
                      id: '',
                      name: nameController.text,
                      memo: memoController.text,
                      num: num,
                    );
                    ref.read(userModelProvider.notifier).addCompe(compe);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('追加'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditUserProfDialog(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController emailController,
    WidgetRef ref,
  ) {
    final user = ref.read(userModelProvider.notifier);

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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'stopwatchpage.dart';
import 'firebaseholder.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  //debugPaintSizeEnabled = true;
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseHolder firebaseHolder = FirebaseHolder();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'アルペンストップウォッチ',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Colors.blue),
      ),
      home: StopwatchPage(),
    );
  }
}

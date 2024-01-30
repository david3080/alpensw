import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'compelistpage.dart';
import 'firebaseholder.dart';
import 'usermodel.dart';
import 'loginpage.dart';
import 'package:flutter/rendering.dart';

void main() async {
  debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseHolder().loadFirebaseOptions());
  } else {
    await Firebase.initializeApp();
  }

  // 画面向きを縦長に固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      title: 'アルペンストップウォッチ',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Colors.blue),
      ),
      home:
          ref.watch(userModelProvider).loggedIn ? CompeListPage() : LoginPage(),
    );
  }
}

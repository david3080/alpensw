import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FirebaseHolder {
  // シングルトンでインスタンスを生成し、Futureを返す
  static final FirebaseHolder _singleton = FirebaseHolder._internal();
  factory FirebaseHolder() => _singleton;
  FirebaseHolder._internal();

  // Hiveに保存されたFirebaseOptionsを読み込んでfirebaseOptionsにセット
  // 初回の場合はinitSettingsをセット
  Future<FirebaseOptions> loadFirebaseOptions() async {
    var box = await Hive.openBox('firebaseOptions');
    var map = box.get('options') as Map<dynamic, dynamic>?;
    FirebaseOptions options;
    if (map != null) {
      options = _createFirebaseOptionsFromMap(map.cast<String, dynamic>());
    } else {
      options = _createFirebaseOptionsFromMap(initSettings);
    }
    return options;
  }

  // HiveにFirebaseOptionsのMapを保存
  Future<void> saveFirebaseOptions([FirebaseOptions? options]) async {
    options ??= await loadFirebaseOptions();
    var box = await Hive.openBox('firebaseOptions');
    await box.put('options', _createMapFromFirebaseOptions(options));
  }

  // FirebaseOptionsインスタンスをMapに変換して返却
  Map<String, dynamic> _createMapFromFirebaseOptions(FirebaseOptions options) {
    return {
      'apiKey': options.apiKey,
      'authDomain': options.authDomain,
      'databaseURL': options.databaseURL,
      'projectId': options.projectId,
      'storageBucket': options.storageBucket,
      'messagingSenderId': options.messagingSenderId,
      'appId': options.appId,
      'measurementId': options.measurementId,
    };
  }

  // MapからFirebaseOptionsを作成して返却
  FirebaseOptions _createFirebaseOptionsFromMap(Map<String, dynamic> map) {
    return FirebaseOptions(
      apiKey: map['apiKey'] ?? '',
      authDomain: map['authDomain'] ?? '',
      databaseURL: map['databaseURL'] ?? '',
      projectId: map['projectId'] ?? '',
      storageBucket: map['storageBucket'] ?? '',
      messagingSenderId: map['messagingSenderId'] ?? '',
      appId: map['appId'] ?? '',
      measurementId: map['measurementId'] ?? '',
    );
  }

  // アプリ利用者がFirebase環境を用意して使ってもらうことを推奨するが
  // 大垣スキー協会向けに株式会社リーサのFirebase環境を初期値として設定
  Map<String, dynamic> initSettings = {
    "apiKey": "zaSyANfPmC6VvYLXRfm7E5LzrhjSuxQU1LwmI",
    "authDomain": "skitimer-ccf47.firebaseapp.com",
    "projectId": "skitimer-ccf47",
    "messagingSenderId": "122677786024",
    "appId": "1:122677786024:web:94df9476d6bb5ea43e599d",
  };
}

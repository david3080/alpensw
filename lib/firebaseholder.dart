import 'package:firebase_core/firebase_core.dart';

class FirebaseHolder {
  // シングルトンでインスタンスを生成し、Futureを返す
  static final FirebaseHolder _singleton = FirebaseHolder._internal();
  factory FirebaseHolder() => _singleton;
  FirebaseHolder._internal();

  // 初回の場合はinitSettingsをセット
  FirebaseOptions loadFirebaseOptions() {
    return _createFirebaseOptionsFromMap(initSettings);
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
    "apiKey": "AIzaSyANfPmC6VvYLXRfm7E5LzrhjSuxQU1LwmI",
    "authDomain": "skitimer-ccf47.firebaseapp.com",
    "projectId": "skitimer-ccf47",
    "messagingSenderId": "122677786024",
    "appId": "1:122677786024:web:94df9476d6bb5ea43e599d",
  };
}

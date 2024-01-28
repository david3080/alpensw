import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final userModelProvider =
    StateNotifierProvider<UserModel, UserModelState>((ref) => UserModel());

class UserModelState {
  final String name;
  final String email;
  final bool loggedIn;
  final List<Compe>? compes;
//  Compe? compe;

  UserModelState({
    required this.name,
    required this.email,
    required this.loggedIn,
    this.compes,
//    this.compe,
  });
}

class UserModel extends StateNotifier<UserModelState> {
  UserModel()
      : super(
          UserModelState(
            name: '',
            email: '',
            loggedIn: false,
          ),
        );

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get name => state.name;
  String get email => state.email;
//  Compe? get compe => state.compe;
  List<Compe>? get compes => state.compes;

  set compe(Compe? compe) {
    state = UserModelState(
      name: state.name,
      email: state.email,
      loggedIn: state.loggedIn,
      compes: state.compes,
//      compe: compe,
    );
  }

  Future<void> signIn(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await manageUserDoc(userCredential);
  }

  Future<void> anonSignIn() async {
    UserCredential userCredential = await _auth.signInAnonymously();
    await manageUserDoc(userCredential);
  }

  Future<void> manageUserDoc(UserCredential userCredential) async {
    final email = userCredential.user!.email ?? 'anon';
    final userDoc = _firestore.collection('users').doc(email);

    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists) {
      // ドキュメントが存在する場合、そのデータを使用します。
      final data = docSnapshot.data() as Map<String, dynamic>;
      state = UserModelState(
        name: data['name'] as String,
        email: data['email'] as String,
        loggedIn: true,
      );
    } else {
      // ドキュメントが存在しない場合、新しいドキュメントを作成します。
      await userDoc.set({
        'uid': email,
        'name': '',
        'email': email,
      });
      state = UserModelState(
        name: '',
        email: email,
        loggedIn: true,
      );
    }
  }

  Future<void> readCompes() async {
    final userDoc = _firestore.collection('users').doc(state.email);
    final compesSnapshot = await userDoc.collection('compes').get();
    if (compesSnapshot.docs.isNotEmpty) {
      final newCompes =
          compesSnapshot.docs.map((doc) => Compe.fromMap(doc.data())).toList();
      state = UserModelState(
        name: state.name,
        email: state.email,
        loggedIn: state.loggedIn,
        compes: newCompes,
      );
    }
  }

  Compe readCompe(int compeId) {
    return state.compes![compeId];
  }

  Future<void> addCompe(Compe compe) async {
    final userDoc = _firestore.collection('users').doc(state.email);
    DocumentReference docRef =
        await userDoc.collection('compes').add(compe.toMap());

    // Firestoreから生成されたドキュメントIDを取得
    String docId = docRef.id;

    // CompeオブジェクトのidにドキュメントIDをセット
    Compe updatedCompe = compe.copyWith(id: docId);

    // 更新したCompeオブジェクトを再度Firestoreに保存
    await docRef.set(updatedCompe.toMap());

    final newCompes = List<Compe>.from(state.compes ?? []);
    newCompes.add(updatedCompe);
    state = UserModelState(
      name: state.name,
      email: state.email,
      loggedIn: state.loggedIn,
      compes: newCompes,
    );
  }

  Future<void> deleteCompe(String compeId) async {
    final userDoc = _firestore.collection('users').doc(state.email);
    await userDoc.collection('compes').doc(compeId).delete();
    final List<Compe> newCompes = List<Compe>.from(state.compes ?? []);
    newCompes.removeWhere((compe) => compe.id == compeId);
    state = UserModelState(
      name: state.name,
      email: state.email,
      loggedIn: state.loggedIn,
      compes: newCompes,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = UserModelState(
      name: '',
      email: '',
      loggedIn: false,
    );
  }

  Future<void> updateProfile(String name, String email) async {
    final userDoc = _firestore.collection('users').doc(state.email);
    await userDoc.update({'name': name});
    state = UserModelState(
      name: name,
      email: email,
      loggedIn: state.loggedIn,
    );
  }
}

class Compe {
  final String id;
  final String name;
  final String memo;
  final int num;

  Compe({
    required this.id,
    required this.name,
    required this.memo,
    required this.num,
  });

  Compe copyWith({
    String? id,
    String? name,
    String? memo,
    int? num,
  }) {
    return Compe(
      id: id ?? this.id,
      name: name ?? this.name,
      memo: memo ?? this.memo,
      num: num ?? this.num,
    );
  }

  factory Compe.fromMap(Map<String, dynamic> map) {
    return Compe(
      id: map['id'],
      name: map['name'],
      memo: map['memo'],
      num: map['num'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'memo': memo,
      'num': num,
    };
  }
}

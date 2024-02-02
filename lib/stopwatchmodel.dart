import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'usermodel.dart';
import 'mystopwatch.dart';

class StopwatchModel {
  final MyStopwatch _stopwatch;
  DateTime? startDateTime;
  DateTime? stopDateTime;
  int bibNumber;
  UserModelState user;
  Compe compe;
  VoidCallback onTick;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MyStopwatch get stopwatch => _stopwatch;
  FirebaseFirestore get firestore => _firestore;

  StopwatchModel(this.bibNumber, this.user, this.compe, this.onTick)
      : _stopwatch = MyStopwatch(onTick: onTick);

  TimerType get timerType {
    if (startDateTime == null && stopDateTime == null) {
      return TimerType.initial;
    } else if (stopDateTime == null) {
      return TimerType.running;
    } else {
      return TimerType.stopped;
    }
  }

  // Firestore上のタイマーをセットする
  Future<void> setDateTimeOnFirestore() async {
    await _firestore
        .collection('users')
        .doc(user.email)
        .collection('compes')
        .doc(compe.id)
        .collection('timers')
        .doc(bibNumber.toString())
        .set({
      'startDateTime': startDateTime,
      'stopDateTime': stopDateTime,
    }, SetOptions(merge: true));
  }

  Future<void> syncWithFirestore() async {
    DocumentSnapshot docSnapshot = await _firestore
        .collection('users')
        .doc(user.email)
        .collection('compes')
        .doc(compe.id)
        .collection('timers')
        .doc(bibNumber.toString())
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      if (data.containsKey('startDateTime') && data['startDateTime'] != null) {
        startDateTime = (data['startDateTime'] as Timestamp).toDate();
        if (timerType == TimerType.running) {
          _stopwatch.startFrom(startDateTime!);
        }
      }
    }

    if (startDateTime == null) {
      _stopwatch.reset();
    }

    onTick();
  }

  void startTimer() {
    _stopwatch.start();
    startDateTime = DateTime.now();
    setDateTimeOnFirestore();
  }

  void stopTimer() {
    _stopwatch.stop();
    stopDateTime = DateTime.now();
    setDateTimeOnFirestore();
  }

  void resetTimer() async {
    // 先にFirestoreを更新
    startDateTime = null;
    stopDateTime = null;
    await setDateTimeOnFirestore();
    // 自らのタイマーをリセット
    _stopwatch.reset();
    // コールバックを実行
    onTick();
  }

  int get milliseconds => _stopwatch.elapsedMilliseconds;

  int getTimerMilliseconds() {
    if (startDateTime != null && stopDateTime != null) {
      return stopDateTime!.difference(startDateTime!).inMilliseconds;
    }
    return 0;
  }

  String? getFormattedStartDateTime() {
    if (startDateTime != null) {
      return _formatDateTime(startDateTime!);
    }
    return null;
  }

  String? getFormattedStopDateTime() {
    if (stopDateTime != null) {
      return _formatDateTime(stopDateTime!);
    }
    return null;
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}:"
        "${dateTime.second.toString().padLeft(2, '0')}."
        "${dateTime.millisecond.toString().padLeft(3, '0')}";
  }

  int getBibNumber() {
    return bibNumber;
  }
}

enum TimerType { initial, running, stopped }

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mystopwatch.dart';

class StopwatchController {
  final MyStopwatch _stopwatch;
  DateTime? startDateTime;
  DateTime? stopDateTime;
  int bibNumber;

  // Firestoreインスタンスを取得
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ゲッターを作成
  MyStopwatch get stopwatch => _stopwatch;
  FirebaseFirestore get firestore => _firestore;

  StopwatchController(this.bibNumber, VoidCallback onTick)
      : _stopwatch = MyStopwatch(onTick: onTick);

  TimerType get timerType {
    if (startDateTime == null) {
      return TimerType.initial;
    } else if (stopDateTime == null) {
      return TimerType.running;
    } else {
      return TimerType.stopped;
    }
  }

  // Firestore上のタイマーをセットする
  Future<void> setDateTimeOnFirestore() async {
    await _firestore.collection('timers').doc(bibNumber.toString()).set({
      'startDateTime': startDateTime,
      'stopDateTime': stopDateTime,
    }, SetOptions(merge: true));
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

  void resetTimer() {
    if (timerType == TimerType.running) {
      _stopwatch.stop();
    }
    _stopwatch.reset();
    startDateTime = null;
    stopDateTime = null;
    setDateTimeOnFirestore();
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

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'usermodel.dart';

class StopwatchModel {
  int bibNumber;
  DateTime? _start;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  DateTime? startDateTime;
  DateTime? stopDateTime;

  UserModelState user;
  Compe compe;
  VoidCallback onTick;

  StopwatchModel(this.bibNumber, this.user, this.compe, this.onTick);

  TimerType get timerType {
    if (startDateTime == null) {
      return TimerType.initial;
    } else if (stopDateTime == null) {
      return TimerType.running;
    } else {
      return TimerType.stopped;
    }
  }

  void startTimer() {
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (Timer t) => _tick(),
    );
    _start = DateTime.now();
    startDateTime = _start;
    onTick.call();
  }

  void stopTimer() {
    _start = null;
    _timer?.cancel();
    stopDateTime = DateTime.now();
    onTick.call();
  }

  void resetTimer() async {
    _start = null;
    _elapsed = Duration.zero;
    startDateTime = null;
    stopDateTime = null;
    onTick.call();
  }

  void startFrom(DateTime startDateTime) {
    _start = startDateTime;
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (Timer t) => _tick(),
    );
  }

  void _tick() {
    if (_start != null) {
      _elapsed = DateTime.now().difference(_start!);
      onTick.call();
    }
  }

  String get milliseconds => _formatTime(_elapsed.inMilliseconds);
  String get resultMilliseconds =>
      _formatTime(stopDateTime!.difference(startDateTime!).inMilliseconds);

  String get formattedStartDateTime => _formatDateTime(startDateTime);
  String get formattedStopDateTime => _formatDateTime(stopDateTime);

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return "-";
    } else {
      return "${dateTime.hour.toString().padLeft(2, '0')}:"
          "${dateTime.minute.toString().padLeft(2, '0')}:"
          "${dateTime.second.toString().padLeft(2, '0')}."
          "${dateTime.millisecond.toString().padLeft(3, '0')}";
    }
  }

  String _formatTime(int milliseconds) {
    final int hundreds = (milliseconds / 10).floor();
    final int seconds = (hundreds / 100).floor();
    final int minutes = (seconds / 60).floor();

    final String formattedMinutes = minutes.toString().padLeft(2, '0');
    final String formattedSeconds = (seconds % 60).toString().padLeft(2, '0');
    final String formattedMilliseconds =
        (milliseconds % 1000).toString().padLeft(3, '0');

    return "$formattedMinutes:$formattedSeconds:$formattedMilliseconds";
  }
}

enum TimerType { initial, running, stopped }

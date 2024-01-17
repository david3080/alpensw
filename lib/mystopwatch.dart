import 'dart:async';
import 'package:flutter/foundation.dart';

class MyStopwatch {
  DateTime? _start;
  Duration _elapsed = Duration.zero;
  Duration _offset = Duration.zero;
  VoidCallback? onTick;
  Timer? _timer;

  MyStopwatch({this.onTick});

  bool get isRunning => _start != null;

  int get elapsedMilliseconds => _elapsed.inMilliseconds;

  set elapsedMilliseconds(int milliseconds) {
    _offset = Duration(milliseconds: milliseconds) - _elapsed;
  }

  void start() {
    _start = DateTime.now();
    _timer =
        Timer.periodic(const Duration(milliseconds: 100), (Timer t) => _tick());
  }

  void stop() {
    if (_start != null) {
      _elapsed += DateTime.now().difference(_start!) + _offset;
      _start = null;
      _offset = Duration.zero;
      _timer?.cancel();
    }
  }

  void reset() {
    _start = null;
    _elapsed = Duration.zero;
    _offset = Duration.zero;
    _timer?.cancel();
  }

  void _tick() {
    if (_start != null) {
      _elapsed = DateTime.now().difference(_start!) + _offset;
      onTick?.call();
    }
  }
}

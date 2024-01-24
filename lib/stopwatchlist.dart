import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stopwatchcontroller.dart';

final stopwatcheListProvider =
    StateNotifierProvider<StopwatcheListNotifier, StopwatcheList>((ref) {
  return StopwatcheListNotifier();
});

class StopwatcheListNotifier extends StateNotifier<StopwatcheList> {
  StopwatcheListNotifier() : super(StopwatcheList()) {
    state = StopwatcheList(
      stopwatches: List.generate(
        5,
        (index) => StopwatchController(index + 1, _updateState),
      ),
    );
    for (var i = 0; i < state.stopwatches.length; i++) {
      syncTimerWithFirestore(i);
    }
  }

  void startTimer(int index) {
    state.stopwatches[index].startTimer();
    _updateState();
  }

  void stopTimer(int index) {
    state.stopwatches[index].stopTimer();
    _updateState();
  }

  void resetTimer(int index) {
    state.stopwatches[index].resetTimer();
    _updateState();
  }

  void _updateState() {
    state = StopwatcheList(
      stopwatches: List<StopwatchController>.from(state.stopwatches),
    );
  }

  void syncTimerWithFirestore(int index) {
    final stopwatch = state.stopwatches[index];
    stopwatch.firestore
        .collection('timers')
        .doc(stopwatch.bibNumber.toString())
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        stopwatch.startDateTime = data?['startDateTime']?.toDate();
        stopwatch.stopDateTime = data?['stopDateTime']?.toDate();

        // Firestoreから取得したstartDateTimeを基にStopwatchを開始
        if (stopwatch.startDateTime != null &&
            stopwatch.stopwatch.isRunning == false) {
          stopwatch.stopwatch.elapsedMilliseconds = DateTime.now()
              .difference(stopwatch.startDateTime!)
              .inMilliseconds;
          stopwatch.stopwatch.start();
        }

        // Firestoreから取得したstopDateTimeを基にStopwatchを停止
        if (stopwatch.stopDateTime != null &&
            stopwatch.stopwatch.isRunning == true) {
          stopwatch.stopwatch.stop();
        }

        _updateState();
      }
    });
  }
}

class StopwatcheList {
  final List<StopwatchController> stopwatches;
  StopwatcheList({this.stopwatches = const []});
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stopwatchmodel.dart';
import 'usermodel.dart';

final stopwatchListProvider =
    StateNotifierProvider.family<StopwatcheListNotifier, StopwatcheList, int>(
        (ref, count) {
  return StopwatcheListNotifier(ref.container, count);
});

class StopwatcheListNotifier extends StateNotifier<StopwatcheList> {
  final ProviderContainer ref;
  StopwatcheListNotifier(this.ref, int count) : super(StopwatcheList()) {
    final user = ref.read(userModelProvider.notifier).state;
    state = StopwatcheList(
      stopwatches: List.generate(
        count,
        (index) => StopwatchModel(
          index + 1,
          user,
          _updateState,
        ),
      ),
    );
    for (var i = 0; i < state.stopwatches.length; i++) {
      syncTimerWithFirestore(i);
    }
  }

  List<StopwatchModel> get stopwatches => state.stopwatches;

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
      stopwatches: List<StopwatchModel>.from(state.stopwatches),
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
  final List<StopwatchModel> stopwatches;
  StopwatcheList({this.stopwatches = const []});
}

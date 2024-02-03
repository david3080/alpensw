import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'stopwatchmodel.dart';
import 'usermodel.dart';

final stopwatchListProvider =
    StateNotifierProvider.family<StopwatcheListNotifier, StopwatcheList, Compe>(
        (ref, compe) {
  return StopwatcheListNotifier(ref.container, compe);
});

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StopwatcheListNotifier extends StateNotifier<StopwatcheList> {
  final ProviderContainer ref;
  final Compe compe;
  final UserModelState user;

  StopwatcheListNotifier(this.ref, this.compe)
      : user = ref.read(userModelProvider.notifier).state,
        super(StopwatcheList()) {
    state = StopwatcheList(
      stopwatches: List.generate(
        compe.num,
        (index) => StopwatchModel(
          index + 1,
          user,
          compe,
          _updateState,
        ),
      ),
    );
    for (var i = 0; i < state.stopwatches.length; i++) {
      syncTimerWithFirestore();
    }
  }

  List<StopwatchModel> get stopwatches => state.stopwatches;

  void startTimer(int index) {
    state.stopwatches[index].startTimer();
    setDateTimeOnFirestore(state.stopwatches[index]);
  }

  void stopTimer(int index) {
    state.stopwatches[index].stopTimer();
    setDateTimeOnFirestore(state.stopwatches[index]);
  }

  void resetTimer() {
    for (var stopwatch in state.stopwatches) {
      stopwatch.resetTimer();
      setDateTimeOnFirestore(stopwatch);
    }
  }

  void _updateState() {
    state = StopwatcheList(
      stopwatches: List<StopwatchModel>.from(state.stopwatches),
    );
  }

  Future<void> setDateTimeOnFirestore(StopwatchModel stopwatch) async {
    await _firestore
        .collection('users')
        .doc(user.email)
        .collection('compes')
        .doc(compe.id)
        .collection('timers')
        .doc(stopwatch.bibNumber.toString())
        .set({
      'startDateTime': stopwatch.startDateTime,
      'stopDateTime': stopwatch.stopDateTime,
    }, SetOptions(merge: true));
  }

  void syncTimerWithFirestore() {
    List<Future> futures = [];
    for (var stopwatch in state.stopwatches) {
      final docRef = _firestore
          .collection('users')
          .doc(user.email)
          .collection('compes')
          .doc(compe.id)
          .collection('timers')
          .doc(stopwatch.bibNumber.toString());

      futures.add(
        docRef.get().then(
          (docSnapshot) {
            if (docSnapshot.exists) {
              final data = docSnapshot.data();
              stopwatch.startDateTime = data?['startDateTime']?.toDate();
              stopwatch.stopDateTime = data?['stopDateTime']?.toDate();
              if (stopwatch.timerType == TimerType.running) {
                // タイマーが走っている場合は再開
                stopwatch.startFrom(stopwatch.startDateTime!);
              }
              if (stopwatch.startDateTime == null) {
                // タイマーが走っていない場合はリセット
                stopwatch.resetTimer();
              }
            } else {
              // 新たにコレクションを作成
              docRef.set({
                'startDateTime': null,
                'stopDateTime': null,
              });
            }
          },
        ),
      );
    }
  }
}

class StopwatcheList {
  final List<StopwatchModel> stopwatches;
  StopwatcheList({this.stopwatches = const []});
}

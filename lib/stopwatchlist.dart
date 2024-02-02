import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stopwatchmodel.dart';
import 'usermodel.dart';

final stopwatchListProvider =
    StateNotifierProvider.family<StopwatcheListNotifier, StopwatcheList, Compe>(
        (ref, compe) {
  return StopwatcheListNotifier(ref.container, compe);
});

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
    final docRef = stopwatch.firestore
        .collection('users')
        .doc(user.email)
        .collection('compes')
        .doc(compe.id)
        .collection('timers')
        .doc(stopwatch.bibNumber.toString());

    docRef.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        // 既存のデータを使用
        final data = docSnapshot.data();
        stopwatch.startDateTime = data?['startDateTime']?.toDate();
        stopwatch.stopDateTime = data?['stopDateTime']?.toDate();
        _updateState();
      } else {
        // 新たにコレクションを作成
        docRef.set({
          'startDateTime': null,
          'stopDateTime': null,
        });
      }
    });

    docRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        stopwatch.startDateTime = data?['startDateTime']?.toDate();
        stopwatch.stopDateTime = data?['stopDateTime']?.toDate();
        _updateState();
      }
    });
  }
}

class StopwatcheList {
  final List<StopwatchModel> stopwatches;
  StopwatcheList({this.stopwatches = const []});
}

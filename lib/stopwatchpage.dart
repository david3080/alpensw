import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'stopwatchlist.dart';
import 'stopwatchcontroller.dart';
import 'fbsettingdialog.dart';
import 'firebaseholder.dart';

final naviProvider = StateNotifierProvider<NaviNotifier, TimerType>((ref) {
  return NaviNotifier();
});

class NaviNotifier extends StateNotifier<TimerType> {
  NaviNotifier() : super(TimerType.initial);

  void setTimerType(TimerType timerType) {
    state = timerType;
  }
}

class StopwatchPage extends ConsumerWidget {
  final Future<FirebaseApp> _initialization;
  StopwatchPage() : _initialization = initializeFirebase();
  static Future<FirebaseApp> initializeFirebase() async {
    FirebaseOptions options = await FirebaseHolder().loadFirebaseOptions();
    return await Firebase.initializeApp(options: options);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Firebaseの初期化が完了したら、通常のビルドを行う
          final stopwatcheList = ref.watch(stopwatcheListProvider);
          final timerType = ref.watch(naviProvider);
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'ALPENストップウォッチ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                onPressed: () {
                  for (int i = 0; i < stopwatcheList.stopwatches.length; i++) {
                    ref.read(stopwatcheListProvider.notifier).resetTimer(i);
                  }
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return FBSettingsDialog();
                      },
                    );
                  },
                ),
                const SizedBox(width: 10.0),
              ],
            ),
            body: ListView.builder(
                itemCount: stopwatcheList.stopwatches.length,
                itemBuilder: (context, index) {
                  final stopwatchController = stopwatcheList.stopwatches[index];
                  if (_shouldShowStopwatch(
                      stopwatchController.timerType, timerType)) {
                    return ListTile(
                      leading: Text(
                        stopwatchController.getBibNumber().toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              formatTime(
                                  stopwatchController.getTimerMilliseconds()),
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  stopwatchController
                                          .getFormattedStartDateTime() ??
                                      "-",
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  stopwatchController
                                          .getFormattedStopDateTime() ??
                                      "-",
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: _buildTrailingIcon(
                          stopwatchController.timerType, index, ref),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.play_arrow),
                  label: 'Start',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.stop),
                  label: 'Stop',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.flag),
                  label: 'Finish',
                ),
              ],
              currentIndex: TimerType.values.indexOf(timerType),
              onTap: (index) {
                ref
                    .read(naviProvider.notifier)
                    .setTimerType(TimerType.values[index]);
              },
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  String formatTime(int milliseconds) {
    final int hundreds = (milliseconds / 10).floor();
    final int seconds = (hundreds / 100).floor();
    final int minutes = (seconds / 60).floor();

    final String formattedMinutes = minutes.toString().padLeft(2, '0');
    final String formattedSeconds = (seconds % 60).toString().padLeft(2, '0');
    final String formattedMilliseconds =
        (milliseconds % 1000).toString().padLeft(3, '0');

    return "$formattedMinutes:$formattedSeconds:$formattedMilliseconds";
  }

  bool _shouldShowStopwatch(TimerType stopwatchType, TimerType currentType) {
    switch (currentType) {
      case TimerType.initial:
        return stopwatchType == TimerType.initial;
      case TimerType.running:
        return stopwatchType == TimerType.running;
      case TimerType.stopped:
        return stopwatchType == TimerType.stopped;
      default:
        return false;
    }
  }

  Widget? _buildTrailingIcon(
      TimerType stopwatchType, int index, WidgetRef ref) {
    switch (stopwatchType) {
      case TimerType.initial:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () =>
              ref.read(stopwatcheListProvider.notifier).startTimer(index),
        );
      case TimerType.running:
        return IconButton(
          icon: const Icon(Icons.stop),
          onPressed: () =>
              ref.read(stopwatcheListProvider.notifier).stopTimer(index),
        );
      case TimerType.stopped:
        return null;
      default:
        return null;
    }
  }
}

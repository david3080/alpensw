import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stopwatchlist.dart';
import 'stopwatchmodel.dart';
import 'usermodel.dart';

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
  final Compe compe;
  StopwatchPage({required this.compe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stopwatchList = ref.watch(stopwatchListProvider(compe).notifier);
    final timerType = ref.watch(naviProvider);

    // Firestoreとデータ同期を行い
    // compe下にtimersコレクションが存在しない場合のみ新規作成
    for (int i = 0; i < compe.num; i++) {
      ref
          .watch(stopwatchListProvider(compe).notifier)
          .stopwatches[i]
          .syncWithFirestore();
    }

    var title = timerType.index == 0
        ? "スタート地点"
        : (timerType.index == 1 ? "ゴール地点" : "結果");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "測定名「${compe.name}」の$title",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () {
              ref.read(userModelProvider.notifier).deleteCompe(compe.id);
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              for (int i = 0;
                  i <
                      ref
                          .watch(stopwatchListProvider(compe))
                          .stopwatches
                          .length;
                  i++) {
                ref.watch(stopwatchListProvider(compe).notifier).resetTimer(i);
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: ref.watch(stopwatchListProvider(compe)).stopwatches.length,
          itemBuilder: (context, index) {
            final stopwatchController =
                ref.watch(stopwatchListProvider(compe)).stopwatches[index];
            if (_shouldShowStopwatch(
                stopwatchController.timerType, timerType)) {
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                  vertical: 0.0,
                ),
                leading: Container(
                  width: 20.0,
                  height: 20.0,
                  alignment: Alignment.centerRight,
                  child: Text(
                    stopwatchController.getBibNumber().toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Text(
                        formatTime(
                          timerType == TimerType.stopped
                              ? stopwatchController.getTimerMilliseconds()
                              : stopwatchController.milliseconds,
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            stopwatchController.getFormattedStartDateTime() ??
                                "-",
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            stopwatchController.getFormattedStopDateTime() ??
                                "-",
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: _buildTrailingIcon(stopwatchController.timerType,
                    index, ref.watch(stopwatchListProvider(compe).notifier)),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'スタート地点',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stop),
            label: 'ゴール地点',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: '結果',
          ),
        ],
        currentIndex: TimerType.values.indexOf(timerType),
        onTap: (index) {
          ref.read(naviProvider.notifier).setTimerType(TimerType.values[index]);
        },
      ),
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

  Widget? _buildTrailingIcon(TimerType stopwatchType, int index,
      StopwatcheListNotifier stopwatchList) {
    switch (stopwatchType) {
      case TimerType.initial:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () => stopwatchList.startTimer(index),
        );
      case TimerType.running:
        return IconButton(
          icon: const Icon(Icons.stop),
          onPressed: () => stopwatchList.stopTimer(index),
        );
      case TimerType.stopped:
        return null;
      default:
        return null;
    }
  }
}

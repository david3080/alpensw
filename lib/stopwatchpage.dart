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
    final stopwatchList = ref.watch(stopwatchListProvider(compe.num).notifier);
    final timerType = ref.watch(naviProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "測定名: ${compe.name}",
          style: const TextStyle(
            fontSize: 18,
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
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              for (int i = 0; i < stopwatchList.stopwatches.length; i++) {
                stopwatchList.resetTimer(i);
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: stopwatchList.stopwatches.length,
          itemBuilder: (context, index) {
            final stopwatchController = stopwatchList.stopwatches[index];
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
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            stopwatchController.getFormattedStopDateTime() ??
                                "-",
                            style: const TextStyle(
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: _buildTrailingIcon(
                    stopwatchController.timerType, index, stopwatchList),
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
            label: 'Goal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Results',
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pomodoro/Data/PomodoroTimer.dart';
import 'package:pomodoro/Services/Database.dart';
import 'package:pomodoro/Services/NotificationService.dart';
import 'package:pomodoro/UI/Screens/Pomodoro/Components/control_bar.dart';
import 'package:pomodoro/UI/Screens/Pomodoro/Components/finished_timer_dialog.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PomodoroScreen extends StatefulWidget {
  final PomodoroTimer Ptimer;
  final Function(PomodoroTimer)? onTimerSwitch;

  const PomodoroScreen({super.key, required this.Ptimer, this.onTimerSwitch});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  late PomodoroTimer _Ptimer;
  late int _remainingSeconds;

  Timer? _timer;
  bool _isRunning = false;
  StreamSubscription<String>? _notificationSub;

  @override
  void initState() {
    super.initState();
    _Ptimer = widget.Ptimer;
    _remainingSeconds = _Ptimer.duration.inSeconds;
    _notificationSub =
        NotificationService.instance.onAction.listen(_onNotificationAction);
    print(
        "Timer updated\nNew Name: ${_Ptimer.name}\nNew Duration: ${_Ptimer.duration}\nNext Suggested Timer ID: ${_Ptimer.nextSuggestedTimerID}");
  }

  @override
  void didUpdateWidget(PomodoroScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.Ptimer != widget.Ptimer) {
      _Ptimer = widget.Ptimer;
      _remainingSeconds = _Ptimer.duration.inSeconds;
      print(
          "Timer updated\nNew Name: ${_Ptimer.name}\nNew Duration: ${_Ptimer.duration}\nNext Suggested Timer ID: ${_Ptimer.nextSuggestedTimerID}");
      _pauseTimer();
    }
  }

  void _onNotificationAction(String actionId) {
    switch (actionId) {
      case 'pause':
        _startTimer();
        break;
      case 'reset':
        _resetTimer();
        break;
    }
  }

  void _startTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      setState(() {
        _isRunning = true;
      });
      _updateWakelock();
      NotificationService.instance.show(
        timerName: _Ptimer.name,
        remainingSeconds: _remainingSeconds,
        isRunning: true,
      );
      _remainingSeconds--;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        bool finished = false;
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
            NotificationService.instance.show(
              timerName: _Ptimer.name,
              remainingSeconds: _remainingSeconds,
              isRunning: true,
            );
          } else {
            _pauseTimer();
            finished = true;
          }
        });
        if (finished) _onTimerComplete();
      });
    }
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
    _updateWakelock();
    // Show paused notification only when mid-timer; otherwise cancel (start or complete state)
    if (_remainingSeconds > 0 && _remainingSeconds < _Ptimer.duration.inSeconds) {
      NotificationService.instance.show(
        timerName: _Ptimer.name,
        remainingSeconds: _remainingSeconds,
        isRunning: false,
      );
    } else {
      NotificationService.instance.cancel();
    }
  }

  Future<void> _updateWakelock() async {
    final db = DatabaseService();
    final keepScreenOn =
        await db.getSetting('keep_screen_on', defaultValue: true);
    if (_isRunning && keepScreenOn) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  void _resetTimer() {
    _stopAlarm();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _Ptimer.duration.inSeconds;
    });
    _updateWakelock();
    NotificationService.instance.cancel();
  }

  Future<void> _onTimerComplete() async {
    final db = DatabaseService();
    final alarmEnabled = await db.getSetting(DatabaseService.settingAlarmEnabled, defaultValue: true);
    final alarmType = await db.getIntSetting(DatabaseService.settingAlarmType, defaultValue: 0);
    final vibrationEnabled = await db.getSetting(DatabaseService.settingVibrationEnabled, defaultValue: true);

    NotificationService.instance.complete(timerName: _Ptimer.name, playSound: alarmEnabled, vibrate: vibrationEnabled);

    if (alarmEnabled) {
      final player = FlutterRingtonePlayer();
      if (alarmType == 1) {
        player.playNotification(looping: true);
      } else {
        player.playAlarm(looping: true);
      }
    }

    if (vibrationEnabled) {
      Vibration.vibrate(pattern: [0, 400, 200, 400, 200, 600]);
    }

    if (mounted) _showCompletionDialog();
  }

  void _stopAlarm() {
    FlutterRingtonePlayer().stop();
  }

  void _showCompletionDialog() async {
    PomodoroTimer? nextTimer;
    if (_Ptimer.nextSuggestedTimerID != null) {
      nextTimer =
          await DatabaseService().getTimerById(_Ptimer.nextSuggestedTimerID!);
      print(
          "Completion Dialog ${_Ptimer.nextSuggestedTimerID}: ${nextTimer?.name}");
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => FinishedTimerDialog(
        timer: _Ptimer,
        nextTimerName: nextTimer?.name,
        onReset: _resetTimer,
        onStartNextTimer: nextTimer != null && widget.onTimerSwitch != null
            ? () {
                _stopAlarm();
                widget.onTimerSwitch!(nextTimer!);
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _getProgress();
    final buttonSize = MediaQuery.of(context).size.width * 0.6;

    return Scaffold(
      backgroundColor: _Ptimer.color.withAlpha(25),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: buttonSize + 40,
                  height: buttonSize + 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: buttonSize + 40,
                        height: buttonSize + 40,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isRunning ? _Ptimer.color : Colors.grey,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _startTimer,
                        child: Container(
                          width: buttonSize,
                          height: buttonSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRunning
                                ? _Ptimer.color.withAlpha(950)
                                : _Ptimer.color.withAlpha(1000),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _formatTime(_remainingSeconds),
                              style: TextStyle(
                                fontSize: buttonSize * 0.15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_remainingSeconds != _Ptimer.duration.inSeconds)
            Positioned(
              left: 0,
              right: 0,
              bottom: kBottomNavigationBarHeight,
              child: ControlBar(
                timer: _Ptimer,
                isRunning: _isRunning,
                onStartPause: _startTimer,
                onReset: _resetTimer,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    return 1.0 - (_remainingSeconds / _Ptimer.duration.inSeconds);
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    _timer?.cancel();
    _stopAlarm();
    WakelockPlus.disable();
    NotificationService.instance.cancel();
    super.dispose();
  }
}

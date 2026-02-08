import 'package:flutter/material.dart';
import 'package:pomodoro/Data/PomodoroTimer.dart';
import 'package:pomodoro/Services/Database.dart';
import 'UI/Screens/Pomodoro/pomodoro_screen.dart';
import 'UI/Screens/Timers/timers_screen.dart';
import 'UI/Screens/Settings/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1; // Start on Pomodoro screen (middle)
  PomodoroTimer? _selectedTimer;
  int _pomodoroKey = 0; // Key to force rebuild when duration changes

  @override
  void initState() {
    super.initState();
    _loadFirstTimer();
  }

  Future<void> _loadFirstTimer() async {
    final timers = await DatabaseService().getAllTimers();
    if (timers.isNotEmpty && mounted) {
      setState(() {
        _selectedTimer = timers.first;
      });
    } else if (mounted) {
      // Fallback to default if no timers found
      setState(() {
        _selectedTimer = PomodoroTimer("Pomodoro", Duration(minutes: 25), Colors.red, Icons.timer);
      });
    }
  }

  void _onTimerSelected(PomodoroTimer timer) {
    setState(() {
      _selectedTimer = timer;
      _currentIndex = 1; // Switch to Pomodoro screen
      _pomodoroKey++; // Force rebuild of Pomodoro screen
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator if timer hasn't loaded yet
    if (_selectedTimer == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          TimersScreen(onTimerSelected: _onTimerSelected),
          PomodoroScreen(
            key: ValueKey(_pomodoroKey),
            Ptimer: _selectedTimer!,
            onTimerSwitch: _onTimerSelected,
          ),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer),
            label: 'Timers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle),
            label: 'Pomodoro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

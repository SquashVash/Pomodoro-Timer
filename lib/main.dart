import 'package:flutter/material.dart';
import 'package:pomodoro/Services/Database.dart';
import 'package:pomodoro/Services/NotificationService.dart';
import 'package:pomodoro/UI/Screens/Onboarding/OnboardingScreen.dart';
import 'package:pomodoro/UI/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const _LaunchGate(),
    );
  }
}

class _LaunchGate extends StatelessWidget {
  const _LaunchGate();

  Future<bool> _shouldShowOnboarding() async {
    final db = DatabaseService();
    final completed = await db.isOnboardingCompleted();
    return !completed;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _shouldShowOnboarding(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final showOnboarding = snapshot.data ?? true;
        if (showOnboarding) {
          return const OnboardingScreen();
        }else{
          NotificationService.instance.init();
        }

        return const MainNavigation();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pomodoro/Services/Database.dart';
import 'package:pomodoro/UI/main_navigation.dart';
import 'package:pomodoro/UI/Screens/Onboarding/MotivationScreen.dart';
import 'package:pomodoro/UI/Screens/Onboarding/PrivacyScreen.dart';
import 'package:pomodoro/UI/Screens/Onboarding/WelcomeScreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  List<Widget> _buildPages(bool isDark) {
    final pages = <Widget>[
      WelcomeScreen(onNext: _nextPage, isDark: isDark),
      MotivationScreen(onNext: _nextPage, onPrevious: _previousPage, isDark: isDark),
    ];

    if (_isIOS) {
      pages.add(PrivacyScreen(onNext: _nextPage, onPrevious: _previousPage, isDark: isDark));
    }

    return pages;
  }

  @override
  void initState() {
    super.initState();
  }

  void _nextPage() {
    final totalPages = _buildPages(Theme.of(context).brightness == Brightness.dark).length;
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      await _databaseService.setOnboardingCompleted(true);
      
      // Navigate to main app
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing onboarding: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pages = _buildPages(isDark);
    final totalPages = pages.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / totalPages,
                      backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_currentPage + 1}/$totalPages',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: pages,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

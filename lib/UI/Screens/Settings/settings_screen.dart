import 'package:flutter/material.dart';
import 'package:pomodoro/Services/Database.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _keepScreenOn = true;
  bool _alarmEnabled = true;
  int _alarmType = 0;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final db = DatabaseService();
    final keepScreenOn = await db.getSetting(DatabaseService.settingKeepScreenOn, defaultValue: true);
    final alarmEnabled = await db.getSetting(DatabaseService.settingAlarmEnabled, defaultValue: true);
    final alarmType = await db.getIntSetting(DatabaseService.settingAlarmType, defaultValue: 0);
    final vibrationEnabled = await db.getSetting(DatabaseService.settingVibrationEnabled, defaultValue: true);
    setState(() {
      _keepScreenOn = keepScreenOn;
      _alarmEnabled = alarmEnabled;
      _alarmType = alarmType;
      _vibrationEnabled = vibrationEnabled;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    final db = DatabaseService();
    await db.setSetting(key, value);
  }

  Future<void> _updateIntSetting(String key, int value) async {
    final db = DatabaseService();
    await db.setIntSetting(key, value);
  }

  Future<void> _sendFeedback() async {
    try {
      final Uri url = Uri.parse(
          'mailto:support@kovets.com?subject=Pomodoro Timer Feedback');
      await launchUrl(url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open email client: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'General',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeColor: Colors.red,
                        title: const Text('Keep screen on'),
                        subtitle: const Text('Prevent the screen from turning off while timer is running'),
                        value: _keepScreenOn,
                        onChanged: (value) {
                          setState(() {
                            _keepScreenOn = value;
                          });
                          _updateSetting(DatabaseService.settingKeepScreenOn, value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'When timer ends',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        activeColor: Colors.red,
                        title: const Text('Play alarm sound'),
                        subtitle: const Text('Play an alert sound when the timer finishes'),
                        value: _alarmEnabled,
                        onChanged: (value) {
                          setState(() => _alarmEnabled = value);
                          _updateSetting(DatabaseService.settingAlarmEnabled, value);
                        },
                      ),
                      if (_alarmEnabled) ...[
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          title: const Text('Sound type'),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SegmentedButton<int>(
                              segments: const [
                                ButtonSegment(
                                  value: 0,
                                  label: Text('Alarm'),
                                  icon: Icon(Icons.alarm, size: 16),
                                ),
                                ButtonSegment(
                                  value: 1,
                                  label: Text('Bell'),
                                  icon: Icon(Icons.notifications, size: 16),
                                ),
                                ButtonSegment(
                                  value: 2,
                                  label: Text('Ringtone'),
                                  icon: Icon(Icons.ring_volume, size: 16),
                                ),
                              ],
                              selected: {_alarmType},
                              onSelectionChanged: (selected) {
                                final type = selected.first;
                                setState(() => _alarmType = type);
                                _updateIntSetting(DatabaseService.settingAlarmType, type);
                              },
                            ),
                          ),
                        ),
                      ],
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      SwitchListTile(
                        activeColor: Colors.red,
                        title: const Text('Vibrate'),
                        subtitle: const Text('Vibrate when the timer finishes'),
                        value: _vibrationEnabled,
                        onChanged: (value) {
                          setState(() => _vibrationEnabled = value);
                          _updateSetting(DatabaseService.settingVibrationEnabled, value);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _sendFeedback,
                      icon: const Icon(Icons.feedback, color: Colors.white),
                      label: const Text(
                        'Send Feedback',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Matches the red in the image
                        foregroundColor: Colors.white, // Ripple and default text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded, but not stadium
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

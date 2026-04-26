import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool isDark;

  const NotificationScreen({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay updated with your timer. Enable notifications to receive timely alerts when your session ends.',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () async {
                    if (kIsWeb) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications are not supported on the web.'),
                        ),
                      );
                      return;
                    }
                    try {
                      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
                          FlutterLocalNotificationsPlugin();
                      
                      bool? granted = false;
                      if (defaultTargetPlatform == TargetPlatform.android) {
                        granted = await flutterLocalNotificationsPlugin
                            .resolvePlatformSpecificImplementation<
                                AndroidFlutterLocalNotificationsPlugin>()
                            ?.requestNotificationsPermission();
                      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                        granted = await flutterLocalNotificationsPlugin
                            .resolvePlatformSpecificImplementation<
                                IOSFlutterLocalNotificationsPlugin>()
                            ?.requestPermissions(
                              alert: true,
                              badge: true,
                              sound: true,
                            );
                      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
                        granted = await flutterLocalNotificationsPlugin
                            .resolvePlatformSpecificImplementation<
                                MacOSFlutterLocalNotificationsPlugin>()
                            ?.requestPermissions(
                              alert: true,
                              badge: true,
                              sound: true,
                            );
                      }
                      
                      if (granted == true) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifications enabled successfully.'),
                            ),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifications permission denied.'),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Unable to request permission: $e'),
                          ),
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Enable Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

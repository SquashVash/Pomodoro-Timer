import 'package:flutter/material.dart';
import 'package:pomodoro/Data/PomodoroTimer.dart';

class TimerOption extends StatelessWidget {
  const TimerOption({
    super.key,
    required this.timer,
    this.onTap,
    this.onMenuTap,
  });

  final PomodoroTimer timer;
  
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return '$hours hr';
      }
      return '$hours hr $mins min';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.2, // Makes it wider (less square)
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Top row: Icon (left) and Three dots menu (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon on top left
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: timer.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      timer.icon,
                      color: timer.color,
                      size: 24,
                    ),
                  ),
                  // Three dot menu on top right
                  GestureDetector(
                    onTap: onMenuTap,
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Bottom section: Timer duration and Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timer duration right above the title
                  Text(
                    _formatDuration(timer.duration),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Title at bottom left
                  Text(
                    timer.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}


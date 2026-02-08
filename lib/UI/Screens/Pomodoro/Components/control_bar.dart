import 'package:flutter/material.dart';
import 'package:pomodoro/Data/PomodoroTimer.dart';

class ControlBar extends StatelessWidget {
  final PomodoroTimer timer;
  final bool isRunning;
  final VoidCallback onStartPause;
  final VoidCallback onReset;

  const ControlBar({
    super.key,
    required this.timer,
    required this.isRunning,
    required this.onStartPause,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: timer.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Timer title on the left
            Expanded(
              child: Text(
                timer.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Control buttons on the right
            Row(
              children: [
                // Start/Pause button
                IconButton(
                  onPressed: onStartPause,
                  icon: Icon(
                    isRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                  iconSize: 28,
                  constraints: const BoxConstraints(),
                ),
                // Reset button
                IconButton(
                  onPressed: onReset,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 24,
                  ),
                  iconSize: 24,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:pomodoro/Data/PomodoroTimer.dart';
import 'package:pomodoro/Services/Database.dart';
import 'package:pomodoro/UI/Screens/Timers/Components/timer_option.dart';
import 'package:pomodoro/UI/Screens/Timers/Components/add_timer_screen.dart';

class TimersScreen extends StatefulWidget {
  const TimersScreen({super.key, required this.onTimerSelected});

  final Function(PomodoroTimer timer) onTimerSelected;

  @override
  State<TimersScreen> createState() => _TimersScreenState();
}

class _TimersScreenState extends State<TimersScreen> {
  List<PomodoroTimer> _timers = [];
  bool _isLoading = true;
  final Map<int, GlobalKey> _menuKeys = {};

  @override
  void initState() {
    super.initState();
    _loadTimers();
  }

  Future<void> _loadTimers() async {
    final timers = await DatabaseService().getAllTimers();
    setState(() {
      _timers = timers;
      _isLoading = false;
      // Clean up keys for deleted timers
      _menuKeys.removeWhere((id, _) => !timers.any((timer) => timer.id == id));
    });
  }

  void _showMenu(BuildContext context, PomodoroTimer timer, GlobalKey key) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + size.width - 120,
        position.dy + 40,
        position.dx + size.width - 20,
        position.dy + 60,
      ),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Delete'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        _showEditTimerScreen(context, timer);
      } else if (value == 'delete') {
        _deleteTimer(context, timer);
      }
    });
  }

  Future<void> _deleteTimer(BuildContext context, PomodoroTimer timer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Timer'),
        content: Text('Are you sure you want to delete "${timer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService().deleteTimer(timer.id!);
      _loadTimers();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${timer.name} deleted')),
        );
      }
    }
  }

  Future<void> _showAddTimerScreen(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTimerScreen(),
      ),
    );

    if (result == true) {
      _loadTimers();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Timer added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showEditTimerScreen(BuildContext context, PomodoroTimer timer) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTimerScreen(timerToEdit: timer),
      ),
    );

    if (result == true) {
      _loadTimers();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Timer updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preset Timers'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _timers.length,
              itemBuilder: (context, index) {
                final timer = _timers[index];
                if (!_menuKeys.containsKey(timer.id)) {
                  _menuKeys[timer.id!] = GlobalKey();
                }

                return Builder(
                  key: _menuKeys[timer.id],
                  builder: (context) => TimerOption(
                    timer: timer,
                    onTap: () {
                      widget.onTimerSelected(timer);
                    },
                    onMenuTap: () {
                      _showMenu(context, timer, _menuKeys[timer.id]!);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTimerScreen(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}


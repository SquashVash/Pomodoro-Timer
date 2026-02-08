import 'package:flutter/material.dart';
import 'package:pomodoro/Data/PomodoroTimer.dart';
import 'package:pomodoro/Services/Database.dart';
import 'package:pomodoro/UI/Screens/Timers/Components/design_picker_dialog.dart';

class AddTimerScreen extends StatefulWidget {
  const AddTimerScreen({super.key, this.timerToEdit});

  final PomodoroTimer? timerToEdit;

  @override
  State<AddTimerScreen> createState() => _AddTimerScreenState();
}

class _AddTimerScreenState extends State<AddTimerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _minutes = 25;
  int _hours = 0;
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.timer;
  int? _selectedNextSuggestedTimerID;
  List<PomodoroTimer> _availableTimers = [];

  final List<IconData> _iconOptions = [
    Icons.timer,
    Icons.work,
    Icons.school,
    Icons.fitness_center,
    Icons.coffee,
    Icons.book,
    Icons.computer,
    Icons.music_note,
  ];

  @override
  void initState() {
    super.initState();
    _loadTimers();
    if (widget.timerToEdit != null) {
      final timer = widget.timerToEdit!;
      _nameController.text = timer.name;
      _hours = timer.duration.inHours;
      _minutes = timer.duration.inMinutes % 60;
      _selectedColor = timer.color;
      _selectedIcon = timer.icon;
      _selectedNextSuggestedTimerID = timer.nextSuggestedTimerID;
    }
  }

  Future<void> _loadTimers() async {
    final timers = await DatabaseService().getAllTimers();
    setState(() {
      _availableTimers = timers;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showDesignPicker() async {
    final Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return DesignPickerDialog(
          initialColor: _selectedColor,
          initialIcon: _selectedIcon,
          iconOptions: _iconOptions,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedColor = result['color'] as Color;
        _selectedIcon = result['icon'] as IconData;
      });
    }
  }

  Future<void> _saveTimer() async {
    if (_formKey.currentState!.validate()) {
      final duration = Duration(hours: _hours, minutes: _minutes);
      final timer = PomodoroTimer(
        _nameController.text.trim(),
        duration,
        _selectedColor,
        _selectedIcon,
        id: widget.timerToEdit?.id, // Keep the same ID when editing
        nextSuggestedTimerID: _selectedNextSuggestedTimerID,
      );

      try {
        if (widget.timerToEdit != null) {
          // Edit mode: update existing timer
          await DatabaseService().updateTimer(widget.timerToEdit!.id!, timer);
        } else {
          // Add mode: create new timer
          await DatabaseService().addTimer(timer);
        }
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error ${widget.timerToEdit != null ? 'updating' : 'adding'} timer: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.timerToEdit != null ? 'Edit Timer' : 'Add New Timer'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Preview Icon and Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Timer Name',
                        hintText: 'e.g., Focus Session',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a timer name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Duration section
                    const Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DurationSelector(
                            label: 'Hours',
                            value: _hours,
                            min: 0,
                            max: 23,
                            onChanged: (value) {
                              setState(() {
                                _hours = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DurationSelector(
                            label: 'Minutes',
                            value: _minutes,
                            min: 0,
                            max: 59,
                            onChanged: (value) {
                              setState(() {
                                _minutes = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Design selection
                    const Text(
                      'Design',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showDesignPicker,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tap to pick design',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Choose color and icon',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _selectedColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey[400]!,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _selectedColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _selectedIcon,
                                color: _selectedColor,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Next suggested Timer section
                    const Text(
                      'Next suggested Timer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonFormField<int?>(
                        value: _selectedNextSuggestedTimerID,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        hint: const Text(
                          'Select a timer (optional)',
                          style: TextStyle(color: Colors.grey),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('None'),
                          ),
                          ..._availableTimers
                              .where((timer) => timer.id != widget.timerToEdit?.id)
                              .map((timer) {
                            return DropdownMenuItem<int?>(
                              value: timer.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: timer.color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      timer.icon,
                                      color: timer.color,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(timer.name),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedNextSuggestedTimerID = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Action button - fixed at bottom
            Container(
              padding: const EdgeInsets.all(24),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      widget.timerToEdit != null ? 'Update Timer' : 'Add Timer',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: value > min
                    ? () => onChanged(value - 1)
                    : null,
                color: value > min ? Colors.blue : Colors.grey,
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: value < max
                    ? () => onChanged(value + 1)
                    : null,
                color: value < max ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

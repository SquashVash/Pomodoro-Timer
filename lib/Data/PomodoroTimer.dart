import 'dart:ui';

import 'package:flutter/cupertino.dart';

class PomodoroTimer{
  int? id;
  String _name;
  Duration _duration;
  Color _color;
  IconData _icon;
  int? nextSuggestedTimerID;

  PomodoroTimer(this._name, this._duration, this._color, this._icon, {this.id, this.nextSuggestedTimerID});

  String get name => _name;
  Duration get duration => _duration;
  Color get color => _color;
  IconData get icon => _icon;
}

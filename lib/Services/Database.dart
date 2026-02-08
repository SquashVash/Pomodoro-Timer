import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pomodoro/Data/PomodoroTimer.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'pomodoro_timers.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pomodoro_timers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        duration_seconds INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        icon_code_point INTEGER NOT NULL,
        icon_font_family TEXT,
        icon_font_package TEXT,
        next_suggested_timer_id INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');

    // Insert default timers
    await _insertDefaultTimers(db);
  }

  Future<void> _insertDefaultTimers(Database db) async {
    // Create timers with IDs assigned
    final pomodoro = PomodoroTimer("Pomodoro", const Duration(minutes: 25), Colors.red, Icons.timer, id: 1, nextSuggestedTimerID: 2);
    final shortBreak = PomodoroTimer("Short Break", const Duration(minutes: 5), Colors.green, Icons.timer, id: 2, nextSuggestedTimerID: 1);
    final longBreak = PomodoroTimer("Long Break", const Duration(minutes: 15), Colors.blue, Icons.timer, id: 3, nextSuggestedTimerID: 4);
    final focusSession = PomodoroTimer("Focus Session", const Duration(minutes: 45), Colors.orange, Icons.timer, id: 4, nextSuggestedTimerID: 3);

    final defaultTimers = [
      pomodoro,
      shortBreak,
      longBreak,
      focusSession,
    ];

    for (var timer in defaultTimers) {
      await _insertTimer(db, timer);
    }
  }

  Future<int> _insertTimer(Database db, PomodoroTimer timer) async {
    return await db.insert(
      'pomodoro_timers',
      {
        'id': timer.id,
        'name': timer.name,
        'duration_seconds': timer.duration.inSeconds,
        'color_value': timer.color.value,
        'icon_code_point': timer.icon.codePoint,
        'icon_font_family': timer.icon.fontFamily,
        'icon_font_package': timer.icon.fontPackage,
        'next_suggested_timer_id': timer.nextSuggestedTimerID,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 1. Add & save new Timer
  Future<int> addTimer(PomodoroTimer timer) async {
    final db = await database;
    final insertedId = await _insertTimer(db, timer);
    timer.id = insertedId;
    return insertedId;
  }

  // 2. Load a specific timer by name/id
  Future<PomodoroTimer?> getTimerById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pomodoro_timers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _timerFromMap(maps.first, db);
  }

  Future<PomodoroTimer?> getTimerByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pomodoro_timers',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isEmpty) return null;
    return _timerFromMap(maps.first, db);
  }

  // 3. Load list of all timers
  Future<List<PomodoroTimer>> getAllTimers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pomodoro_timers',
      orderBy: 'created_at ASC',
    );

    return Future.wait(
      maps.map((map) => _timerFromMap(map, db)),
    );
  }

  Future<PomodoroTimer> _timerFromMap(Map<String, dynamic> map, Database db) async {
    final id = map['id'] as int?;
    final nextSuggestedTimerID = map['next_suggested_timer_id'] as int?;

    return PomodoroTimer(
      map['name'] as String,
      Duration(seconds: map['duration_seconds'] as int),
      Color(map['color_value'] as int),
      IconData(
        map['icon_code_point'] as int,
        fontFamily: map['icon_font_family'] as String?,
        fontPackage: map['icon_font_package'] as String?,
      ),
      id: id,
      nextSuggestedTimerID: nextSuggestedTimerID,
    );
  }

  // Edit/Update timer by ID
  Future<int> updateTimer(int id, PomodoroTimer timer) async {
    final db = await database;
    return await db.update(
      'pomodoro_timers',
      {
        'name': timer.name,
        'duration_seconds': timer.duration.inSeconds,
        'color_value': timer.color.value,
        'icon_code_point': timer.icon.codePoint,
        'icon_font_family': timer.icon.fontFamily,
        'icon_font_package': timer.icon.fontPackage,
        'next_suggested_timer_id': timer.nextSuggestedTimerID,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Edit/Update timer by name
  Future<int> updateTimerByName(String name, PomodoroTimer timer) async {
    final db = await database;
    return await db.update(
      'pomodoro_timers',
      {
        'name': timer.name,
        'duration_seconds': timer.duration.inSeconds,
        'color_value': timer.color.value,
        'icon_code_point': timer.icon.codePoint,
        'icon_font_family': timer.icon.fontFamily,
        'icon_font_package': timer.icon.fontPackage,
        'next_suggested_timer_id': timer.nextSuggestedTimerID,
      },
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  // Delete timer by ID
  Future<int> deleteTimer(int id) async {
    final db = await database;
    return await db.delete(
      'pomodoro_timers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete timer by name
  Future<int> deleteTimerByName(String name) async {
    final db = await database;
    return await db.delete(
      'pomodoro_timers',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}


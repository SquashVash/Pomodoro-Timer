# Pomodoro Timer

This Pomodoro Timer app helps you work smarter by breaking your day into focused sessions and refreshing breaks.

Set a task, start a timer, and let the app guide you through proven Pomodoro cycles that boost concentration and reduce procrastination. With a clean, distraction-free design, customizable work and break lengths, and gentle reminders to pause and reset, it’s perfect for studying, coding, writing, or tackling your to-do list. One timer, better focus, real progress—25 minutes at a time. 🍅⏱️

## Features

### 🎯 Core Functionality
- **Multiple Timer Presets**: Create and manage multiple custom timers
- **Circular Progress Indicator**: Visual progress tracking with a beautiful circular design
- **Timer Controls**: Start, pause, and reset functionality
- **Next Suggested Timer**: Automatically suggests the next timer after completion
- **Persistent Storage**: All timers are saved locally using SQLite database

### 🎨 Customization
- **Custom Timer Creation**: Add timers with custom names, durations, colors, and icons
- **Timer Management**: Edit or delete existing timers
- **Color-Coded Timers**: Each timer can have its own unique color theme
- **Icon Selection**: Choose from a variety of icons for your timers

### 📱 User Interface
- **Material Design 3**: Modern, clean UI following Material Design principles
- **Bottom Navigation**: Easy navigation between Timers, Pomodoro, and Settings screens
- **Responsive Design**: Adapts to different screen sizes
- **Intuitive Controls**: Simple tap-to-start/pause functionality

### ⚙️ Settings
- **Sound Notifications**: Enable/disable sound alerts when timer completes
- **Vibration**: Toggle vibration feedback for timer completion

### 📦 Default Timers
The app comes with four pre-configured timers:
- **Pomodoro** (25 minutes) - Red theme
- **Short Break** (5 minutes) - Green theme
- **Long Break** (15 minutes) - Blue theme
- **Focus Session** (45 minutes) - Orange theme

## Screenshots

The app features three main screens:
1. **Timers Screen**: View and manage all your timer presets in a grid layout
2. **Pomodoro Screen**: The main timer interface with circular progress indicator
3. **Settings Screen**: Configure app preferences and view app information

## Requirements

- Flutter SDK: ^3.9.0
- Dart SDK: Compatible with Flutter 3.9.0
- Android: Minimum SDK version as specified in `android/app/build.gradle.kts`
- iOS: Compatible with iOS deployment target as specified in `ios/Runner.xcodeproj`


## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

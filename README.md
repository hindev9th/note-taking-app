# Note Taking App

![App Logo](assets/logo.png)

A modern, feature-rich note-taking application built with Flutter that helps you organize your thoughts, ideas, and important information in a clean and intuitive interface. Currently optimized and tested primarily for Linux environments.

## Features

- **Clean Grid Layout**: View all your notes in an organized grid layout for easy access
- **Rich Text Editing**: Create and edit notes with formatting options using Flutter Quill
- **Dark & Light Themes**: Automatically adapts to your system theme preferences
- **Auto-Save**: Never lose your work with automatic saving as you type
- **Drag & Drop Organization**: Rearrange notes with intuitive drag-and-drop functionality
- **Persistent Storage**: All notes are securely stored locally using Hive database

## Screenshots

![App Preview](https://github.com/user-attachments/assets/acc08b66-c84e-44cc-92ee-71e54c00cf48)

## Tech Stack

- **Flutter**: Cross-platform UI framework
- **flutter_quill**: Rich text editor implementation
- **Hive**: Fast, lightweight local database
- **GetX**: State management and navigation
- **flutter_staggered_grid_view**: For the responsive grid layout
- **reorderable_grid_view**: For drag-and-drop functionality
- **handy_window** & **window_manager**: For Linux window management

## Themes

The app supports both light and dark themes:

### Dark Theme
- Background: `#0F172A`
- Card Background: `#1E293B`
- Text Content: `#94A3B8`
- Title: White

### Light Theme
- Uses standard light colors with good contrast

## Getting Started

### Prerequisites
- Flutter SDK (version 3.6.0 or higher)
- Dart SDK (version 3.6.0 or higher)

### Installation

1. Clone the repository
   ```
   git clone https://github.com/yourusername/note-taking-app.git
   ```

2. Navigate to the project directory
   ```
   cd note-taking-app
   ```

3. Make sure you have the Linux desktop development dependencies installed
   ```
   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
   ```

4. Install dependencies
   ```
   flutter pub get
   ```

5. Enable Linux desktop support (if not already enabled)
   ```
   flutter config --enable-linux-desktop
   ```

6. Run the app
   ```
   flutter run -d linux
   ```

## Building for Production

### Linux (Primary Platform)
```
flutter build linux --release
```

You can create a Debian package for easy installation on Linux systems:
```
./build_deb.sh
```

### Other Platforms
While the app is primarily focused on Linux, the Flutter framework allows for cross-platform development. Support for the following platforms is planned but not fully tested:

```
flutter build <platform> --release
```

Where `<platform>` can be android, ios, web, windows, or macos.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to help improve the app.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## System Requirements

### Minimum Requirements for Linux
- Ubuntu 20.04 or newer (or equivalent Linux distribution)
- 4GB RAM
- 100MB disk space
- GTK 3.0 or newer

## Acknowledgments

- Thanks to all the package authors whose work made this app possible
- Inspiration from various note-taking apps in the market

# IDE Cache Mover - Flutter Desktop Application

A modern GUI application built with Flutter to move IDE cache folders from C: drive to D: drive using Windows junction links.

## Features

- ✅ Modern Material Design 3 UI
- ✅ Multiple IDE support (Cursor, VS Code, Claude, Windsurf, Discord, GitHub Desktop, Figma, OBS Studio)
- ✅ Checkbox selection interface
- ✅ Select All / Deselect All functionality
- ✅ Real-time status updates
- ✅ Progress indicators
- ✅ Junction detection (prevents duplicate moves)
- ✅ Confirmation dialog before moving
- ✅ Native Windows file operations (robocopy, mklink)

## Prerequisites

- Flutter SDK (latest stable version)
- Visual Studio with "Desktop development with C++" workload
- Windows 10/11

## Setup

1. **Enable Windows desktop support:**
   ```bash
   flutter config --enable-windows-desktop
   ```

2. **Install dependencies:**
   ```bash
   cd ide_cache_mover
   flutter pub get
   ```

## Running the Application

```bash
flutter run -d windows
```

## Building for Release

```bash
flutter build windows --release
```

The executable will be in `build\windows\x64\runner\Release\ide_cache_mover.exe`

## How It Works

1. The app scans `%APPDATA%` for installed IDE folders
2. Checks if folders are already moved (junction detection)
3. Allows you to select which IDEs to move
4. Uses `robocopy` to move files from `C:\Users\...\AppData\Roaming\` to `D:\AppData\Roaming\`
5. Creates Windows junction links so applications continue to work normally
6. All operations are performed through native Windows platform channels

## Supported IDEs

- Cursor
- VS Code
- VS Code Insiders
- Claude
- Windsurf
- Discord
- GitHub Desktop
- Figma
- OBS Studio

## Important Notes

⚠️ **Always close all selected applications before moving their folders!**

The app will show a warning dialog before proceeding with the move operation.

## Technical Details

- **Framework:** Flutter 3.35.7+
- **Language:** Dart 3.9.2+
- **Platform Channels:** Windows native C++ code for file operations
- **File Operations:** Uses Windows `robocopy` and `mklink` commands

## Project Structure

```
ide_cache_mover/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── ide_model.dart        # IDE data model
│   ├── screens/
│   │   └── home_screen.dart      # Main UI screen
│   └── services/
│       ├── file_operation_service.dart  # File operations service
│       └── ide_service.dart            # IDE management service
└── windows/
    └── runner/
        ├── file_ops_handler.h     # Platform channel header
        └── file_ops_handler.cpp   # Platform channel implementation
```

## License

This project is for personal use.

# Flutter Interview Prep — Interview Companion

A responsive Flutter study app for Senior Flutter interview preparation.

## What's included

- Responsive UI for phone, tablet, web, and desktop
- Topic sidebar on desktop and drawer/horizontal topic pills on smaller devices
- Font size controls (`- / +`)
- Global search across all questions and answers
- Favorites/bookmarks with local persistence
- Confidence rating per question with local persistence
- Reading Mode for distraction-free review
- CEO / Mock Interview Mode with random questions and hidden answers
- Desktop Sticker Mode controls beside the font controls
- Desktop opacity slider
- Always-on-top toggle
- Hide-title-bar toggle
- In-app plugin explanation

## Desktop Sticker Mode

The desktop window features use the `window_manager` plugin.

Supported desktop platforms:

- macOS
- Windows
- Linux

The app safely falls back on mobile and web, where native desktop window APIs are not available.

### Why a plugin is required

Flutter can draw the UI, but desktop window behavior belongs to the operating system. Features like opacity, always-on-top, frameless title bars, and click-through require native desktop APIs. `window_manager` exposes those native APIs to Flutter.

### Click-through note

Click-through mode is intentionally left as a safe planned control in this build. A real click-through overlay should also include a global shortcut or tray/menu-bar recovery option; otherwise, the user may not be able to click the app again to disable it.

Recommended future plugins:

- `hotkey_manager` for global shortcut recovery
- `tray_manager` for tray/menu-bar controls
- `screen_retriever` for multi-monitor positioning

## Run

```bash
flutter pub get
flutter run -d macos
flutter run -d windows
flutter run -d linux
flutter run -d chrome
flutter run -d ios
flutter run -d android
```

## Main files

- `lib/screens/home_screen.dart` — responsive UI, search, favorites, reading mode, CEO mode, sticker controls
- `lib/services/window_transparency/` — conditional desktop window service
- `lib/models/topics_data.dart` — interview content

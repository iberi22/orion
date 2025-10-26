# Technology Stack & Build System

## Core Technologies

- **Framework:** Flutter (Dart SDK ^3.7.2)
- **UI Library:** shadcn_flutter for clean, minimalist components
- **Backend:** Firebase (Firestore, Firebase AI)
- **Local Database:** Isar for agent memory and local storage
- **Audio:** flutter_sound, just_audio for voice interaction

## Key Dependencies

- `shadcn_flutter` - Primary UI component library
- `firebase_core`, `cloud_firestore` - Backend services
- `firebase_ai` - AI integration
- `isar` - Local database and agent memory
- `google_fonts` - Typography
- `flutter_dotenv` - Environment configuration
- `permission_handler` - Device permissions for audio

## Development Commands

### Setup & Dependencies

```bash
flutter pub get          # Install dependencies
```

### Development

```bash
flutter run             # Run the application
flutter analyze         # Code analysis and linting
flutter test           # Run unit tests
```

### Code Quality

- Uses `flutter_lints` package for code style enforcement
- Follows Effective Dart style guide
- Analysis rules defined in `analysis_options.yaml`

## Build Targets

- Android (primary)
- iOS
- Web
- Windows, macOS, Linux (desktop support)

## Environment Configuration

- Uses `.env` file for environment variables
- Firebase configuration via `firebase_options.dart`
- Multi-platform Firebase setup (Android, iOS, Web, Windows, macOS)

# Project Structure & Organization

## Root Directory Structure

```
orion/
├── lib/                    # Main application code
├── android/               # Android platform files
├── ios/                   # iOS platform files
├── web/                   # Web platform files
├── windows/               # Windows platform files
├── macos/                 # macOS platform files
├── linux/                 # Linux platform files
├── test/                  # Unit and widget tests
├── docs/                  # Project documentation
├── documentacion_aetheria/ # Detailed project docs
└── functions/             # Firebase Cloud Functions
```

## Application Code Structure (`lib/`)

```
lib/
├── main.dart              # Application entry point
├── firebase_options.dart  # Firebase configuration
├── models/               # Data models and entities
│   └── chat_message.dart
├── services/             # Business logic and external integrations
│   ├── ai_service.dart
│   ├── chat_service.dart
│   └── firestore_service.dart
├── state/                # State management (currently empty)
└── ui/                   # User interface screens and widgets
    ├── welcome_screen.dart
    ├── chat_screen.dart
    ├── voice_chat_screen.dart
    ├── meditation_screen.dart
    ├── signin_screen.dart
    └── signup_screen.dart
```

## Architecture Patterns

- **UI Layer:** Screen-based organization with shadcn_flutter components
- **Service Layer:** Separate services for AI, chat, and Firestore operations
- **Model Layer:** Data models for application entities
- **State Management:** Prepared structure (state/ directory ready for implementation)

## Key Files

- `pubspec.yaml` - Dependencies and Flutter configuration
- `analysis_options.yaml` - Code analysis and linting rules
- `firebase.json` - Firebase project configuration
- `.env` - Environment variables (not committed)

## Documentation Structure

- `docs/` - General project documentation
- `documentacion_aetheria/` - Detailed project specifications, epics, and planning
- `GEMINI.md` - Development guidelines and AI assistant instructions
- `README.md` - Project overview and getting started guide

## Naming Conventions

- **Files:** snake_case for Dart files
- **Classes:** PascalCase
- **Variables/Functions:** camelCase
- **Directories:** lowercase with underscores

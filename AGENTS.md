# Agent Guidelines - CalmMind

## Project Overview
CalmMind is a Flutter application for mental wellness using an MVVM architecture and Firebase backend.

## Tech Stack
- **Framework:** Flutter (SDK >= 3.7.0)
- **State Management:** `provider`
- **Backend:** Firebase (Authentication, Cloud Firestore)
- **Architecture:** MVVM (Model-View-ViewModel)

## Directory Structure
- `lib/viewmodels/`: Business logic for screens (ViewModel).
- `lib/ui/view/`: Main application screens.
- `lib/ui/widgets/`: Reusable UI components.
- `lib/ui/constants/`: UI constants and styling.
- `lib/services/`: API and business logic services.
- `lib/repositories/`: Data abstraction layer.
- `lib/models/`: Data models.
- `lib/providers/`: State providers.

## Developer Commands
- **Dependencies:** `flutter pub get`
- **Linting:** `flutter analyze`
- **Execution:** `flutter run`

## Conventions & Constraints
- **MVVM Pattern:** Maintain strict separation between UI (`lib/ui/`) and business logic (`lib/viewmodels/`).
- **Environment:** Use `.env` for environment-specific keys.
- **Styling:** Refer to `lib/ui/constants/app_constants.dart` for consistent styling.
- **Firebase:** Firebase configuration is managed in `lib/firebase_options.dart`.

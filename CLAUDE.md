# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Running the app
```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Run with hot reload (development mode)
flutter run --debug

# Run in release mode
flutter run --release
```

### Building
```bash
# Build APK (Android)
flutter build apk

# Build app bundle (Android)
flutter build appbundle

# Build iOS app
flutter build ios

# Analyze code for issues
flutter analyze
```

### Localization
```bash
# Generate localization files after editing ARB files
flutter gen-l10n

# ARB files are in lib/l10n/
# - app_es.arb (Spanish - template)
# - app_en.arb (English)
```

### Dependency Management
```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Clean build artifacts
flutter clean && flutter pub get
```

### Testing
```bash
# Run all tests (note: test directory currently empty)
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart

# Run tests with coverage
flutter test --coverage
```

## Architecture Overview

This is a Flutter app following **Clean Architecture** with three distinct layers:

### Layer Structure

**Domain Layer** (`features/*/domain/`)
- Pure Dart business logic with zero Flutter dependencies
- Contains entities, repository interfaces, and use cases
- Example: `features/auth/domain/entities/user.dart`

**Data Layer** (`features/*/data/`)
- Implements domain repository interfaces
- Manages data sources (remote HTTP + local SharedPreferences)
- Models extend entities and add JSON serialization
- Example: `features/auth/data/repositories/auth_data_repository.dart`

**Presentation Layer** (`features/*/presentation/`)
- UI components (pages, widgets) and BLoC state management
- Example: `features/auth/presentation/bloc/auth_bloc.dart`

### Dependency Flow
```
Presentation → Domain ← Data
```
- Presentation depends on Domain abstractions
- Data implements Domain interfaces
- Domain has no dependencies (pure Dart)

## Key Architectural Patterns

### Dependency Injection (GetIt)

All dependencies are registered in `lib/core/injection_container.dart`:

```dart
import 'package:photo_manager_app/core/injection_container.dart';

// Access registered dependencies
final authBloc = sl<AuthBloc>();
final loginUseCase = sl<LoginUseCase>();
```

**Registration order matters:**
1. External dependencies (http.Client, SharedPreferences)
2. Data sources (remote + local)
3. Repositories
4. Use cases
5. BLoCs

### State Management (flutter_bloc)

**BLoC Pattern:**
- Events trigger business logic
- States represent UI snapshots
- BLoCs registered as singletons (AuthBloc) or factories (ProfileBloc)

**Minimum loading duration pattern:**
AuthBloc ensures loading states display for minimum 800ms to prevent flicker.

### Routing (go_router)

Router configuration: `lib/core/navigation/app_router.dart`

**Key features:**
- Authentication-based redirects via `AuthNotifier`
- Bottom navigation with `StatefulShellRoute`
- Route constants in `RoutePaths` and `RouteNames` classes

**Adding new routes:**
1. Add path to `RoutePaths` class
2. Add name to `RouteNames` class
3. Register route in `app_router.dart`

### Error Handling

Comprehensive error system in `lib/core/errors/`:

**Failure hierarchy** (`base/failures.dart`):
- 17 specific failure types (NetworkFailure, ValidationFailure, etc.)
- Localized error messages via `messageKey` property
- Support for parameterized error messages

**Error display:**
```dart
// Show error as SnackBar
ErrorNotificationService.showError(
  context,
  failure,
  config: ErrorDisplayConfig.snackBar,
  onRetry: () { /* retry logic */ }
);

// Show error as Dialog
ErrorNotificationService.showError(
  context,
  failure,
  config: ErrorDisplayConfig.dialog
);

// Full-page error state
ErrorDisplay(
  failure: failure,
  onRetry: () { /* reload */ }
)
```

**Note:** `lib/core/errors/handler/error_handler.dart` needs implementation to convert Exceptions to Failures.

### Localization

The app supports English and Spanish with Spanish as default.

**Adding new translations:**
1. Add key-value pairs to both `lib/l10n/app_es.arb` and `lib/l10n/app_en.arb`
2. Run `flutter gen-l10n` to regenerate localization files
3. Use in code: `AppLocalizations.of(context)!.yourKey`

**Parameterized messages:**
```dart
// In ARB file
"errorRequiredField": "The field {fieldName} is required"

// In code
l10n.errorRequiredField('email')
```

## Common Development Workflows

### Adding a new feature

Follow the existing feature structure (`auth` and `profile` as examples):

```
features/
  your_feature/
    data/
      data_sources/
        your_feature_remote_data_source.dart  # HTTP API calls
        your_feature_local_data_source.dart   # SharedPreferences cache
      models/
        your_model.dart                        # Extends domain entity
      repositories/
        your_feature_data_repository.dart      # Implements domain interface
    domain/
      entities/
        your_entity.dart                       # Pure Dart class
      repositories/
        your_feature_repository.dart           # Abstract interface
      use_cases/
        your_use_case.dart                     # Business logic
    presentation/
      bloc/
        your_bloc.dart
        your_state.dart
        your_event.dart
      pages/
        your_page.dart
      widgets/
        your_widget.dart
```

**Then register in DI container:**
1. Add data sources to `injection_container.dart`
2. Add repository
3. Add use cases (as factories)
4. Add BLoC

### Working with BLoCs

**Creating events:**
```dart
// In BLoC file
on<YourEvent>(_onYourEvent);

Future<void> _onYourEvent(YourEvent event, Emitter<YourState> emit) async {
  emit(YourLoading());
  try {
    final result = await yourUseCase();
    emit(YourSuccess(result));
  } catch (e) {
    final failure = ErrorHandler.handleError(e);
    emit(YourError(failure));
  }
}
```

**Consuming in UI:**
```dart
BlocConsumer<YourBloc, YourState>(
  listener: (context, state) {
    // Side effects (navigation, snackbars, etc.)
    if (state is YourError) {
      ErrorNotificationService.showError(context, state.failure);
    }
  },
  builder: (context, state) {
    // Build UI based on state
    if (state is YourLoading) return CircularProgressIndicator();
    if (state is YourSuccess) return YourContent(state.data);
    return Container();
  }
)
```

### Repository Pattern

**Cache-first strategy example:**
```dart
@override
Future<YourEntity> getData() async {
  try {
    // Try remote first
    final model = await remoteDataSource.getData();
    await localDataSource.cache(model);
    return model;
  } catch (e) {
    // Fallback to cache
    final cached = await localDataSource.getCached();
    if (cached != null) return cached;
    rethrow;
  }
}
```

### Model-Entity Pattern

```dart
// Domain entity (pure Dart)
class YourEntity {
  final String id;
  final String name;

  YourEntity({required this.id, required this.name});
}

// Data model (adds JSON serialization)
class YourModel extends YourEntity {
  YourModel({required super.id, required super.name});

  factory YourModel.fromJson(Map<String, dynamic> json) {
    return YourModel(
      id: json['id'],
      name: json['name']
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
```

## Project Configuration

### Backend API
Base URL for Android emulator: `http://10.0.2.2:8080`
- Located in remote data source implementations
- Change for production/different environments

### Theme Colors
Primary color: `#5D5BE9` (purple)
- Defined in `lib/config/theme/photo_manager_colors.dart`

### Flutter Version
- SDK: 3.10.1+
- Dart: 3.10.1

## Current Implementation Status

**Completed features:**
- Authentication (login, logout, token management)
- Profile (view profile, storage stats, device management)
- Localization (English/Spanish)
- Error handling infrastructure
- Navigation with bottom nav bar

**Incomplete/TODO:**
- Error handler implementation (`ErrorHandler.handleError()` method)
- Home, Folders, Sync, and Notifications pages (placeholder routes exist)
- Test coverage (test directory is empty)
- Standardize error states (ProfileBloc uses String, should use Failure like AuthBloc)

## Important Notes

- **Android Emulator:** Use `10.0.2.2` to access localhost on host machine
- **Token Management:** Tokens stored via AuthLocalDataSource, accessed by ProfileRemoteDataSource
- **Logout Cleanup:** Always clears both auth and profile caches
- **Route Protection:** AuthNotifier listens to AuthBloc and triggers redirects automatically
- **Loading States:** Use minimum 800ms duration pattern from AuthBloc for consistent UX
- **Widget Composition:** Break large pages into focused widgets (see login widgets as example)

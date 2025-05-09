# Immigru Flutter Application

A Flutter application built with clean architecture principles.

## Project Structure

This project follows clean architecture principles with the following layers:

```
lib/
├── core/              # Core functionality and utilities
│   ├── constants/     # Application constants
│   ├── errors/        # Error handling
│   ├── network/       # Network utilities
│   ├── utils/         # General utilities
│   └── di/            # Dependency injection
├── data/              # Data layer
│   ├── datasources/   # Data sources (remote/local)
│   ├── models/        # Data models
│   └── repositories/  # Repository implementations
├── domain/            # Domain layer
│   ├── entities/      # Business entities
│   ├── repositories/  # Repository interfaces
│   └── usecases/      # Use cases
└── presentation/      # Presentation layer
    ├── blocs/         # BLoCs for state management
    ├── pages/         # UI screens
    └── widgets/       # Reusable UI components
```

## Features

- Authentication (Login/Signup)
- Clean Architecture
- BLoC Pattern for State Management
- Supabase Integration

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- Supabase account and project

### Setup

1. Clone the repository
2. Update the Supabase credentials in `lib/core/constants/app_constants.dart`
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Configuration

To configure Supabase, update the following values in `lib/core/constants/app_constants.dart`:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

## Dependencies

- flutter_bloc: State management
- equatable: Value equality
- get_it: Dependency injection
- supabase_flutter: Supabase client
- shared_preferences: Local storage
- formz: Form validation

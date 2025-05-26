# Immigru - Immigration Community Platform

## Overview
Immigru is a Flutter-based mobile application designed to help immigrants connect, share experiences, and navigate their migration journey. The app provides a social platform with features like posts, comments, events, and specialized immigration groups called ImmiGroves.

## Architecture
This project follows **Feature-First Clean Architecture** principles, ensuring scalability, maintainability, and testability.

### Project Structure
```
lib/
├── app.dart                 # Main application widget
├── main.dart               # Entry point
├── core/                   # Shared infrastructure
│   ├── config/            # App configuration
│   ├── di/                # Dependency injection
│   ├── error/             # Error handling
│   ├── network/           # Network layer
│   └── storage/           # Local storage
├── features/              # Feature modules
│   ├── auth/             # Authentication
│   ├── home/             # Main feed
│   ├── onboarding/       # User onboarding
│   ├── profile/          # User profiles
│   └── welcome/          # Welcome screens
└── shared/               # Shared UI components
    ├── theme/           # App theming
    └── widgets/         # Reusable widgets
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Supabase account for backend services

### Installation
1. Clone the repository
```bash
git clone https://github.com/yourusername/immigru-flutter.git
cd immigru-flutter
```

2. Install dependencies
```bash
flutter pub get
```

3. Set up environment variables
Create a `.env` file with your Supabase credentials:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. Run the app
```bash
flutter run
```

## Development

### Architecture Guidelines
- Follow clean architecture principles
- Each feature should be self-contained
- Use BLoC pattern for state management
- Implement dependency injection for all services
- Write unit tests for business logic

### Code Style
- Follow Flutter's official style guide
- Use meaningful variable and function names
- Document complex logic with comments
- Keep functions small and focused

### Adding New Features
1. Create a new directory under `/lib/features/`
2. Implement the three-layer architecture:
   - `domain/` - Business logic and entities
   - `data/` - API and repository implementations
   - `presentation/` - UI and state management
3. Register dependencies in the feature's DI module
4. Add the module to `FeatureModule.registerAll()`

## Dependencies
- **State Management**: flutter_bloc
- **Backend**: supabase_flutter
- **DI**: get_it
- **Network**: dio
- **Storage**: shared_preferences, flutter_secure_storage

## Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Contributing
Please read our contributing guidelines before submitting PRs.

## License
This project is licensed under the MIT License.

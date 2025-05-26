# Immigru Code Style Guide

## Dart/Flutter Style

### Naming Conventions
- **Classes**: PascalCase (e.g., `UserProfile`, `AuthBloc`)
- **Files**: snake_case (e.g., `user_profile.dart`, `auth_bloc.dart`)
- **Variables/Functions**: camelCase (e.g., `userName`, `getUserData()`)
- **Constants**: lowerCamelCase with `const` prefix (e.g., `const defaultTimeout`)
- **Private members**: Leading underscore (e.g., `_privateMethod()`)

### File Organization
```dart
// 1. Imports (sorted alphabetically within groups)
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:immigru/core/error/failures.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';

// 2. Part files (if any)
part 'auth_event.dart';
part 'auth_state.dart';

// 3. Constants
const int maxRetries = 3;

// 4. Main class/widget
class AuthScreen extends StatelessWidget {
  // ...
}

// 5. Helper classes/widgets
class _AuthForm extends StatefulWidget {
  // ...
}
```

### Documentation
```dart
/// Brief description of the class/function.
/// 
/// Longer description if needed, explaining purpose,
/// behavior, and any important details.
/// 
/// Example:
/// ```dart
/// final result = await getUserData(userId);
/// ```
class UserRepository {
  /// Gets user data from the remote server.
  /// 
  /// [userId] The unique identifier of the user
  /// Returns [User] on success or throws [ServerException]
  Future<User> getUserData(String userId) async {
    // Implementation
  }
}
```

### BLoC Pattern
```dart
// Events should be immutable
@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

// States should be immutable
@immutable
abstract class AuthState extends Equatable {
  const AuthState();
}

// BLoC naming: FeatureNameBloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }
}
```

### Error Handling
```dart
// Use Either for expected errors
Future<Either<Failure, User>> getUser() async {
  try {
    final user = await dataSource.fetchUser();
    return Right(user);
  } on ServerException {
    return Left(ServerFailure(message: 'Failed to fetch user'));
  }
}

// Use try-catch for unexpected errors
try {
  await riskyOperation();
} catch (e, stackTrace) {
  logger.error('Operation failed', e, stackTrace);
  rethrow;
}
```

### Widget Best Practices
```dart
// Prefer const constructors
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Text('Hello');
  }
}

// Extract complex widgets
class ComplexScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildContent(),
          _buildFooter(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() => const Header();
  Widget _buildContent() => const Content();
  Widget _buildFooter() => const Footer();
}
```

### Testing
```dart
// Test file naming: feature_name_test.dart
// Test descriptions should be clear and specific
void main() {
  group('AuthBloc', () {
    test('should emit [Loading, Success] when login is successful', () async {
      // Arrange
      when(mockUseCase.execute(any))
          .thenAnswer((_) async => Right(user));
      
      // Act
      bloc.add(LoginRequested(email: email, password: password));
      
      // Assert
      await expectLater(
        bloc.stream,
        emitsInOrder([Loading(), Success(user)]),
      );
    });
  });
}
```

## Git Commit Messages
- Use present tense: "Add feature" not "Added feature"
- Use imperative mood: "Move cursor to..." not "Moves cursor to..."
- Limit first line to 72 characters
- Reference issues and pull requests

Example:
```
feat: Add user authentication with Google Sign-In

- Implement Google OAuth flow
- Add error handling for auth failures
- Update UI with sign-in button

Fixes #123
```

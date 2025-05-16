# Auth Feature

This module implements the authentication feature for the Immigru application following clean architecture principles.

## Architecture

The auth feature follows the clean architecture pattern with the following layers:

### Domain Layer
- **Entities**: Core business objects (User)
- **Repositories**: Abstract interfaces defining data operations
- **Use Cases**: Application-specific business rules

### Data Layer
- **Data Sources**: Implementation of data access (Supabase)
- **Models**: Data transfer objects
- **Repository Implementations**: Concrete implementations of domain repositories

### Presentation Layer
- **BLoC**: State management using the BLoC pattern
- **Screens**: UI components
- **Widgets**: Reusable UI elements

## Features

The auth feature provides the following functionality:

- **Email/Password Authentication**: Sign in and sign up with email and password
- **Phone Authentication**: Sign in with phone number and OTP verification
- **Social Authentication**: Sign in with Google
- **Password Reset**: Reset password via email
- **Session Management**: Automatic session persistence and restoration

## Screens

1. **Login Screen**: Email/password and phone login options
2. **Signup Screen**: New user registration
3. **Phone Verification Screen**: OTP verification for phone authentication
4. **Forgot Password Screen**: Password reset flow

## Integration

To integrate the auth feature into the main application:

```dart
// Initialize the auth feature
final authFeature = AuthFeature(serviceLocator);
await authFeature.initialize();

// Add auth routes to your app
MaterialApp(
  routes: {
    ...authFeature.getRoutes(),
  },
  onGenerateRoute: (settings) {
    // Try auth routes first
    final authRoute = authFeature.generateRoute(settings);
    if (authRoute != null) {
      return authRoute;
    }
    
    // Other route handling
  },
);

// Provide the auth bloc
MultiBlocProvider(
  providers: [
    authFeature.provideBloc(),
  ],
  child: AppContent(),
);
```

## Authentication Flow

1. **Email/Password Authentication**:
   - User enters email and password
   - Credentials are validated
   - Authentication request is sent to Supabase
   - On success, user profile is fetched and stored

2. **Phone Authentication**:
   - User enters phone number
   - OTP is sent to the phone
   - User enters OTP code
   - Code is verified with Supabase
   - On success, user profile is fetched and stored

3. **Social Authentication**:
   - User clicks on social login button
   - OAuth flow is initiated
   - On success, user profile is fetched and stored

## Dependency Injection

The auth feature uses GetIt for dependency injection. All dependencies are registered in the `auth_module.dart` file.

## Navigation

The auth feature provides its own route configuration in `auth_routes.dart`. This allows for easy integration with the main app's navigation system.

## Future Improvements

- Add more social login options (Apple, Facebook, etc.)
- Implement biometric authentication
- Add multi-factor authentication
- Improve error handling and user feedback

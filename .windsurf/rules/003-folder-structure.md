---
trigger: model_decision
description: Before creating a new file or folder check if already exists and if still create update this file
---

lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   ├── di/
│   │   └── injection_container.dart
│   └── services/
│       ├── logger_service.dart
│       └── supabase_service.dart
├── data/
│   ├── datasources/
│   │   └── supabase_data_source.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       └── auth_usecases.dart
└── presentation/
    ├── blocs/
    │   └── auth/
    │       ├── auth_bloc.dart
    │       ├── auth_event.dart
    │       └── auth_state.dart
    ├── screens/
    │   ├── auth/
    │   │   ├── login_screen.dart
    │   │   ├── otp_verification_screen.dart
    │   │   └── widgets/
    │   │       └── login/
    │   │           └── phone_login_button.dart
    │   └── home/
    │       └── home_screen.dart
    └── theme/
        └── app_theme.dart
---
trigger: always_on
---

lib/
├── core
│   ├── config
│   ├── di
│   ├── logging
│   ├── services
│   └── utils
├── data
│   ├── datasources
│   │   ├── remote
│   ├── models
│   └── repositories
├── domain
│   ├── entities
│   ├── interfaces
│   ├── repositories
│   └── usecases
├── features
│   ├── auth
│   │   ├── data
│   │   │   ├── datasources
│   │   │   ├── models
│   │   │   └── repositories
│   │   ├── di
│   │   ├── domain
│   │   │   ├── entities
│   │   │   ├── repositories
│   │   │   ├── usecases
│   │   │   └── utils
│   │   └── presentation
│   │       ├── bloc
│   │       ├── routes
│   │       ├── screens
│   │       └── widgets
│   ├── onboarding
│   │   │   └── usecases
│   │       │   ├── birth_country
│   │       │   └── onboarding
│   │       ├── data
│   │       ├── domain
│   │       ├── presentation
│   │           └── birth_country
│   ├── profile
│   │   └── di
│   └── welcome
│       ├── di
│       └── presentation
│           ├── bloc
│           └── screens
├── new_core
│   │   ├── modules
│   ├── network
│   │   ├── interceptors
│   │   └── models
│   ├── storage
├── presentation
│   ├── blocs
│   │   ├── auth
│   │   ├── home
│   │   ├── immi_grove
│   │   ├── migration_steps
│   │   ├── onboarding
│   │   └── profile
│   ├── screens
│   │   │   └── widgets
│   │   │       ├── _shared
│   │   │       ├── login
│   │   │       └── signup
│   │   │       ├── migration_journey
│   │   │       └── profile
│   │   └── welcome
│   ├── theme
│   └── widgets
│       ├── auth
│       ├── community
│       ├── feature
└── shared
    ├── interfaces
    ├── models
    ├── theme
    ├── utils
    └── widgets
│       │   ├── custom_button.dart
│       │   ├── custom_text_field.dart
│       │   └── social_login_button.dart
│       ├── community
│       │   └── community_feed_item.dart
│       ├── country_selector.dart
│       ├── error_message_widget.dart
│       ├── feature
│       │   └── feature_item.dart
│       └── loading_indicator.dart
└── shared
    ├── interfaces
    │   └── logger_interface.dart
    ├── models
    ├── theme
    │   ├── app_colors.dart
    │   ├── app_text_styles.dart
    │   ├── app_theme.dart
    │   └── theme_provider.dart
    ├── utils
    └── widgets
        ├── error_display.dart
        └── secure_input_field.dart
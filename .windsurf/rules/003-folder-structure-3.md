lib/
├── core
│   ├── config
│   ├── country
│   │   ├── data
│   │   │   └── repositories
│   │   ├── di
│   │   └── domain
│   │       ├── entities
│   │       ├── repositories
│   │       └── usecases
│   ├── di
│   │   ├── modules
│   ├── logging
│   ├── network
│   │   ├── interceptors
│   │   └── models
│   ├── storage
│   └── utils
├── features
│   ├── auth
│   │   │   ├── datasources
│   │   │   ├── models
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
│   ├── home
│   │   │   └── usecases
│   │           └── tabs
│   ├── onboarding
│   │       │   ├── birth_country
│   │       │   ├── current_status
│   │       │   ├── immi_grove
│   │       │   ├── interest
│   │       │   ├── language
│   │       │   ├── migration_journey
│   │       │   ├── onboarding
│   │       │   └── profession
│   │       ├── common
│   │       ├── data
│   │       ├── domain
│   │       ├── steps
│   │           ├── birth_country
│   │           ├── current_status
│   │           ├── interest
│   │           ├── language
│   │           ├── migration_journey
│   │           ├── profession
│   ├── profile
│   │   └── di
│   └── welcome
│       ├── di
│       ├── presentation
│       │   ├── bloc
│       │   └── screens
└── shared
    ├── theme
    └── widgets
│   │           │   └── birth_country_step_widget.dart
│   │           ├── country_selector.dart
│   │           ├── current_status
│   │           │   └── current_status_step_widget.dart
│   │           ├── interest
│   │           │   └── interest_step_widget.dart
│   │           ├── language
│   │           │   └── language_step_widget.dart
│   │           ├── migration_journey
│   │           │   ├── migration_journey_step_widget.dart
│   │           │   ├── migration_step_modal.dart
│   │           │   └── migration_timeline_widget.dart
│   │           ├── profession
│   │           │   ├── profession_step_widget_new.dart
│   │           │   └── profession_step_widget.dart
│   │           └── visa_selector.dart
│   ├── profile
│   │   └── di
│   └── welcome
│       ├── di
│       │   └── welcome_module.dart
│       ├── presentation
│       │   ├── bloc
│       │   │   ├── welcome_bloc.dart
│       │   │   ├── welcome_event.dart
│       │   │   └── welcome_state.dart
│       │   └── screens
│       │       └── welcome_screen.dart
│       └── welcome_feature.dart
├── main.dart
└── shared
    ├── theme
    │   ├── app_colors.dart
    │   ├── app_text_styles.dart
    │   ├── app_theme.dart
    │   └── theme_provider.dart
    └── widgets
        ├── app_logo.dart
        ├── country_selector.dart
        ├── error_display.dart
        ├── error_message_widget.dart
        ├── loading_indicator.dart
        ├── pulsing_fab.dart
        └── secure_input_field.dart
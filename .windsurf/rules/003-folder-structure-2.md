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
│   │       │   ├── current_status
│   │       │   ├── migration_journey
│   │       │   └── onboarding
│   │       ├── data
│   │       ├── domain
│   │           ├── birth_country
│   │           ├── current_status
│   │           ├── migration_journey
│   ├── profile
│   │   └── di
│   └── welcome
│       ├── di
│       └── presentation
│           ├── bloc
│           └── screens
├── new_core
│   ├── country
│   │   └── domain
│   │       ├── entities
│   │       ├── repositories
│   │       └── usecases
│   │   ├── modules
│   ├── network
│   │   ├── interceptors
│   │   └── models
│   └── storage
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
    ├── theme
    └── widgets
│   │       │   │   ├── birth_country_bloc.dart
│   │       │   │   ├── birth_country_event.dart
│   │       │   │   └── birth_country_state.dart
│   │       │   ├── current_status
│   │       │   │   ├── current_status_bloc.dart
│   │       │   │   ├── current_status_event.dart
│   │       │   │   └── current_status_state.dart
│   │       │   ├── migration_journey
│   │       │   │   ├── migration_journey_bloc.dart
│   │       │   │   ├── migration_journey_event.dart
│   │       │   │   └── migration_journey_state.dart
│   │       │   └── onboarding
│   │       │       ├── onboarding_bloc.dart
│   │       │       ├── onboarding_event.dart
│   │       │       └── onboarding_state.dart
│   │       ├── data
│   │       ├── domain
│   │       ├── screens
│   │       │   └── onboarding_screen.dart
│   │       └── widgets
│   │           ├── birth_country
│   │           │   └── birth_country_step_widget.dart
│   │           ├── country_selector.dart
│   │           ├── current_status
│   │           │   └── current_status_step_widget.dart
│   │           ├── migration_journey
│   │           │   ├── migration_journey_step_widget.dart
│   │           │   ├── migration_step_modal.dart
│   │           │   └── migration_timeline_widget.dart
│   │           └── visa_selector.dart
│   ├── profile
│   │   └── di
│   └── welcome
│       ├── di
│       │   └── welcome_module.dart
│       └── presentation
│           ├── bloc
│           │   ├── welcome_bloc.dart
│           │   ├── welcome_event.dart
│           │   └── welcome_state.dart
│           └── screens
│               └── welcome_screen.dart
├── main.dart
├── new_core
│   ├── country
│   │   ├── data
│   │   │   └── repositories
│   │   │       └── country_repository_impl.dart
│   │   ├── di
│   │   │   └── country_module.dart
│   │   └── domain
│   │       ├── entities
│   │       │   └── country.dart
│   │       ├── repositories
│   │       │   └── country_repository.dart
│   │       └── usecases
│   │           └── get_countries_usecase.dart
│   ├── di
│   │   ├── modules
│   │   │   ├── core_module.dart
│   │   │   ├── country_module.dart
│   │   │   ├── feature_module.dart
│   │   │   ├── logging_module.dart
│   │   │   ├── network_module.dart
│   │   │   ├── storage_module.dart
│   │   │   ├── supabase_module.dart
│   │   │   └── theme_module.dart
│   │   └── service_locator.dart
│   ├── logging
│   │   ├── log_util.dart
│   │   ├── logger_interface.dart
│   │   ├── logger_provider.dart
│   │   └── unified_logger.dart
│   ├── network
│   │   ├── api_client.dart
│   │   ├── edge_function_client.dart
│   │   ├── interceptors
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── logging_interceptor.dart
│   │   │   └── network_interceptor.dart
│   │   └── models
│   │       ├── api_response.dart
│   │       └── request_options.dart
│   └── storage
│       ├── local_storage.dart
│       └── secure_storage.dart
├── presentation
│   ├── blocs
│   │   ├── auth
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── home
│   │   │   ├── home_bloc.dart
│   │   │   ├── home_event.dart
│   │   │   └── home_state.dart
│   │   ├── immi_grove
│   │   │   ├── immi_grove_bloc.dart
│   │   │   ├── immi_grove_event.dart
│   │   │   └── immi_grove_state.dart
│   │   ├── migration_steps
│   │   │   ├── migration_steps_bloc.dart
│   │   │   ├── migration_steps_event.dart
│   │   │   └── migration_steps_state.dart
│   │   ├── onboarding
│   │   │   ├── onboarding_bloc.dart
│   │   │   ├── onboarding_event.dart
│   │   │   └── onboarding_state.dart
│   │   └── profile
│   │       ├── profile_bloc.dart
│   │       ├── profile_event.dart
│   │       └── profile_state.dart
│   ├── screens
│   │   ├── auth
│   │   │   ├── login_screen.dart
│   │   │   ├── otp_verification_screen.dart
│   │   │   ├── phone_login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── widgets
│   │   │       ├── _shared
│   │   │       │   ├── auth_footer.dart
│   │   │       │   ├── auth_google.dart
│   │   │       │   ├── auth_header.dart
│   │   │       │   └── auth_tabbar.dart
│   │   │       ├── login
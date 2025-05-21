---
trigger: model_decision
description: When creating new file or folder, check if doesnt already exist.
---

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
│   │   │   │   ├── immi_grove_repository.dart
│   │   │   │   ├── interest_repository.dart
│   │   │   │   ├── language_repository.dart
│   │   │   │   ├── migration_journey_repository.dart
│   │   │   │   ├── onboarding_feature_repository.dart
│   │   │   │   ├── onboarding_repository.dart
│   │   │   │   └── visa_repository.dart
│   │   │   └── usecases
│   │   │       ├── add_migration_step_usecase.dart
│   │   │       ├── check_onboarding_status_usecase.dart
│   │   │       ├── complete_onboarding_usecase.dart
│   │   │       ├── get_interests_usecase.dart
│   │   │       ├── get_joined_immi_groves_usecase.dart
│   │   │       ├── get_languages_usecase.dart
│   │   │       ├── get_migration_steps_usecase.dart
│   │   │       ├── get_onboarding_data_usecase.dart
│   │   │       ├── get_recommended_immi_groves_usecase.dart
│   │   │       ├── get_user_interests_usecase.dart
│   │   │       ├── get_user_languages_usecase.dart
│   │   │       ├── join_immi_grove_usecase.dart
│   │   │       ├── leave_immi_grove_usecase.dart
│   │   │       ├── remove_migration_step_usecase.dart
│   │   │       ├── save_migration_steps_usecase.dart
│   │   │       ├── save_onboarding_data_usecase.dart
│   │   │       ├── save_selected_immi_groves_usecase.dart
│   │   │       ├── save_user_interests_usecase.dart
│   │   │       ├── save_user_languages_usecase.dart
│   │   │       ├── update_birth_country_usecase.dart
│   │   │       ├── update_current_status_usecase.dart
│   │   │       └── update_migration_step_usecase.dart
│   │   ├── onboarding_feature.dart
│   │   └── presentation
│   │       ├── bloc
│   │       │   ├── birth_country
│   │       │   │   ├── birth_country_bloc.dart
│   │       │   │   ├── birth_country_event.dart
│   │       │   │   └── birth_country_state.dart
│   │       │   ├── current_status
│   │       │   │   ├── current_status_bloc.dart
│   │       │   │   ├── current_status_event.dart
│   │       │   │   └── current_status_state.dart
│   │       │   ├── immi_grove
│   │       │   │   ├── immi_grove_bloc.dart
│   │       │   │   ├── immi_grove_event.dart
│   │       │   │   └── immi_grove_state.dart
│   │       │   ├── interest
│   │       │   │   ├── interest_bloc.dart
│   │       │   │   ├── interest_event.dart
│   │       │   │   └── interest_state.dart
│   │       │   ├── language
│   │       │   │   ├── language_bloc.dart
│   │       │   │   ├── language_event.dart
│   │       │   │   └── language_state.dart
│   │       │   ├── migration_journey
│   │       │   │   ├── migration_journey_bloc.dart
│   │       │   │   ├── migration_journey_event.dart
│   │       │   │   └── migration_journey_state.dart
│   │       │   ├── onboarding
│   │       │   │   ├── immi_grove_events.dart
│   │       │   │   ├── onboarding_bloc.dart
│   │       │   │   ├── onboarding_event.dart
│   │       │   │   └── onboarding_state.dart
│   │       │   └── profession
│   │       │       ├── profession_bloc.dart
│   │       │       ├── profession_event.dart
│   │       │       └── profession_state.dart
│   │       ├── common
│   │       │   ├── base_onboarding_step.dart
│   │       │   ├── index.dart
│   │       │   ├── onboarding_gradient_header.dart
│   │       │   ├── onboarding_info_box.dart
│   │       │   ├── onboarding_migration_helper.dart
│   │       │   ├── onboarding_navigation_buttons.dart
│   │       │   ├── onboarding_progress_indicator.dart
│   │       │   ├── onboarding_step_factory.dart
│   │       │   ├── onboarding_step_header.dart
│   │       │   ├── onboarding_step_manager.dart
│   │       │   ├── onboarding_theme.dart
│   │       │   └── themed_card.dart
│   │       ├── data
│   │       ├── domain
│   │       ├── screens
│   │       │   └── onboarding_screen.dart
│   │       ├── steps
│   │       │   ├── birth_country
│   │       │   │   └── birth_country_step.dart
│   │       │   ├── current_status
│   │       │   │   └── current_status_step.dart
│   │       │   ├── immi_grove
│   │       │   │   └── immi_grove_step.dart
│   │       │   ├── index.dart
│   │       │   ├── interest
│   │       │   │   └── interest_step.dart
│   │       │   ├── language
│   │       │   │   └── language_step.dart
│   │       │   ├── migration_journey
│   │       │   │   └── migration_journey_step.dart
│   │       │   └── profession
│   │       │       └── profession_step.dart
│   │       └── widgets
│   │           ├── birth_country
│   │           │   └── birth_country_step_widget.dart
│   │           ├── country_selector.dart
│   │           ├── current_status
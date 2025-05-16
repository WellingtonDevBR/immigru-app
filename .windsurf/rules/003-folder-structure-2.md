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
│   │   ├── app_logger.dart
│   │   ├── base_logger.dart
│   │   ├── edge_function_logger.dart
│   │   └── logger_provider.dart
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
│   ├── storage
│   │   ├── local_storage.dart
│   │   └── secure_storage.dart
│   └── utils
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
│   │   │       │   ├── email_login_form.dart
│   │   │       │   ├── error_message.dart
│   │   │       │   ├── google_sign_in_button.dart
│   │   │       │   ├── login_tab_bar.dart
│   │   │       │   ├── login_widgets.dart
│   │   │       │   └── phone_login_button.dart
│   │   │       └── signup
│   │   │           ├── email_signup_form.dart
│   │   │           ├── phone_signup_form.dart
│   │   │           ├── signup_tab_bar.dart
│   │   │           ├── signup_widgets.dart
│   │   │           └── social_login_button.dart
│   │   ├── home
│   │   │   ├── home_screen.dart
│   │   │   └── widgets
│   │   │       ├── all_posts_tab.dart
│   │   │       ├── app_bar_widget.dart
│   │   │       ├── bottom_navigation.dart
│   │   │       ├── community_feed_item.dart
│   │   │       ├── create_post_card.dart
│   │   │       ├── create_post_dialog.dart
│   │   │       ├── events_tab.dart
│   │   │       ├── feature_grid.dart
│   │   │       ├── floating_action_button_widget.dart
│   │   │       ├── for_you_tab.dart
│   │   │       ├── immi_groves_tab.dart
│   │   │       └── tab_navigation.dart
│   │   ├── onboarding
│   │   │   ├── onboarding_screen.dart
│   │   │   └── widgets
│   │   │       ├── birth_country_step.dart
│   │   │       ├── current_status_step.dart
│   │   │       ├── immi_groves_step.dart
│   │   │       ├── interest_step.dart
│   │   │       ├── language_step.dart
│   │   │       ├── migration_journey
│   │   │       │   ├── enhanced_date_picker.dart
│   │   │       │   ├── index.dart
│   │   │       │   ├── migration_journey_header.dart
│   │   │       │   ├── migration_journey_step_widget.dart
│   │   │       │   ├── migration_step_modal.dart
│   │   │       │   └── migration_timeline.dart
│   │   │       ├── onboarding_progress_indicator.dart
│   │   │       ├── profession_step.dart
│   │   │       └── profile
│   │   │           ├── basic_info_step.dart
│   │   │           ├── bio_step.dart
│   │   │           ├── display_name_step.dart
│   │   │           ├── photo_step.dart
│   │   │           └── privacy_step.dart
│   │   └── welcome
│   │       └── welcome_screen.dart
│   ├── theme
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   └── widgets
│       ├── app_logo.dart
│       ├── auth
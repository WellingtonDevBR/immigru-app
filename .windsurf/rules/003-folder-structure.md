---
trigger: always_on
---

lib/
├── app.dart
├── core
│   ├── config
│   │   ├── google_auth_config.dart
│   │   └── supabase_config.dart
│   ├── di
│   │   └── injection_container.dart
│   ├── services
│   │   ├── auth_logger.dart
│   │   ├── edge_function_logger.dart
│   │   ├── logger_service.dart
│   │   ├── network_service.dart
│   │   ├── onboarding_service.dart
│   │   ├── session_manager.dart
│   │   ├── supabase_service.dart
│   │   └── theme_service.dart
│   └── utils
│       └── auth_debug_helper.dart
├── data
│   ├── datasources
│   │   ├── remote
│   │   │   └── user_profile_edge_function_data_source.dart
│   │   └── supabase_data_source.dart
│   ├── models
│   │   ├── country_model.dart
│   │   ├── interest_model.dart
│   │   ├── language_model.dart
│   │   ├── onboarding_data_model.dart
│   │   ├── profile_model.dart
│   │   ├── supabase_auth_context.dart
│   │   └── visa_model.dart
│   └── repositories
│       ├── auth_repository_impl.dart
│       ├── country_repository_impl.dart
│       ├── data_repository_impl.dart
│       ├── interest_repository_impl.dart
│       ├── language_repository_impl.dart
│       ├── onboarding_repository_impl.dart
│       ├── profile_repository_impl.dart
│       ├── supabase_auth_service.dart
│       └── visa_repository_impl.dart
├── domain
│   ├── entities
│   │   ├── auth_context.dart
│   │   ├── country.dart
│   │   ├── interest.dart
│   │   ├── language.dart
│   │   ├── onboarding_data.dart
│   │   ├── profile.dart
│   │   ├── user.dart
│   │   └── visa.dart
│   ├── repositories
│   │   ├── auth_repository.dart
│   │   ├── auth_service.dart
│   │   ├── country_repository.dart
│   │   ├── data_repository.dart
│   │   ├── interest_repository.dart
│   │   ├── language_repository.dart
│   │   ├── onboarding_repository.dart
│   │   ├── profile_repository.dart
│   │   └── visa_repository.dart
│   └── usecases
│       ├── auth_usecases.dart
│       ├── country_usecases.dart
│       ├── data_usecases.dart
│       ├── interest_usecases.dart
│       ├── language_usecases.dart
│       ├── onboarding_usecases.dart
│       ├── post_usecases.dart
│       └── profile_usecases.dart
├── main.dart
└── presentation
    ├── blocs
    │   ├── auth
    │   │   ├── auth_bloc.dart
    │   │   ├── auth_event.dart
    │   │   └── auth_state.dart
    │   ├── home
    │   │   ├── home_bloc.dart
    │   │   ├── home_event.dart
    │   │   └── home_state.dart
    │   ├── onboarding
    │   │   ├── onboarding_bloc.dart
    │   │   ├── onboarding_event.dart
    │   │   └── onboarding_state.dart
    │   └── profile
    │       ├── profile_bloc.dart
    │       ├── profile_event.dart
    │       └── profile_state.dart
    ├── screens
    │   ├── auth
    │   │   ├── login_screen.dart
    │   │   ├── otp_verification_screen.dart
    │   │   ├── phone_login_screen.dart
    │   │   ├── signup_screen.dart
    │   │   └── widgets
    │   │       ├── _shared
    │   │       │   ├── auth_footer.dart
    │   │       │   ├── auth_google.dart
    │   │       │   ├── auth_header.dart
    │   │       │   └── auth_tabbar.dart
    │   │       ├── login
    │   │       │   ├── email_login_form.dart
    │   │       │   ├── error_message.dart
    │   │       │   ├── google_sign_in_button.dart
    │   │       │   ├── login_tab_bar.dart
    │   │       │   ├── login_widgets.dart
    │   │       │   └── phone_login_button.dart
    │   │       └── signup
    │   │           ├── email_signup_form.dart
    │   │           ├── phone_signup_form.dart
    │   │           ├── signup_tab_bar.dart
    │   │           ├── signup_widgets.dart
    │   │           └── social_login_button.dart
    │   ├── home
    │   │   ├── home_screen.dart
    │   │   └── widgets
    │   │       ├── all_posts_tab.dart
    │   │       ├── app_bar_widget.dart
    │   │       ├── bottom_navigation.dart
    │   │       ├── community_feed_item.dart
    │   │       ├── create_post_card.dart
    │   │       ├── create_post_dialog.dart
    │   │       ├── events_tab.dart
    │   │       ├── feature_grid.dart
    │   │       ├── floating_action_button_widget.dart
    │   │       ├── for_you_tab.dart
    │   │       ├── immi_groves_tab.dart
    │   │       └── tab_navigation.dart
    │   ├── onboarding
    │   │   ├── onboarding_screen.dart
    │   │   └── widgets
    │   │       ├── birth_country_step.dart
    │   │       ├── current_status_step.dart
    │   │       ├── interest_step.dart
    │   │       ├── language_step.dart
    │   │       ├── migration_journey
    │   │       │   ├── enhanced_date_picker.dart
    │   │       │   ├── index.dart
    │   │       │   ├── migration_journey_header.dart
    │   │       │   ├── migration_journey_step_widget.dart
    │   │       │   ├── migration_step_modal.dart
    │   │       │   └── migration_timeline.dart
    │   │       ├── onboarding_progress_indicator.dart
    │   │       ├── profession_step.dart
    │   │       └── profile
    │   │           ├── basic_info_step.dart
    │   │           ├── bio_step.dart
    │   │           ├── display_name_step.dart
    │   │           ├── location_step.dart
    │   │           ├── photo_step.dart
    │   │           └── privacy_step.dart
    │   └── welcome
    │       └── welcome_screen.dart
    ├── theme
    │   ├── app_colors.dart
    │   └── app_theme.dart
    └── widgets
        ├── app_logo.dart
        ├── auth
        │   ├── custom_button.dart
        │   ├── custom_text_field.dart
        │   └── social_login_button.dart
        ├── community
        │   └── community_feed_item.dart
        ├── country_selector.dart
        ├── error_message_widget.dart
        ├── feature
        │   └── feature_item.dart
        └── loading_indicator.dart
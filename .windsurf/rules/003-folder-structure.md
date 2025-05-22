---
trigger: always_on
---

lib/
├── app.dart
├── core
│   ├── config
│   │   └── google_auth_config.dart
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
│   │   ├── logger_interface.dart
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
│   │       ├── failure.dart
│   │       └── request_options.dart
│   ├── storage
│   │   ├── local_storage.dart
│   │   └── secure_storage.dart
│   └── utils
│       └── input_validation.dart
├── features
│   ├── auth
│   │   ├── auth_feature.dart
│   │   ├── data
│   │   │   ├── datasources
│   │   │   │   └── auth_data_source.dart
│   │   │   ├── models
│   │   │   │   └── user_model.dart
│   │   │   └── repositories
│   │   │       └── auth_repository_impl.dart
│   │   ├── di
│   │   │   └── auth_module.dart
│   │   ├── domain
│   │   │   ├── entities
│   │   │   │   ├── auth_error.dart
│   │   │   │   └── user.dart
│   │   │   ├── repositories
│   │   │   │   └── auth_repository.dart
│   │   │   ├── usecases
│   │   │   │   ├── login_usecase.dart
│   │   │   │   ├── logout_usecase.dart
│   │   │   │   ├── reset_password_usecase.dart
│   │   │   │   └── signup_usecase.dart
│   │   │   └── utils
│   │   └── presentation
│   │       ├── bloc
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       ├── routes
│   │       │   └── auth_routes.dart
│   │       ├── screens
│   │       │   ├── forgot_password_screen.dart
│   │       │   ├── login_screen.dart
│   │       │   ├── phone_verification_screen.dart
│   │       │   └── signup_screen.dart
│   │       └── widgets
│   │           ├── auth_button.dart
│   │           ├── auth_error_banner.dart
│   │           ├── auth_footer.dart
│   │           ├── auth_header.dart
│   │           ├── auth_text_field.dart
│   │           ├── auth_wrapper.dart
│   │           ├── email_login_widget.dart
│   │           ├── error_message_widget.dart
│   │           ├── login_tab_bar.dart
│   │           ├── password_requirements_widget.dart
│   │           ├── phone_login_widget.dart
│   │           └── social_login_button.dart
│   ├── home
│   │   ├── data
│   │   │   ├── datasources
│   │   │   │   └── home_data_source.dart
│   │   │   ├── models
│   │   │   │   ├── event_model.dart
│   │   │   │   ├── immi_grove_model.dart
│   │   │   │   └── post_model.dart
│   │   │   └── repositories
│   │   │       └── home_repository_impl.dart
│   │   ├── di
│   │   │   └── home_module.dart
│   │   ├── domain
│   │   │   ├── entities
│   │   │   │   ├── event.dart
│   │   │   │   ├── immi_grove.dart
│   │   │   │   └── post.dart
│   │   │   ├── repositories
│   │   │   │   └── home_repository.dart
│   │   │   └── usecases
│   │   │       ├── create_post_usecase.dart
│   │   │       ├── get_events_usecase.dart
│   │   │       ├── get_personalized_posts_usecase.dart
│   │   │       └── get_posts_usecase.dart
│   │   ├── home_feature.dart
│   │   └── presentation
│   │       ├── bloc
│   │       │   ├── home_bloc.dart
│   │       │   ├── home_event.dart
│   │       │   └── home_state.dart
│   │       ├── screens
│   │       │   ├── home_screen.dart
│   │       │   └── post_creation_screen.dart
│   │       └── widgets
│   │           ├── app_bar_widget.dart
│   │           ├── bottom_navigation.dart
│   │           ├── create_post_dialog.dart
│   │           ├── floating_action_button.dart
│   │           ├── post_card.dart
│   │           ├── post_creation_widget.dart
│   │           ├── tab_navigation.dart
│   │           └── tabs
│   │               ├── all_posts_tab.dart
│   │               ├── events_tab.dart
│   │               ├── for_you_tab.dart
│   │               ├── immi_groves_tab.dart
│   │               └── notifications_tab.dart
│   ├── onboarding
│   │   ├── data
│   │   │   ├── datasources
│   │   │   │   ├── immi_grove_data_source.dart
│   │   │   │   ├── interest_data_source.dart
│   │   │   │   ├── language_data_source.dart
│   │   │   │   └── onboarding_data_source.dart
│   │   │   ├── models
│   │   │   │   ├── immi_grove_model.dart
│   │   │   │   ├── interest_model.dart
│   │   │   │   ├── language_model.dart
│   │   │   │   └── migration_step_model.dart
│   │   │   └── repositories
│   │   │       ├── immi_grove_repository_impl.dart
│   │   │       ├── interest_repository_impl.dart
│   │   │       ├── language_repository_impl.dart
│   │   │       ├── migration_journey_repository_impl.dart
│   │   │       ├── onboarding_repository_adapter.dart
│   │   │       ├── onboarding_repository_impl.dart
│   │   │       └── visa_repository_impl.dart
│   │   ├── di
│   │   │   ├── immi_grove_module.dart
│   │   │   ├── interest_module.dart
│   │   │   ├── language_module.dart
│   │   │   └── onboarding_module.dart
│   │   ├── domain
│   │   │   ├── entities
│   │   │   │   ├── immi_grove.dart
│   │   │   │   ├── interest.dart
│   │   │   │   ├── language.dart
│   │   │   │   ├── migration_reason.dart
│   │   │   │   ├── migration_status.dart
│   │   │   │   ├── migration_step.dart
│   │   │   │   ├── onboarding_data.dart
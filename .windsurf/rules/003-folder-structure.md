---
trigger: always_on
---

lib/
├── app_new.dart
├── app.dart
├── core
│   ├── config
│   │   ├── google_auth_config.dart
│   │   └── supabase_config.dart
│   ├── di
│   │   ├── injection_container.dart
│   │   └── logging_module.dart
│   ├── logging
│   │   ├── app_logger.dart
│   │   ├── base_logger.dart
│   │   ├── edge_function_logger.dart
│   │   └── logger_provider.dart
│   ├── services
│   │   ├── auth_logger.dart
│   │   ├── logger_service.dart
│   │   ├── network_service.dart
│   │   ├── onboarding_service.dart
│   │   ├── session_manager.dart
│   │   ├── supabase_service.dart
│   │   └── theme_service.dart
│   └── utils
│       ├── auth_debug_helper.dart
│       └── input_validation.dart
├── data
│   ├── datasources
│   │   ├── remote
│   │   │   ├── immi_grove_edge_function_data_source.dart
│   │   │   ├── migration_steps_edge_function_data_source.dart
│   │   │   └── user_profile_edge_function_data_source.dart
│   │   └── supabase_data_source.dart
│   ├── models
│   │   ├── country_model.dart
│   │   ├── immi_grove_model.dart
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
│       ├── immi_grove_repository_impl.dart
│       ├── interest_repository_impl.dart
│       ├── language_repository_impl.dart
│       ├── migration_steps_repository_impl.dart
│       ├── onboarding_repository_impl.dart
│       ├── profile_repository_impl.dart
│       ├── supabase_auth_service.dart
│       └── visa_repository_impl.dart
├── domain
│   ├── entities
│   │   ├── auth_context.dart
│   │   ├── country.dart
│   │   ├── immi_grove.dart
│   │   ├── interest.dart
│   │   ├── language.dart
│   │   ├── onboarding_data.dart
│   │   ├── profile.dart
│   │   ├── user.dart
│   │   └── visa.dart
│   ├── interfaces
│   │   └── logger_interface.dart
│   ├── repositories
│   │   ├── auth_repository.dart
│   │   ├── auth_service.dart
│   │   ├── country_repository.dart
│   │   ├── data_repository.dart
│   │   ├── immi_grove_repository.dart
│   │   ├── interest_repository.dart
│   │   ├── language_repository.dart
│   │   ├── migration_steps_repository.dart
│   │   ├── onboarding_repository.dart
│   │   ├── profile_repository.dart
│   │   └── visa_repository.dart
│   └── usecases
│       ├── auth_usecases.dart
│       ├── country_usecases.dart
│       ├── data_usecases.dart
│       ├── immi_grove_usecases.dart
│       ├── interest_usecases.dart
│       ├── language_usecases.dart
│       ├── migration_steps_usecases.dart
│       ├── onboarding_usecases.dart
│       ├── post_usecases.dart
│       └── profile_usecases.dart
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
│   │           ├── email_login_widget.dart
│   │           ├── error_message_widget.dart
│   │           ├── login_tab_bar.dart
│   │           ├── password_requirements_widget.dart
│   │           ├── phone_login_widget.dart
│   │           └── social_login_button.dart
│   ├── onboarding
│   │   ├── data
│   │   │   ├── datasources
│   │   │   │   └── onboarding_data_source.dart
│   │   │   ├── models
│   │   │   │   └── migration_step_model.dart
│   │   │   └── repositories
│   │   │       ├── migration_journey_repository_impl.dart
│   │   │       ├── onboarding_repository_adapter.dart
│   │   │       ├── onboarding_repository_impl.dart
│   │   │       └── visa_repository_impl.dart
│   │   ├── di
│   │   │   └── onboarding_module.dart
│   │   ├── domain
│   │   │   ├── entities
│   │   │   │   ├── migration_status.dart
│   │   │   │   ├── migration_step.dart
│   │   │   │   └── onboarding_step.dart
│   │   │   ├── repositories
│   │   │   │   ├── migration_journey_repository.dart
│   │   │   │   ├── onboarding_repository.dart
│   │   │   │   └── visa_repository.dart
│   │   │   └── usecases
│   │   │       ├── add_migration_step_usecase.dart
│   │   │       ├── check_onboarding_status_usecase.dart
│   │   │       ├── complete_onboarding_usecase.dart
│   │   │       ├── get_migration_steps_usecase.dart
│   │   │       ├── get_onboarding_data_usecase.dart
│   │   │       ├── remove_migration_step_usecase.dart
│   │   │       ├── save_migration_steps_usecase.dart
│   │   │       ├── save_onboarding_data_usecase.dart
│   │   │       ├── update_birth_country_usecase.dart
│   │   │       ├── update_current_status_usecase.dart
│   │   │       └── update_migration_step_usecase.dart
│   │   ├── onboarding_feature.dart
│   │   └── presentation
│   │       ├── bloc
│   │       │   ├── birth_country
---
trigger: always_on
description: Before creating a new file or folder check if already exists and if still create update this file
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
│   │   └── supabase_data_source.dart
│   ├── models
│   │   └── supabase_auth_context.dart
│   └── repositories
│       ├── auth_repository_impl.dart
│       ├── data_repository_impl.dart
│       └── supabase_auth_service.dart
├── domain
│   ├── entities
│   │   ├── auth_context.dart
│   │   └── user.dart
│   ├── repositories
│   │   ├── auth_repository.dart
│   │   ├── auth_service.dart
│   │   └── data_repository.dart
│   └── usecases
│       ├── auth_usecases.dart
│       ├── data_usecases.dart
│       └── post_usecases.dart
├── main.dart
└── presentation
    ├── blocs
    │   ├── auth
    │   │   ├── auth_bloc.dart
    │   │   ├── auth_event.dart
    │   │   └── auth_state.dart
    │   └── home
    │       ├── home_bloc.dart
    │       ├── home_event.dart
    │       └── home_state.dart
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
        └── feature
            └── feature_item.dart
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
    ├── theme
    │   ├── app_colors.dart
    │   ├── app_text_styles.dart
    │   ├── app_theme.dart
    │   └── theme_provider.dart
    └── widgets
        ├── country_selector.dart
        ├── error_display.dart
        └── secure_input_field.dart
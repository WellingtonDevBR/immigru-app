---
trigger: always_on
---

lib/
├── core
│   ├── config
│   ├── di
│   ├── services
│   └── utils
├── data
│   ├── datasources
│   │   ├── remote
│   ├── models
│   └── repositories
├── domain
│   ├── entities
│   ├── repositories
│   └── usecases
└── presentation
    ├── blocs
    │   ├── auth
    │   ├── home
    │   ├── onboarding
    │   └── profile
    ├── screens
    │   │   └── widgets
    │   │       ├── _shared
    │   │       ├── login
    │   │       └── signup
    │   │       ├── migration_journey
    │   │       └── profile
    │   ├── profile
    │   └── welcome
    ├── theme
    └── widgets
        ├── auth
        ├── community
        ├── feature
        │   └── feature_item.dart
        └── loading_indicator.dart
# Feature Template

This template provides the standard structure for creating new features in the Immigru app.

## Usage
Copy this entire directory structure when creating a new feature and rename accordingly.

## Structure
```
feature_name/
├── data/
│   ├── datasources/
│   │   └── feature_name_datasource.dart
│   ├── models/
│   │   └── feature_name_model.dart
│   └── repositories/
│       └── feature_name_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── feature_name_entity.dart
│   ├── repositories/
│   │   └── feature_name_repository.dart
│   └── usecases/
│       └── get_feature_name_usecase.dart
├── presentation/
│   ├── bloc/
│   │   ├── feature_name_bloc.dart
│   │   ├── feature_name_event.dart
│   │   └── feature_name_state.dart
│   ├── screens/
│   │   └── feature_name_screen.dart
│   └── widgets/
│       └── feature_name_widget.dart
├── di/
│   └── feature_name_module.dart
└── feature_name_feature.dart
```

## Naming Conventions
- Replace `feature_name` with your actual feature name in snake_case
- Use PascalCase for class names
- Follow Flutter naming conventions

# Onboarding Feature Reorganization

This document outlines the reorganization of the onboarding feature in the Immigru app, following clean architecture principles and best practices for Flutter development.

## Overview

The onboarding process has been reorganized to improve maintainability, testability, and scalability while maintaining compatibility with the existing implementation. The reorganization focuses on:

1. **Standardized Step Structure**: Common base classes and interfaces for all onboarding steps
2. **Reusable Components**: Extracted common UI elements into reusable widgets
3. **Improved State Management**: Better handling of step transitions and data flow
4. **Consistent Navigation**: Standardized approach for step navigation
5. **Cleaner Directory Structure**: Organized by feature and responsibility

## Migration Strategy

We've successfully completed the migration of the onboarding feature to the new architecture following a phased approach:

### Phase 1: Parallel Implementation (Completed)
- Kept original implementation in `/presentation/screens/onboarding`
- Implemented new architecture in `/features/onboarding`
- Created adapter components to bridge between implementations
- Used feature toggles to switch between implementations

### Phase 2: Gradual Migration (Completed)
- Migrated components one at a time
- Tested thoroughly after each migration
- Updated references to use new components
- Maintained backward compatibility

### Phase 3: Clean Up (Completed)
- Removed redundant files
- Updated documentation
- Finalized feature-first implementation

## Using the New Architecture

The onboarding feature now follows clean architecture principles and a feature-first approach. Here's how to use the new components:

### Adding Onboarding to Your App

```dart
// In your app.dart file
import 'package:immigru/features/onboarding/onboarding_feature.dart';

// Initialize the feature
final onboardingFeature = OnboardingFeature(serviceLocator);
await onboardingFeature.initialize();

// Provide the bloc
return MultiBlocProvider(
  providers: [
    onboardingFeature.provideBloc(),
    // Other blocs...
  ],
  child: MaterialApp(
    // Use the routes provided by the feature
    routes: {
      ...onboardingFeature.getRoutes(),
      // Other routes...
    },
    // Or use the route generator
    onGenerateRoute: (settings) {
      final route = onboardingFeature.generateRoute(settings);
      if (route != null) return route;
      // Handle other routes...
    },
  ),
);
```

### Using Individual Components

#### Birth Country Step

```dart
import 'package:immigru/features/onboarding/presentation/widgets/birth_country/birth_country_step_widget.dart';
import 'package:immigru/new_core/country/domain/entities/country.dart';

// In your widget build method
BirthCountryStepWidget(
  onCountrySelected: (Country country) {
    // Handle country selection
    print('Selected country: ${country.name} (${country.isoCode})');
  },
  selectedCountryId: 'US', // Optional: Pre-select a country
)
```

#### Current Status Step

```dart
import 'package:immigru/features/onboarding/presentation/widgets/current_status/current_status_step_widget.dart';

// In your widget build method
CurrentStatusStepWidget(
  onStatusSelected: (String statusId) {
    // Handle status selection
    print('Selected status: $statusId');
  },
  selectedStatusId: 'permanent', // Optional: Pre-select a status
)
```

#### Migration Journey Step

```dart
import 'package:immigru/features/onboarding/presentation/widgets/migration_journey/migration_journey_step_widget.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';

// In your widget build method
MigrationJourneyStepWidget(
  birthCountryId: 'US',
  birthCountryName: 'United States',
  onMigrationJourneyCompleted: (List<MigrationStep> steps) {
    // Handle migration journey completion
    print('Migration journey completed with ${steps.length} steps');
  },
)
```

### Using with OnboardingMigrationHelper

The `OnboardingMigrationHelper` provides adapter methods to bridge between the old callback-based approach and the new event-based approach:

```dart
import 'package:immigru/features/onboarding/presentation/common/onboarding_migration_helper.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

// Create a country selection handler
final countrySelectionHandler = OnboardingMigrationHelper.createCountrySelectionHandler(
  context: context,
  logger: logger,
  autoNavigate: true,
);

// Create a status selection handler
final statusSelectionHandler = OnboardingMigrationHelper.createStatusSelectionHandler(
  context: context,
  logger: logger,
  autoNavigate: true,
);

// Create a migration journey handler
final migrationJourneyHandler = OnboardingMigrationHelper.createMigrationJourneyHandler(
  context: context,
  logger: logger,
  autoNavigate: true,
);
```

## Architecture Principles

The onboarding feature has been implemented following clean architecture principles and Flutter best practices:

### 1. Clean Architecture Layers

- **Domain Layer**: Contains business entities, repository interfaces, and use cases
  - Entities like `MigrationStep` and `MigrationStatus`
  - Repository interfaces like `OnboardingRepository` and `MigrationJourneyRepository`
  - Use cases for specific business operations

- **Data Layer**: Implements repository interfaces and handles data sources
  - Repository implementations like `OnboardingRepositoryImpl`
  - Data sources for Supabase and edge functions
  - Data models with mapping to/from entities

- **Presentation Layer**: Manages UI components and state
  - BLoC pattern for state management
  - Screen and widget implementations
  - Adapters for backward compatibility

### 2. Feature-First Approach

- Self-contained feature module with its own DI container
- Clear separation between feature components
- Proper encapsulation of feature-specific logic
- Standardized interface for integration with the main app

### 3. Design Principles

- **Single Responsibility**: Each class has a single responsibility
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Interface Segregation**: Specific interfaces for specific clients
- **Open/Closed**: Open for extension, closed for modification

## Directory Structure

```
lib/features/onboarding/
├── presentation/
│   ├── common/                  # Common components and utilities
│   │   ├── base_onboarding_step.dart
│   │   ├── onboarding_migration_helper.dart
│   │   ├── onboarding_navigation_buttons.dart
│   │   ├── onboarding_progress_indicator.dart
│   │   ├── onboarding_step_factory.dart
│   │   ├── onboarding_step_header.dart
│   │   ├── onboarding_step_manager.dart
│   │   └── index.dart
│   ├── screens/
│   │   └── onboarding_screen.dart        # Main screen implementation
│   ├── steps/                    # New step implementations
│   │   ├── birth_country/
│   │   │   └── birth_country_step.dart
│   │   ├── current_status/
│   │   │   └── current_status_step.dart
│   │   ├── migration_journey/
│   │   │   └── migration_journey_step.dart
│   │   └── index.dart
│   └── widgets/                  # Adapter components for backward compatibility
│       ├── birth_country/
│       │   └── birth_country_step_widget.dart
│       ├── current_status/
│       │   └── current_status_step_widget.dart
│       └── migration_journey/
│           ├── migration_journey_step_widget.dart
│           ├── migration_step_modal.dart
│           └── migration_timeline_widget.dart
├── domain/                      # Domain layer
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/                        # Data layer
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── di/                          # Dependency injection
    └── onboarding_module.dart
```

## Key Components

### Base Classes

- **BaseOnboardingStep**: Abstract base class for all onboarding steps
- **BaseOnboardingStepState**: Base state class with common functionality for all steps

### Migration Helper

- **OnboardingMigrationHelper**: Utility class to facilitate migration from the old implementation to the new one, providing adapter methods for event handling. This component is crucial for maintaining backward compatibility while gradually migrating to the new architecture.

### Widget Adapters

- **BirthCountryStepWidget**: Adapter for the birth country step
- **CurrentStatusStepWidget**: Adapter for the current status step
- **MigrationJourneyStepWidget**: Adapter for the migration journey step

These adapters bridge between the old callback-based approach and the new event-based approach, making it easier to gradually migrate components while preserving the original design and functionality.

### Common Components

- **OnboardingStepHeader**: Reusable header component for all steps
- **OnboardingProgressIndicator**: Progress tracking component
- **OnboardingNavigationButtons**: Navigation buttons component
- **OnboardingStepManager**: Manager for step transitions and navigation
- **OnboardingStepFactory**: Factory for creating step widgets

## Integration Guide

To integrate these changes into the existing codebase:

1. **Phase 1: Use Common Components**
   - Start using the common components in the existing steps
   - Replace custom headers, progress indicators, and navigation buttons

2. **Phase 2: Migrate to New Step Structure**
   - Gradually migrate each step to use the new base classes
   - Test each step individually to ensure functionality is preserved

3. **Phase 3: Switch to New Screen Implementation**
   - Update the app to use `OnboardingScreenNew` instead of the original screen
   - Verify that all functionality works as expected

4. **Phase 4: Clean Up**
   - Remove unused code and files
   - Update imports and references

## Benefits

- **Improved Maintainability**: Standardized structure makes code easier to maintain
- **Better Testability**: Cleaner separation of concerns enables better testing
- **Easier Feature Addition**: Adding new steps is simpler with the standardized structure
- **Consistent User Experience**: Common components ensure a consistent look and feel
- **Reduced Code Duplication**: Reusable components reduce duplication

## Compatibility

The reorganization maintains compatibility with the existing implementation, allowing for a gradual migration. The new components can be used alongside the existing ones until the migration is complete.

## Logging

All components use the unified logging system from `lib/new_core/logging` to ensure consistent logging behavior throughout the application.

# Migration Journey Components

## Overview

The Migration Journey feature in the Immigru app allows users to document their migration history by adding steps that represent their movement between countries. This folder contains modular components that handle different aspects of the migration journey UI.

## Component Structure

The migration journey has been organized into several smaller, more maintainable components:

1. **MigrationJourneyStepWidget** (`migration_journey_step_widget.dart`)
   - The main container widget that orchestrates all the other components
   - Manages the overall state and layout of the migration journey step
   - Passes data and callbacks to child components

2. **MigrationJourneyHeader** (`migration_journey_header.dart`)
   - Displays the header section of the migration journey step
   - Shows title and instructions for the user

3. **MigrationStepForm** (`migration_step_form.dart`)
   - Handles the form for adding or editing migration steps
   - Includes country selection, visa selection, dates, and other migration details
   - Validates user input and submits the form data

4. **MigrationTimeline** (`migration_timeline.dart`)
   - Displays the user's migration steps in a timeline format
   - Shows each step with country, dates, and visa information
   - Provides options to edit or delete steps

5. **EnhancedDatePicker** (`enhanced_date_picker.dart`)
   - A modern, customizable date picker for selecting month and year
   - Used in the migration step form and modal for date selection

6. **Index File** (`index.dart`)
   - Exports all migration journey components for easier imports

## Usage

The MigrationJourneyStepWidget is used directly in the onboarding screen to provide the migration journey functionality:

```dart
MigrationJourneyStepWidget(
  birthCountry: 'United States',
  migrationSteps: steps,
  onAddStep: (step) {
    // Handle adding a new step
  },
  onUpdateStep: (index, step) {
    // Handle updating an existing step
  },
  onRemoveStep: (index) {
    // Handle removing a step
  },
)
```

## Architecture

The migration journey follows a modular architecture where each component has a specific responsibility:

1. The **MigrationJourneyStepWidget** is the container that manages the overall state
2. The **MigrationTimeline** displays the existing steps and handles user interactions
3. The **MigrationStepModal** provides a form interface for adding or editing steps
4. The **EnhancedDatePicker** provides a consistent date selection experience

This modular approach makes the code more maintainable and easier to test.

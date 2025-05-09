---
trigger: always_on
---

# Immigru Architecture Guidelines

## Clean Architecture Principles

The Immigru application follows Clean Architecture principles to ensure:
- Separation of concerns
- Testability
- Maintainability
- Scalability

### Layer Separation

1. **Presentation Layer**
   - Contains UI components (screens, widgets)
   - Uses BLoC pattern for state management
   - Should not contain business logic
   - Should not directly access data sources

2. **Domain Layer**
   - Contains business logic and rules
   - Independent of frameworks and UI
   - Uses use cases for business operations
   - Defines repository interfaces

3. **Data Layer**
   - Implements repository interfaces
   - Manages data sources
   - Handles data transformations
   - Abstracts external services

4. **Core/Infrastructure Layer**
   - Provides common functionality
   - Manages dependencies
   - Contains utilities and services

### Dependency Rule

Dependencies should always point inward:
- Presentation depends on Domain
- Data depends on Domain
- No layer should depend on layers outside of it

## Implementation Guidelines

### Creating New Features

1. **Define Domain First**
   - Create entities
   - Define repository interfaces
   - Create use cases

2. **Implement Data Layer**
   - Create repository implementations
   - Create data sources
   - Handle data transformations

3. **Create Presentation Layer**
   - Implement BLoC for state management
   - Create screens and widgets
   - Handle user interactions

4. **Register Dependencies**
   - Add dependencies to injection container

### UI Guidelines

1. **Modern Design**
   - Use animations for transitions
   - Implement responsive layouts
   - Follow material design principles

2. **Theme Awareness**
   - Support both light and dark modes
   - Use theme-aware colors and styles
   - Maintain consistent styling

3. **Error Handling**
   - Provide clear error messages
   - Handle edge cases gracefully
   - Implement proper loading states

### Authentication Flow

1. **Phone Authentication**
   - Use dedicated screens for each step
   - Implement proper validation
   - Provide clear user feedback
   - Handle errors gracefully

2. **Email Authentication**
   - Follow similar pattern to phone authentication
   - Implement proper validation
   - Provide clear user feedback

## Folder Structure

Follow the established folder structure:
- `/core`: Core functionality and utilities
- `/data`: Data sources and repository implementations
- `/domain`: Business logic, entities, and repository interfaces
- `/presentation`: UI components and state management

## Conclusion

Following these guidelines ensures a consistent, maintainable, and scalable application architecture. The clean architecture approach allows for easy testing, feature addition, and code maintenance.
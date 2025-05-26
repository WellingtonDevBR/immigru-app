# Immigru Developer Guide

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Development Setup](#development-setup)
3. [Feature Development](#feature-development)
4. [State Management](#state-management)
5. [API Integration](#api-integration)
6. [Testing Guidelines](#testing-guidelines)
7. [Common Patterns](#common-patterns)

## Architecture Overview

### Clean Architecture Layers

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│    (UI, BLoC, State Management)     │
├─────────────────────────────────────┤
│          Domain Layer               │
│  (Use Cases, Entities, Interfaces)  │
├─────────────────────────────────────┤
│           Data Layer                │
│  (Repositories, Data Sources, DTOs) │
└─────────────────────────────────────┘
```

### Dependency Rule
Dependencies point inward. The domain layer has no dependencies on outer layers.

## Development Setup

### Environment Configuration
1. Copy `.env.example` to `.env`
2. Add your Supabase credentials
3. Run `flutter pub get`

### IDE Setup
- Install Flutter and Dart plugins
- Enable format on save
- Configure import sorting

## Feature Development

### Creating a New Feature

1. **Create Feature Structure**
```bash
features/
└── my_feature/
    ├── data/
    │   ├── datasources/
    │   ├── models/
    │   └── repositories/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    ├── presentation/
    │   ├── bloc/
    │   ├── screens/
    │   └── widgets/
    └── di/
        └── my_feature_module.dart
```

2. **Define Domain Layer First**
- Create entities
- Define repository interfaces
- Implement use cases

3. **Implement Data Layer**
- Create DTOs/models
- Implement data sources
- Implement repositories

4. **Build Presentation Layer**
- Create BLoC events and states
- Implement BLoC logic
- Build UI components

## State Management

### BLoC Pattern
```dart
// Event
abstract class MyEvent extends Equatable {}

class LoadData extends MyEvent {
  @override
  List<Object?> get props => [];
}

// State
abstract class MyState extends Equatable {}

class MyInitial extends MyState {
  @override
  List<Object?> get props => [];
}

// BLoC
class MyBloc extends Bloc<MyEvent, MyState> {
  final MyUseCase useCase;
  
  MyBloc(this.useCase) : super(MyInitial()) {
    on<LoadData>(_onLoadData);
  }
}
```

## API Integration

### Supabase Edge Functions
```dart
// Data source implementation
class MyDataSource {
  final SupabaseClient client;
  
  Future<MyModel> fetchData() async {
    final response = await client.functions.invoke(
      'my-function',
      body: {'param': 'value'},
    );
    
    return MyModel.fromJson(response.data);
  }
}
```

## Testing Guidelines

### Unit Tests
```dart
// Test use cases
test('should get data from repository', () async {
  // Arrange
  when(mockRepository.getData())
      .thenAnswer((_) async => Right(testData));
  
  // Act
  final result = await useCase();
  
  // Assert
  expect(result, Right(testData));
});
```

### Widget Tests
```dart
testWidgets('should display data', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => mockBloc,
        child: MyWidget(),
      ),
    ),
  );
  
  expect(find.text('Expected Text'), findsOneWidget);
});
```

## Common Patterns

### Error Handling
```dart
// Use Either type for error handling
Future<Either<Failure, Success>> doSomething() async {
  try {
    final result = await apiCall();
    return Right(Success(result));
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}
```

### Dependency Injection
```dart
// Module registration
class MyModule {
  static void register(GetIt sl) {
    // Data sources
    sl.registerLazySingleton<MyDataSource>(
      () => MyDataSourceImpl(sl()),
    );
    
    // Repositories
    sl.registerLazySingleton<MyRepository>(
      () => MyRepositoryImpl(sl()),
    );
    
    // Use cases
    sl.registerLazySingleton(() => MyUseCase(sl()));
    
    // BLoCs
    sl.registerFactory(() => MyBloc(sl()));
  }
}
```

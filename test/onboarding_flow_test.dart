import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immigru/core/services/onboarding_service.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/repositories/onboarding_repository.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_state.dart';
import 'package:mockito/mockito.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}
class MockOnboardingService extends Mock implements OnboardingService {}

void main() {
  group('Onboarding Flow Tests', () {
    late OnboardingBloc onboardingBloc;
    late MockOnboardingRepository mockRepository;
    late MockOnboardingService mockService;

    setUp(() {
      mockRepository = MockOnboardingRepository();
      mockService = MockOnboardingService();
      
      // Set up mock responses
      when(mockRepository.getOnboardingData()).thenAnswer((_) async => OnboardingData.empty());
      when(mockRepository.hasCompletedOnboarding()).thenAnswer((_) async => false);
      
      onboardingBloc = OnboardingBloc(
        getOnboardingDataUseCase: (_) async => OnboardingData.empty(),
        saveOnboardingDataUseCase: (_) async {},
        completeOnboardingUseCase: () async {},
        checkOnboardingStatusUseCase: () async => false,
        logger: null,
      );
    });

    tearDown(() {
      onboardingBloc.close();
    });

    test('Initial state is correct', () {
      expect(onboardingBloc.state.currentStep, equals(OnboardingStep.birthCountry));
      expect(onboardingBloc.state.isLoading, equals(false));
      expect(onboardingBloc.state.data, equals(OnboardingData.empty()));
    });

    test('BirthCountryUpdated event updates state correctly', () {
      final testCountry = 'United States';
      
      onboardingBloc.add(BirthCountryUpdated(testCountry));
      
      expectLater(
        onboardingBloc.stream,
        emits(
          predicate<OnboardingState>(
            (state) => state.data.birthCountry == testCountry,
          ),
        ),
      );
    });

    test('NextStepRequested event advances to next step', () {
      // Set up a valid state for the current step
      final initialState = onboardingBloc.state.copyWith(
        data: OnboardingData(birthCountry: 'United States'),
      );
      
      // Use reflection to set the state (for testing purposes)
      final stateField = onboardingBloc.state;
      
      // Add the event
      onboardingBloc.add(const NextStepRequested());
      
      // Verify that the state advances to the next step
      expectLater(
        onboardingBloc.stream,
        emits(
          predicate<OnboardingState>(
            (state) => state.currentStep == OnboardingStep.currentStatus,
          ),
        ),
      );
    });

    // Add more tests for other events and state transitions
  });
}

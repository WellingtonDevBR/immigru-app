import 'package:equatable/equatable.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';

/// Base class for all onboarding events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize onboarding flow
class OnboardingInitialized extends OnboardingEvent {
  const OnboardingInitialized();
}

/// Event to update birth country
class BirthCountryUpdated extends OnboardingEvent {
  final String country;

  const BirthCountryUpdated(this.country);

  @override
  List<Object> get props => [country];
}

/// Event to update current immigration status
class CurrentStatusUpdated extends OnboardingEvent {
  final String status;

  const CurrentStatusUpdated(this.status);

  @override
  List<Object> get props => [status];
}

/// Event to add a migration step
class MigrationStepAdded extends OnboardingEvent {
  final MigrationStep step;

  const MigrationStepAdded(this.step);

  @override
  List<Object> get props => [step];
}

/// Event to update a migration step
class MigrationStepUpdated extends OnboardingEvent {
  final int index;
  final MigrationStep step;

  const MigrationStepUpdated(this.index, this.step);

  @override
  List<Object> get props => [index, step];
}

/// Event to remove a migration step
class MigrationStepRemoved extends OnboardingEvent {
  final int index;

  const MigrationStepRemoved(this.index);

  @override
  List<Object> get props => [index];
}

/// Event to update profession
class ProfessionUpdated extends OnboardingEvent {
  final String profession;

  const ProfessionUpdated(this.profession);

  @override
  List<Object> get props => [profession];
}

/// Event to navigate to the next step
class NextStepRequested extends OnboardingEvent {
  const NextStepRequested();
}

/// Event to navigate to the previous step
class PreviousStepRequested extends OnboardingEvent {
  const PreviousStepRequested();
}

/// Event to skip the current step
class StepSkipped extends OnboardingEvent {
  const StepSkipped();
}

/// Event to complete the onboarding process
class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}

/// Event to save current onboarding progress
class OnboardingSaved extends OnboardingEvent {
  const OnboardingSaved();
}

/// Event to update selected languages
class LanguagesUpdated extends OnboardingEvent {
  final List<String> languages;

  const LanguagesUpdated(this.languages);

  @override
  List<Object> get props => [languages];
}

/// Event to update selected interests
class InterestsUpdated extends OnboardingEvent {
  final List<String> interests;

  const InterestsUpdated(this.interests);

  @override
  List<Object?> get props => [interests];
}

/// Event to update the user's profile basic info
class ProfileBasicInfoUpdated extends OnboardingEvent {
  final String fullName;

  const ProfileBasicInfoUpdated({
    required this.fullName,
  });

  @override
  List<Object?> get props => [fullName];
}

/// Event to update the user's display name
class ProfileDisplayNameUpdated extends OnboardingEvent {
  final String displayName;

  const ProfileDisplayNameUpdated(this.displayName);

  @override
  List<Object?> get props => [displayName];
}

/// Event to update the user's bio
class ProfileBioUpdated extends OnboardingEvent {
  final String bio;

  const ProfileBioUpdated(this.bio);

  @override
  List<Object?> get props => [bio];
}

/// Event to update the user's location
class ProfileLocationUpdated extends OnboardingEvent {
  final String currentLocation;
  final String destinationCity;

  const ProfileLocationUpdated({
    required this.currentLocation,
    required this.destinationCity,
  });

  @override
  List<Object?> get props => [currentLocation, destinationCity];
}

/// Event to update the user's photo
class ProfilePhotoUpdated extends OnboardingEvent {
  final String photoUrl;

  const ProfilePhotoUpdated(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

/// Event to update the user's privacy settings
class ProfilePrivacyUpdated extends OnboardingEvent {
  final bool isPrivate;

  const ProfilePrivacyUpdated(this.isPrivate);

  @override
  List<Object> get props => [isPrivate];
}

/// Event to update the user's selected ImmiGroves
class ImmiGrovesUpdated extends OnboardingEvent {
  final List<String> selectedImmiGroves;

  const ImmiGrovesUpdated(this.selectedImmiGroves);

  @override
  List<Object> get props => [selectedImmiGroves];
}

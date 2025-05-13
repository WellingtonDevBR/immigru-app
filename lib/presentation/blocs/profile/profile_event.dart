import 'package:equatable/equatable.dart';

/// Base class for all profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the user's profile
class ProfileLoaded extends ProfileEvent {
  const ProfileLoaded();
}

/// Event to update the user's basic information
class BasicInfoUpdated extends ProfileEvent {
  final String fullName;
  final String? photoUrl;

  const BasicInfoUpdated({
    required this.fullName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [fullName, photoUrl];
}

/// Event to update the user's display name
class DisplayNameUpdated extends ProfileEvent {
  final String displayName;

  const DisplayNameUpdated(this.displayName);

  @override
  List<Object?> get props => [displayName];
}

/// Event to update the user's bio
class BioUpdated extends ProfileEvent {
  final String bio;

  const BioUpdated(this.bio);

  @override
  List<Object?> get props => [bio];
}

/// Event to update the user's location information
class LocationUpdated extends ProfileEvent {
  final String currentLocation;
  final String destinationCity;

  const LocationUpdated({
    required this.currentLocation,
    required this.destinationCity,
  });

  @override
  List<Object?> get props => [currentLocation, destinationCity];
}

/// Event to upload a profile photo
class ProfilePhotoUploaded extends ProfileEvent {
  final String localPath;

  const ProfilePhotoUploaded(this.localPath);

  @override
  List<Object?> get props => [localPath];
}

/// Event to update privacy settings
class PrivacySettingsUpdated extends ProfileEvent {
  final bool isPrivate;

  const PrivacySettingsUpdated(this.isPrivate);

  @override
  List<Object?> get props => [isPrivate];
}

/// Event to request moving to the next step
class NextStepRequested extends ProfileEvent {
  const NextStepRequested();
}

/// Event to request moving to the previous step
class PreviousStepRequested extends ProfileEvent {
  const PreviousStepRequested();
}

/// Event to skip the current step
class StepSkipped extends ProfileEvent {
  const StepSkipped();
}

/// Event to save the profile
class ProfileSaved extends ProfileEvent {
  const ProfileSaved();
}

/// Event to mark profile setup as completed
class ProfileSetupCompleted extends ProfileEvent {
  const ProfileSetupCompleted();
}

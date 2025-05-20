import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Entity representing an event in the home feed
class Event extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String location;
  final IconData icon;
  final String? imageUrl;
  final String? organizerId;
  final String? organizerName;
  final bool isRegistered;

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    required this.location,
    required this.icon,
    this.imageUrl,
    this.organizerId,
    this.organizerName,
    this.isRegistered = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        eventDate,
        location,
        icon,
        imageUrl,
        organizerId,
        organizerName,
        isRegistered,
      ];

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? eventDate,
    String? location,
    IconData? icon,
    String? imageUrl,
    String? organizerId,
    String? organizerName,
    bool? isRegistered,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}

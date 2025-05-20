import 'package:flutter/material.dart';
import 'package:immigru/features/home/domain/entities/event.dart';

/// Model class for Event entity
class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    super.description,
    required super.eventDate,
    required super.location,
    required super.icon,
    super.imageUrl,
    super.organizerId,
    super.organizerName,
    super.isRegistered = false,
  });

  /// Create an EventModel from JSON
  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Convert string icon name to IconData
    IconData getIconFromString(String? iconName) {
      switch (iconName?.toLowerCase()) {
        case 'video_call':
          return Icons.video_call;
        case 'location_on':
          return Icons.location_on;
        case 'celebration':
          return Icons.celebration;
        case 'gavel':
          return Icons.gavel;
        case 'school':
          return Icons.school;
        case 'work':
          return Icons.work;
        case 'people':
          return Icons.people;
        default:
          return Icons.event;
      }
    }

    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'].toString())
          : DateTime.now(),
      location: json['location']?.toString() ?? 'Online',
      icon: json['icon'] != null
          ? getIconFromString(json['icon'].toString())
          : Icons.event,
      imageUrl: json['image_url']?.toString(),
      organizerId: json['organizer_id']?.toString(),
      organizerName: json['organizer_name']?.toString(),
      isRegistered: json['is_registered'] != null
          ? json['is_registered'] as bool
          : false,
    );
  }

  /// Convert EventModel to JSON
  Map<String, dynamic> toJson() {
    // Convert IconData to string name
    String getStringFromIcon(IconData icon) {
      if (icon == Icons.video_call) return 'video_call';
      if (icon == Icons.location_on) return 'location_on';
      if (icon == Icons.celebration) return 'celebration';
      if (icon == Icons.gavel) return 'gavel';
      if (icon == Icons.school) return 'school';
      if (icon == Icons.work) return 'work';
      if (icon == Icons.people) return 'people';
      return 'event';
    }

    return {
      'id': id,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'icon': getStringFromIcon(icon),
      'image_url': imageUrl,
      'organizer_id': organizerId,
      'organizer_name': organizerName,
      'is_registered': isRegistered,
    };
  }

  /// Create a list of EventModels from a list of JSON objects
  static List<EventModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => EventModel.fromJson(json)).toList();
  }
}

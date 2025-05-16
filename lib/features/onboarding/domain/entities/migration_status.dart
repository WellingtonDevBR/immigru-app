import 'package:equatable/equatable.dart';

/// Entity representing a migration status option
class MigrationStatus extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;

  const MigrationStatus({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
  });

  @override
  List<Object?> get props => [id, title, subtitle, emoji];

  /// Get all available migration statuses
  static List<MigrationStatus> getAvailableStatuses() {
    return [
      const MigrationStatus(
        id: 'planning',
        title: 'I\'m planning to migrate',
        subtitle: 'Researching options and requirements',
        emoji: '💡',
      ),
      const MigrationStatus(
        id: 'preparing',
        title: 'I\'m getting ready',
        subtitle: 'Documents, language, research',
        emoji: '✈️',
      ),
      const MigrationStatus(
        id: 'moved',
        title: 'I\'ve already moved',
        subtitle: 'Living in my destination country',
        emoji: '🏠',
      ),
      const MigrationStatus(
        id: 'exploring',
        title: 'I\'m exploring new visa options',
        subtitle: 'Looking at different pathways',
        emoji: '🧭',
      ),
      const MigrationStatus(
        id: 'permanent',
        title: 'I\'m already a permanent resident/citizen',
        subtitle: 'Settled in my new country',
        emoji: '👤',
      ),
    ];
  }
}

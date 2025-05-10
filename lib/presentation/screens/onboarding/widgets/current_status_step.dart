import 'package:flutter/material.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the current immigration status selection step in onboarding
class CurrentStatusStep extends StatelessWidget {
  final String? selectedStatus;
  final Function(String) onStatusSelected;

  const CurrentStatusStep({
    Key? key,
    this.selectedStatus,
    required this.onStatusSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // List of possible immigration statuses
    final statuses = [
      {
        'id': 'planning',
        'title': 'I\'m planning to migrate',
        'subtitle': 'Researching options and requirements',
        'icon': Icons.lightbulb_outline,
        'emoji': '💡',
      },
      {
        'id': 'getting_ready',
        'title': 'I\'m getting ready',
        'subtitle': 'Documents, language, research',
        'icon': Icons.flight_takeoff_outlined,
        'emoji': '✈️',
      },
      {
        'id': 'moved',
        'title': 'I\'ve already moved',
        'subtitle': 'Living in my destination country',
        'icon': Icons.home_outlined,
        'emoji': '🏠',
      },
      {
        'id': 'exploring',
        'title': 'I\'m exploring new visa options',
        'subtitle': 'Looking at different pathways',
        'icon': Icons.explore_outlined,
        'emoji': '🧭',
      },
      {
        'id': 'permanent',
        'title': 'I\'m already a permanent resident/citizen',
        'subtitle': 'Settled in my new country',
        'icon': Icons.verified_user_outlined,
        'emoji': '👤',
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Where are you in this journey?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            'This helps us personalize your experience',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Status options
          Expanded(
            child: ListView.builder(
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final status = statuses[index];
                final isSelected = selectedStatus == status['id'];
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isDarkMode
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: InkWell(
                    onTap: () => onStatusSelected(status['id'] as String),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Status emoji/icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                status['emoji'] as String,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Status text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  status['title'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  status['subtitle'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Selected indicator
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

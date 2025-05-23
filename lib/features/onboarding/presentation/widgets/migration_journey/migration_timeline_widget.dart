import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for displaying a timeline of migration steps
class MigrationTimelineWidget extends StatelessWidget {
  /// List of migration steps to display
  final List<MigrationStep> steps;
  
  /// Callback when a step is edited
  final Function(MigrationStep) onEditStep;
  
  /// Callback when a step is removed
  final Function(MigrationStep) onRemoveStep;

  /// Constructor
  const MigrationTimelineWidget({
    super.key,
    required this.steps,
    required this.onEditStep,
    required this.onRemoveStep,
  });

  @override
  Widget build(BuildContext context) {
    // We don't need to sort here as the steps should already be sorted by the BLoC
    // The backend sorts steps with birth country at the bottom, current location at the top,
    // target country next, and then by date (most recent first)
    final sortedSteps = List<MigrationStep>.from(steps);
    
    return ListView.builder(
      itemCount: sortedSteps.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final step = sortedSteps[index];
        final isFirst = index == 0;
        final isLast = index == sortedSteps.length - 1;
        
        return _buildTimelineItem(
          context: context,
          step: step,
          isFirst: isFirst,
          isLast: isLast,
          index: index,
        );
      },
    );
  }
  
  /// Build a single timeline item
  Widget _buildTimelineItem({
    required BuildContext context,
    required MigrationStep step,
    required bool isFirst,
    required bool isLast,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Check if this is a birth country step
    final isBirthCountryStep = step.id.startsWith('birth_');
    
    // Format dates (only for non-birth country steps)
    final dateFormat = DateFormat('MMM yyyy');
    
    // Handle different date display scenarios
    String startDateText;
    String endDateText;
    
    if (isBirthCountryStep) {
      // Birth country doesn't need dates
      startDateText = '';
      endDateText = '';
    } else if (step.isTargetCountry) {
      // Target countries are future destinations
      startDateText = step.startDate != null 
          ? 'Planning to arrive: ${dateFormat.format(step.startDate!)}'
          : 'Future destination';
      endDateText = '';
    } else if (step.isCurrentLocation) {
      // Current location shows arrival date to present
      startDateText = step.startDate != null 
          ? dateFormat.format(step.startDate!)
          : 'Unknown';
      endDateText = 'Present';
    } else {
      // Past countries show both start and end dates
      startDateText = step.startDate != null 
          ? dateFormat.format(step.startDate!)
          : 'Unknown';
      endDateText = step.endDate != null 
          ? dateFormat.format(step.endDate!)
          : 'Unknown';
    }
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Line before the dot (not for first item)
                if (!isFirst)
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 2,
                      color: AppColors.primaryColor.withValues(alpha:0.5),
                    ),
                  ),
                
                // Dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: step.isCurrentLocation 
                        ? AppColors.primaryColor 
                        : AppColors.primaryColor.withValues(alpha:0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                
                // Line after the dot (not for last item)
                if (!isLast)
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 2,
                      color: AppColors.primaryColor.withValues(alpha:0.5),
                    ),
                  ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: step.isCurrentLocation
                      ? AppColors.primaryColor
                      : isDarkMode
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                  width: step.isCurrentLocation ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with country name and actions
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: step.isCurrentLocation
                          ? AppColors.primaryColor.withValues(alpha:0.1)
                          : isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Country name
                        Expanded(
                          child: Text(
                            step.countryName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        
                        // Status indicator (Current or Target)
                        if (step.isCurrentLocation || step.isTargetCountry)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: step.isCurrentLocation 
                                ? AppColors.primaryColor 
                                : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              step.isCurrentLocation ? 'Current' : 'Target',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        
                        // Edit button
                        IconButton(
                          onPressed: () => onEditStep(step),
                          icon: Icon(
                            Icons.edit,
                            size: 20,
                            color: isDarkMode ? Colors.white70 : Colors.grey[600],
                          ),
                          tooltip: 'Edit',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                          visualDensity: VisualDensity.compact,
                        ),
                        
                        // Remove button
                        IconButton(
                          onPressed: () => onRemoveStep(step),
                          icon: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: isDarkMode ? Colors.white70 : Colors.grey[600],
                          ),
                          tooltip: 'Remove',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  
                  // Details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // For birth country, show a special label
                        if (isBirthCountryStep)
                          Row(
                            children: [
                              Icon(
                                Icons.home_outlined,
                                size: 16,
                                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Birth Country',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDarkMode ? Colors.white70 : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        // For regular steps, show visa and date information
                        else ...[  
                          // Visa type
                          Row(
                            children: [
                              Icon(
                                Icons.article_outlined,
                                size: 16,
                                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Visa: ${step.visaTypeName}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDarkMode ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Date range
                          Row(
                            children: [
                              Icon(
                                step.isTargetCountry ? Icons.flight_takeoff : Icons.calendar_today,
                                size: 16,
                                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: step.isTargetCountry
                                  ? Text(
                                      startDateText,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: isDarkMode ? Colors.white70 : Colors.black87,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    )
                                  : Text(
                                      endDateText.isEmpty
                                        ? startDateText
                                        : '$startDateText - $endDateText',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: isDarkMode ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

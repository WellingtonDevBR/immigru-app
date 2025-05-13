import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/entities/visa.dart';
import 'package:intl/intl.dart';

/// A widget that displays the migration steps in a timeline format
class MigrationTimeline extends StatefulWidget {
  final String birthCountry;
  final List<MigrationStep> migrationSteps;
  final Function(int) onEditStep;
  final Function(int) onRemoveStep;

  const MigrationTimeline({
    super.key,
    required this.birthCountry,
    required this.migrationSteps,
    required this.onEditStep,
    required this.onRemoveStep,
  });

  @override
  State<MigrationTimeline> createState() => _MigrationTimelineState();
}

class _MigrationTimelineState extends State<MigrationTimeline>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Convert country ISO code to full country name
  String _getCountryDisplayName(String countryCode) {
    // Map of common ISO codes to full country names
    const Map<String, String> countryMap = {
      'US': 'United States',
      'CA': 'Canada',
      'GB': 'United Kingdom',
      'AU': 'Australia',
      'NZ': 'New Zealand',
      'IN': 'India',
      'CN': 'China',
      'JP': 'Japan',
      'BR': 'Brazil',
      'DE': 'Germany',
      'FR': 'France',
      'IT': 'Italy',
      'ES': 'Spain',
      'MX': 'Mexico',
      'RU': 'Russia',
    };
    
    // If the country code is in our map, return the full name
    if (countryMap.containsKey(countryCode)) {
      return countryMap[countryCode]!;
    }
    
    // If it's already a full name (longer than 2 characters), return as is
    if (countryCode.length > 2) {
      return countryCode;
    }
    
    // Otherwise, return the code as is
    return countryCode;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Text(
                  'Your Travel History Timeline',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),

              // Timeline container
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  // No timeline connectors

                  Column(
                    children: [
                      // Birth country
                      _buildBirthCountryItem(theme),

                      // Migration steps
                      if (widget.migrationSteps.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.migrationSteps.length,
                          itemBuilder: (context, index) {
                            final step = widget.migrationSteps[index];
                            return FadeTransition(
                              opacity: _animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.5, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: _animation,
                                  curve: Interval(
                                    0.2 + (index * 0.1).clamp(0.0, 0.8),
                                    0.7 + (index * 0.1).clamp(0.0, 0.3),
                                    curve: Curves.easeOut,
                                  ),
                                )),
                                child: _buildTimelineItem(
                                    context, step, index, theme, isDarkMode),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBirthCountryItem(ThemeData theme) {
    final iconColor = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(
          left: 24.0, right: 24.0, top: 4.0, bottom: 12.0),
      child: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.5, 0),
            end: Offset.zero,
          ).animate(_animation),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline icon with dot
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.home,
                    color: iconColor,
                    size: 14,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Content - modern card with glass effect
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Country name
                            Expanded(
                              child: Text(
                                // Convert country code to full name if needed
                                _getCountryDisplayName(widget.birthCountry),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            // Birth country label
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Birth Country',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    MigrationStep step,
    int index,
    ThemeData theme,
    bool isDarkMode,
  ) {
    IconData icon;
    Color iconColor;
    String dateText = '';

    if (step.arrivedDate != null) {
      // Format the date to show month and year (e.g., "May 2016")
      final monthYear = DateFormat('MMM yyyy').format(step.arrivedDate!);
      dateText = monthYear;
    }

    // Determine icon and color based on migration status and visa name
    final visaName = step.visaName.toLowerCase();

    // First check migration status for icon priority
    if (step.isCurrentLocation) {
      icon = Icons.location_on;
      iconColor = Colors.blue;
    } else if (step.isTargetDestination) {
      icon = Icons.flag;
      iconColor = Colors.purple;
    } else if (!step.wasSuccessful) {
      icon = Icons.cancel;
      iconColor = Colors.red;
    }
    // Then check visa type if no special status
    else if (visaName.contains('tourist') || visaName.contains('visitor')) {
      icon = Icons.beach_access;
      iconColor = Colors.blue;
    } else if (visaName.contains('student') || visaName.contains('study')) {
      icon = Icons.school;
      iconColor = Colors.orange;
    } else if (visaName.contains('work') || visaName.contains('skilled')) {
      icon = Icons.work;
      iconColor = Colors.green;
    } else if (visaName.contains('permanent') ||
        visaName.contains('resident')) {
      icon = Icons.home;
      iconColor = Colors.purple;
    } else if (visaName.contains('citizen')) {
      icon = Icons.flag;
      iconColor = Colors.red;
    } else {
      icon = Icons.flight_land;
      iconColor = theme.colorScheme.primary;
    }

    // Get migration reason text and icon
    final reasonText = step.migrationReason != null 
        ? _getMigrationReasonText(step.migrationReason)
        : '';
    final reasonIcon = step.migrationReason != null 
        ? _getMigrationReasonIcon(step.migrationReason)
        : null;

    return Container(
      margin: const EdgeInsets.only(
          left: 24.0, right: 24.0, top: 4.0, bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline icon with dot
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: iconColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 14,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Content - modern card with glass effect
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row with country and date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Country name
                            Expanded(
                              child: Text(
                                step.countryName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            // Date chip
                            if (dateText.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  dateText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Visa information
                        if (step.visaName.isNotEmpty) ...[  
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 14,
                                color: iconColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  step.visaName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: iconColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Status chips in a row
                        if (step.isCurrentLocation || step.isTargetDestination || !step.wasSuccessful) ...[  
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (step.isCurrentLocation)
                                _buildStatusChip(
                                  'Current Location',
                                  Icons.location_on,
                                  Colors.blue,
                                  theme,
                                ),
                              if (step.isTargetDestination)
                                _buildStatusChip(
                                  'Target Destination',
                                  Icons.flag,
                                  Colors.purple,
                                  theme,
                                ),
                              if (!step.wasSuccessful)
                                _buildStatusChip(
                                  'Unsuccessful',
                                  Icons.error_outline,
                                  Colors.red,
                                  theme,
                                ),
                            ],
                          ),
                        ],

                        // Bottom row with migration reason and action buttons
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Migration reason
                            if (reasonIcon != null && reasonText.isNotEmpty)
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      reasonIcon,
                                      size: 14,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        reasonText,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const Spacer(),
                            
                            // Action buttons in a row
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit button
                                Material(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    onTap: () => widget.onEditStep(index),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 8),
                                
                                // Delete button
                                Material(
                                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    onTap: () => widget.onRemoveStep(index),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
      String text, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMigrationReasonIcon(MigrationReason? reason) {
    switch (reason) {
      case MigrationReason.study:
        return Icons.school;
      case MigrationReason.work:
        return Icons.work;
      case MigrationReason.family:
        return Icons.family_restroom;
      case MigrationReason.refugee:
        return Icons.security;
      case MigrationReason.retirement:
        return Icons.weekend;
      case MigrationReason.investment:
        return Icons.attach_money;
      case MigrationReason.lifestyle:
        return Icons.beach_access;
      case MigrationReason.other:
        return Icons.more_horiz;
      default:
        return Icons.info_outline;
    }
  }

  String _getMigrationReasonText(MigrationReason? reason) {
    switch (reason) {
      case MigrationReason.study:
        return 'Migrated for education';
      case MigrationReason.work:
        return 'Migrated for work';
      case MigrationReason.family:
        return 'Migrated for family';
      case MigrationReason.refugee:
        return 'Migrated as a refugee';
      case MigrationReason.retirement:
        return 'Migrated for retirement';
      case MigrationReason.investment:
        return 'Migrated for investment';
      case MigrationReason.lifestyle:
        return 'Migrated for lifestyle';
      case MigrationReason.other:
        return 'Migrated for other reasons';
      default:
        return 'Migrated for other reasons';
    }
  }
}

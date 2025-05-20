import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_status.dart';
import 'package:immigru/features/onboarding/presentation/bloc/current_status/current_status_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/current_status/current_status_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/current_status/current_status_state.dart';
import 'package:immigru/features/onboarding/presentation/common/base_onboarding_step.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_migration_helper.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_step_header.dart';
import 'package:immigru/new_core/di/service_locator.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for the current immigration status selection step in onboarding
/// 
/// This step allows users to select their current immigration status.
/// It follows the new architecture pattern using the BaseOnboardingStep.
class CurrentStatusStep extends BaseOnboardingStep {
  /// The currently selected status ID
  final String? selectedStatusId;

  const CurrentStatusStep({
    super.key,
    this.selectedStatusId,
  });

  @override
  State<CurrentStatusStep> createState() => _CurrentStatusStepState();
}

class _CurrentStatusStepState extends BaseOnboardingStepState<CurrentStatusStep> {
  // Status options
  final List<Map<String, dynamic>> _statusOptions = [
    {
      'id': 'citizen',
      'title': 'Citizen',
      'subtitle': 'I am a citizen of the country where I currently live',
      'icon': Icons.verified_user,
    },
    {
      'id': 'permanent_resident',
      'title': 'Permanent Resident',
      'subtitle': 'I have permanent residency in the country where I live',
      'icon': Icons.home,
    },
    {
      'id': 'temporary_visa',
      'title': 'Temporary Visa',
      'subtitle': 'I am on a temporary visa (work, student, etc.)',
      'icon': Icons.card_membership,
    },
    {
      'id': 'asylum_seeker',
      'title': 'Asylum Seeker',
      'subtitle': 'I am seeking asylum or refugee status',
      'icon': Icons.security,
    },
    {
      'id': 'undocumented',
      'title': 'Undocumented',
      'subtitle': 'I do not have legal status in the country where I live',
      'icon': Icons.help_outline,
    },
    {
      'id': 'other',
      'title': 'Other',
      'subtitle': 'My status is not listed above',
      'icon': Icons.more_horiz,
    },
  ];

  /// Handle status selection
  void _handleStatusSelected(String statusId) {
    // Use the logger from the base class instead of LogUtil directly
    logger.i('Status selected: $statusId', tag: 'CurrentStatusStep');
    
    // Add haptic feedback
    HapticFeedback.selectionClick();
    
    // Find the matching MigrationStatus object
    final availableStatuses = MigrationStatus.getAvailableStatuses();
    final selectedStatus = availableStatuses.firstWhere(
      (status) => status.id == statusId,
      orElse: () => const MigrationStatus(
        id: 'planning',
        title: 'I\'m planning to migrate',
        subtitle: 'Researching options and requirements',
        emoji: '💡',
      ),
    );
    
    // Update the bloc with the MigrationStatus object
    final state = context.read<CurrentStatusBloc>().state;
    final selectedStatusId = state.selectedStatus;
    if (selectedStatusId?.id == statusId) return;
    
    context.read<CurrentStatusBloc>().add(CurrentStatusSelected(selectedStatus));
    
    // Also update the onboarding bloc using the migration helper
    final migrationHandler = OnboardingMigrationHelper.createStatusSelectionHandler(
      context: context,
      logger: logger,
      autoNavigate: false,
    );
    migrationHandler(statusId);
    
    // Save progress and navigate to next step after a delay
    saveOnboardingProgress();
    
    // Add a small delay to ensure the save completes before moving to next step
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        goToNextStep();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.instance<CurrentStatusBloc>()
        ..add(const CurrentStatusInitialized()),
      child: Builder(
        builder: (context) {
          return _buildContent(context);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const OnboardingStepHeader(
            title: 'What is your current status?',
            subtitle: 'Select your current immigration status to help us personalize your experience.',
            icon: Icons.assignment_ind,
          ),
          
          // Info box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your status helps us provide relevant information and resources.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Status options
          Expanded(
            child: BlocBuilder<CurrentStatusBloc, CurrentStatusState>(
              builder: (context, state) {
                return ListView(
                  children: [
                    Text(
                      'Select your current immigration status',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? Colors.grey[300]
                            : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Status option cards
                    ..._statusOptions.map((status) {
                      final isSelected = state.selectedStatus?.id == status['id'];
                      
                      return _buildStatusCard(
                        status,
                        isSelected,
                        isDarkMode,
                        theme,
                        onStatusSelected: _handleStatusSelected,
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    Map<String, dynamic> status,
    bool isSelected,
    bool isDarkMode,
    ThemeData theme, {
    required Function(String) onStatusSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin:
          const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();

            // Get the selected status ID
            final selectedStatus = status['id'] as String;
            onStatusSelected(selectedStatus);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor.withValues(alpha: 0.15)
                  : isDarkMode
                      ? AppColors.cardDark
                      : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor
                            .withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
              border: isSelected
                  ? Border.all(
                      color: AppColors.primaryColor, width: 2)
                  : Border.all(
                      color: isDarkMode
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      width: 1,
                    ),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                            .withValues(alpha: 0.2)
                        : isDarkMode
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Icon(
                    status['icon'] as IconData,
                    color: isSelected
                        ? AppColors.primaryColor
                        : isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status['title'] as String,
                        style:
                            theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
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
                
                // Selection indicator
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

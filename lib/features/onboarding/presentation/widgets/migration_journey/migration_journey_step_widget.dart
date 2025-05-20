import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/presentation/bloc/migration_journey/migration_journey_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/migration_journey/migration_journey_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/migration_journey/migration_journey_state.dart';
import 'package:immigru/features/onboarding/presentation/widgets/migration_journey/migration_step_modal.dart';
import 'package:immigru/features/onboarding/presentation/widgets/migration_journey/migration_timeline_widget.dart';
import 'package:immigru/new_core/di/service_locator.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the migration journey step in onboarding
class MigrationJourneyStepWidget extends StatelessWidget {
  /// Birth country of the user
  final String birthCountryId;
  
  /// Birth country name of the user
  final String birthCountryName;
  
  /// Callback when the migration journey is completed
  final Function(List<MigrationStep>) onMigrationJourneyCompleted;

  /// Constructor
  const MigrationJourneyStepWidget({
    super.key,
    required this.birthCountryId,
    required this.birthCountryName,
    required this.onMigrationJourneyCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.instance<MigrationJourneyBloc>()
        ..add(const MigrationJourneyInitialized()),
      child: _MigrationJourneyStepContent(
        birthCountryId: birthCountryId,
        birthCountryName: birthCountryName,
        onMigrationJourneyCompleted: onMigrationJourneyCompleted,
      ),
    );
  }
}

class _MigrationJourneyStepContent extends StatefulWidget {
  final String birthCountryId;
  final String birthCountryName;
  final Function(List<MigrationStep>) onMigrationJourneyCompleted;

  const _MigrationJourneyStepContent({
    required this.birthCountryId,
    required this.birthCountryName,
    required this.onMigrationJourneyCompleted,
  });

  @override
  State<_MigrationJourneyStepContent> createState() => _MigrationJourneyStepContentState();
}

class _MigrationJourneyStepContentState extends State<_MigrationJourneyStepContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _animationController.forward();

    // Add haptic feedback when screen appears
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
    
    // Check if we need to add birth country as first step
    Future.delayed(const Duration(milliseconds: 300), () {
      _checkAndAddBirthCountryStep();
    });
  }
  
  /// Check if birth country step exists, if not add it
  void _checkAndAddBirthCountryStep() {
    final bloc = context.read<MigrationJourneyBloc>();
    final state = bloc.state;
    
    // Check if birth country is provided
    if (widget.birthCountryId.isNotEmpty && widget.birthCountryName.isNotEmpty) {

      
      // Check if we already have a birth country step
      final hasBirthCountryStep = state.steps.any((step) => 
        step.id.startsWith('birth_') || 
        (step.countryId.toString() == widget.birthCountryId && step.order == 0));
      
      // If we don't have a birth country step, add it
      if (!hasBirthCountryStep) {

        _addBirthCountryStep();
      } else {

        
        // Check if the birth country step has the correct data
        MigrationStep? birthStep;
        try {
          birthStep = state.steps.firstWhere(
            (step) => step.id.startsWith('birth_') || 
                      (step.countryId.toString() == widget.birthCountryId && step.order == 0),
          );
        } catch (e) {
          // No birth step found
          birthStep = null;
        }
        
        if (birthStep != null && 
            (birthStep.countryName != widget.birthCountryName || 
             birthStep.countryId.toString() != widget.birthCountryId)) {

          _addBirthCountryStep(); // This will update the existing step
        }
      }
    } else {

    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BlocConsumer<MigrationJourneyBloc, MigrationJourneyState>(
      listener: (context, state) {
        // Handle errors
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          color: isDarkMode ? AppColors.darkBackground : Colors.white,
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeaderSection(context, theme, isDarkMode),
                    const SizedBox(height: 24),
                    _buildInstructions(theme, isDarkMode),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildMigrationTimeline(context, state, theme, isDarkMode),
                    ),
                    _buildAddStepButton(context, state, theme),
                    // Add more bottom padding for the footer buttons
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build the header section with illustration
  Widget _buildHeaderSection(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.map_outlined,
            color: AppColors.primaryColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "I've been to...",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tell us about your migration journey",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build instructions for the user
  Widget _buildInstructions(ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Migration Journey",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Add the countries you've lived in, including your birth country. "
          "This helps us personalize your experience.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  /// Build the migration timeline
  Widget _buildMigrationTimeline(
    BuildContext context,
    MigrationJourneyState state,
    ThemeData theme,
    bool isDarkMode,
  ) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Loading your migration journey...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    // If no steps yet, show a message
    if (state.steps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff,
              size: 64,
              color: isDarkMode ? Colors.white30 : Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No migration steps yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by adding your birth country as your first step',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _addBirthCountryStep(),
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Add Birth Country'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    // Show the timeline with existing steps
    return MigrationTimelineWidget(
      steps: state.steps,
      onEditStep: (step) => _editStep(context, step),
      onRemoveStep: (step) => _removeStep(context, step),
    );
  }

  /// Build the add step button
  Widget _buildAddStepButton(
    BuildContext context,
    MigrationJourneyState state,
    ThemeData theme,
  ) {
    // Only show if we have at least one step
    if (state.steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: state.isLoading ? null : () => _showAddStepModal(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Another Country',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Continue button removed - now using the Next button in the footer

  /// Add birth country step
  void _addBirthCountryStep() {
    // Get the bloc before adding the step
    final migrationJourneyBloc = BlocProvider.of<MigrationJourneyBloc>(context);
    
    // Create a step for the birth country with a special ID format to identify it
    // The 'birth_' prefix helps us identify this as a special step that should be preserved
    final birthCountryStep = MigrationStep(
      id: 'birth_${widget.birthCountryId}',
      countryId: int.tryParse(widget.birthCountryId) ?? 0,
      countryCode: widget.birthCountryId,
      countryName: widget.birthCountryName,
      visaTypeId: 0, // No visa for birth country
      visaTypeName: '', // No visa name for birth country
      startDate: null, // No start date for birth country
      endDate: null, // No end date for birth country
      isCurrentLocation: false, // May not be current location
      isTargetCountry: false, // Birth country is not target country
      order: 999, // Birth country should always be last
    );

    // Add the step using the captured bloc
    migrationJourneyBloc.add(MigrationStepAdded(birthCountryStep));
  }

  /// Show modal to add a new step
  void _showAddStepModal(BuildContext context) {
    // Get the bloc before showing the modal
    final migrationJourneyBloc = BlocProvider.of<MigrationJourneyBloc>(context);
    
    MigrationStepModal.show(
      context: context,
      onSave: (step) {
        // Use the bloc captured from the parent context
        migrationJourneyBloc.add(MigrationStepAdded(step));
      },
    );
  }

  /// Edit an existing step
  void _editStep(BuildContext context, MigrationStep step) {
    // Get the bloc before showing the modal
    final migrationJourneyBloc = BlocProvider.of<MigrationJourneyBloc>(context);
    
    MigrationStepModal.show(
      context: context,
      step: step,
      isEditing: true,
      onSave: (updatedStep) {
        // Use the bloc captured from the parent context
        migrationJourneyBloc.add(
              MigrationStepUpdated(step.id, updatedStep),
            );
      },
    );
  }

  /// Remove a step
  void _removeStep(BuildContext context, MigrationStep step) {
    // Get the bloc before showing the dialog
    final migrationJourneyBloc = BlocProvider.of<MigrationJourneyBloc>(context);
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Country'),
        content: Text(
          'Are you sure you want to remove ${step.countryName} from your migration journey?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Use the bloc captured from the parent context
              migrationJourneyBloc.add(MigrationStepRemoved(step.id));
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

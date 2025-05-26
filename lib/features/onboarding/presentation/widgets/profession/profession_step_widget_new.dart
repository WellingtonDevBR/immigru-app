import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/profession.dart';
import 'package:immigru/features/onboarding/presentation/bloc/profession/profession_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/profession/profession_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/profession/profession_state.dart';
import 'package:immigru/features/onboarding/presentation/common/index.dart';
import 'package:immigru/core/di/service_locator.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for the profession selection step in onboarding
class ProfessionStepWidget extends StatelessWidget {
  final Function(String) onProfessionSelected;
  final String? selectedProfession;

  const ProfessionStepWidget({
    super.key,
    required this.onProfessionSelected,
    this.selectedProfession,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.instance<ProfessionBloc>()
        ..add(const ProfessionInitialized()),
      child: _ProfessionStepContent(
        onProfessionSelected: onProfessionSelected,
        selectedProfession: selectedProfession,
      ),
    );
  }
}

class _ProfessionStepContent extends BaseOnboardingStep {
  final Function(String) onProfessionSelected;
  final String? selectedProfession;

  const _ProfessionStepContent({
    required this.onProfessionSelected,
    this.selectedProfession,
  });

  @override
  State<_ProfessionStepContent> createState() => _ProfessionStepContentState();
}

class _ProfessionStepContentState
    extends BaseOnboardingStepState<_ProfessionStepContent>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  // Track if a profession has been selected
  bool _professionSelected = false;

  @override
  void initState() {
    super.initState();

    // Initialize search controller
    _searchController = TextEditingController();

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

    // Add haptic feedback when screen appears using a separate method
    _addHapticFeedbackWithDelay();

    // Reset profession selection flag when coming back to this screen
    _professionSelected = false;
  }

  @override
  void didUpdateWidget(covariant _ProfessionStepContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset animation when coming back to this screen
    if (!_animationController.isAnimating && _animationController.value == 0) {
      // Animation is at the beginning, restart it
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Add haptic feedback with a small delay
  /// Extracted to a separate method to avoid potential BuildContext issues
  void _addHapticFeedbackWithDelay() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        HapticFeedback.lightImpact();
      }
    });
  }
  
  /// Handle profession selection with animation and callback
  /// Extracted to a separate method to avoid potential BuildContext issues
  void _handleProfessionSelection(String professionName) {
    // Small delay to ensure UI updates before navigating
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        // Animate out before navigating
        _animationController.reverse().then((_) {
          if (mounted) {
            // Notify parent about profession selection
            widget.onProfessionSelected(professionName);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BlocConsumer<ProfessionBloc, ProfessionState>(
      listener: (context, state) {
        // Handle profession selection
        if (state.selectedProfession != null &&
            state.status != ProfessionStatus.loading) {
          // Make sure the animation is running if it's at 0
          if (_animationController.value == 0 &&
              !_animationController.isAnimating) {
            _animationController.forward();
          }

          // Only set _professionSelected if it's not already true
          if (!_professionSelected) {
            setState(() {
              _professionSelected = true;
            });

            // Check if this is a manual selection (not from initialization)
            // Only trigger navigation for manual selections, not when coming back from language step
            if (state.selectionSource == SelectionSource.userAction) {
              // Handle profession selection with a separate method
              _handleProfessionSelection(state.selectedProfession!.name);
            } else {
              // Just notify parent about profession selection without navigation
              widget.onProfessionSelected(state.selectedProfession!.name);
            }
          }
        }
      },
      builder: (context, state) {
        // Set initial selection if profession was provided
        if (widget.selectedProfession != null &&
            widget.selectedProfession!.isNotEmpty &&
            state.selectedProfession == null &&
            state.status != ProfessionStatus.loading) {
          // Find matching profession in the list
          final matchingProfession = state.filteredProfessions
              .where(
                  (profession) => profession.name == widget.selectedProfession)
              .toList();

          if (matchingProfession.isNotEmpty) {
            // Store bloc reference before async gap
            final professionBloc = context.read<ProfessionBloc>();
            
            // Select the matching profession
            Future.microtask(() {
              if (mounted) {
                professionBloc.add(
                      ProfessionSelected(matchingProfession.first),
                    );
              }
            });
          }
        }

        return Scaffold(
          body: FadeTransition(
            opacity: _fadeInAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom header with gradient background
                    Container(
                      margin: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor.withValues(alpha: 0.7),
                            AppColors.primaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left side: Text
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'What is your profession?',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Select your profession or enter a custom one',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right side: Profession icon
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.work_outline,
                                  color: AppColors.primaryColor,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search professions or enter your own',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor:
                              isDarkMode ? Colors.grey[800] : Colors.grey[50],
                        ),
                        onChanged: (query) {
                          context
                              .read<ProfessionBloc>()
                              .add(SearchQueryChanged(query));
                        },
                      ),
                    ),

                    // Professions list
                    Expanded(
                      child: state.status == ProfessionStatus.loading
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                      color: AppColors.primaryColor),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading professions...',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            )
                          : _buildProfessionsList(context, state),
                    ),

                    // Custom profession button
                    if (state.showCustomInput)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: _buildCustomProfessionInput(context, state),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<ProfessionBloc>()
                                .add(const ShowCustomInputToggled(true));
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Custom Profession'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfessionsList(BuildContext context, ProfessionState state) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: state.filteredProfessions.length,
      itemBuilder: (context, index) {
        final profession = state.filteredProfessions[index];
        final isSelected = state.selectedProfession?.name == profession.name;

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(color: AppColors.primaryColor, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<ProfessionBloc>().add(
                    ProfessionSelected(profession),
                  );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      profession.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primaryColor,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomProfessionInput(
      BuildContext context, ProfessionState state) {
    final customProfessionController = TextEditingController();
    final industryController = TextEditingController();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Custom profession input
          TextField(
            controller: customProfessionController,
            decoration: InputDecoration(
              labelText: 'Your Profession',
              hintText: 'Enter your profession',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Industry input
          TextField(
            controller: industryController,
            decoration: InputDecoration(
              labelText: 'Industry (Optional)',
              hintText: 'Enter your industry',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context
                        .read<ProfessionBloc>()
                        .add(const ShowCustomInputToggled(false));
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (customProfessionController.text.trim().isNotEmpty) {
                      final customProfession = Profession(
                        name: customProfessionController.text.trim(),
                        industry: industryController.text.trim().isNotEmpty
                            ? industryController.text.trim()
                            : null,
                        isCustom: true,
                      );

                      context.read<ProfessionBloc>().add(
                            ProfessionSelected(customProfession),
                          );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

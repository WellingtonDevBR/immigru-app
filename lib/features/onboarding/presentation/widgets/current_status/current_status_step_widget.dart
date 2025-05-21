import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_status.dart';
import 'package:immigru/features/onboarding/presentation/bloc/current_status/current_status_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/current_status/current_status_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/current_status/current_status_state.dart';
import 'package:immigru/core/di/service_locator.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'dart:math' as math;

/// Widget for the current immigration status selection step in onboarding
class CurrentStatusStepWidget extends StatelessWidget {
  final Function(String) onStatusSelected;
  final String? selectedStatusId;

  const CurrentStatusStepWidget({
    super.key,
    required this.onStatusSelected,
    this.selectedStatusId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.instance<CurrentStatusBloc>()
        ..add(const CurrentStatusInitialized()),
      child: _CurrentStatusStepContent(
        onStatusSelected: onStatusSelected,
        selectedStatusId: selectedStatusId,
      ),
    );
  }
}

class _CurrentStatusStepContent extends StatefulWidget {
  final Function(String) onStatusSelected;
  final String? selectedStatusId;

  const _CurrentStatusStepContent({
    required this.onStatusSelected,
    this.selectedStatusId,
  });

  @override
  State<_CurrentStatusStepContent> createState() =>
      _CurrentStatusStepContentState();
}

class _CurrentStatusStepContentState extends State<_CurrentStatusStepContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  // Track if a status has been selected
  bool _statusSelected = false;

  // Track if we're returning to this screen (to prevent auto-navigation)
  bool _isReturningToScreen = false;

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

    // Check if we're returning to this screen with a previously selected status
    _isReturningToScreen =
        widget.selectedStatusId != null && widget.selectedStatusId!.isNotEmpty;

    // Start animations
    _animationController.forward();

    // Add haptic feedback when screen appears
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
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

    return BlocConsumer<CurrentStatusBloc, CurrentStatusState>(
      listener: (context, state) {
        // Handle status selection - only trigger navigation for new selections, not when returning
        if (state.selectedStatus != null && !state.isLoading) {
          // Check if this is a new selection (different from previous)
          final isNewSelection =
              widget.selectedStatusId != state.selectedStatus!.id;

          // If this is a new selection OR we're manually selecting (not the initial load)
          if (isNewSelection || !_isReturningToScreen) {
            // Only set _statusSelected if it's not already true
            if (!_statusSelected) {
              setState(() {
                _statusSelected = true;
              });

              // Provide haptic feedback
              HapticFeedback.mediumImpact();

              // Animate out before navigating
              _animationController.reverse().then((_) {
                // Notify parent about status selection
                widget.onStatusSelected(state.selectedStatus!.id);
              });
            }
          } else if (_isReturningToScreen && !_statusSelected) {
            // Just mark as selected without navigation when returning
            setState(() {
              _statusSelected = true;
            });
            final logger = UnifiedLogger();
            logger.d(
                'Returning to current status screen with existing selection - not auto-navigating',
                tag: 'CurrentStatusStep');
          }
        }
      },
      builder: (context, state) {
        // Set initial selection if ID was provided, but don't auto-navigate
        if (widget.selectedStatusId != null &&
            widget.selectedStatusId!.isNotEmpty &&
            state.selectedStatus == null &&
            !state.isLoading &&
            state.availableStatuses.isNotEmpty) {
          final matchingStatus = state.availableStatuses
              .where((status) => status.id == widget.selectedStatusId)
              .toList();

          if (matchingStatus.isNotEmpty) {
            // Use a post-frame callback to avoid triggering during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Just select the status without triggering navigation
              context.read<CurrentStatusBloc>().add(
                    CurrentStatusSelected(matchingStatus.first),
                  );

              // Mark that we're returning to this screen with a selection
              // This prevents automatic navigation in the listener
              if (mounted) {
                setState(() {
                  _isReturningToScreen = true;
                });
              }
            });
          }
        }

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

                    // Progress indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: LinearProgressIndicator(
                        value: 0.2, // Second step
                        backgroundColor:
                            isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Animated header with brand colors and illustration
                    Container(
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
                                  'What\'s your status?',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Select your current immigration stage',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right side: Map illustration
                          Expanded(
                            flex: 2,
                            child: Transform.rotate(
                              angle: -math.pi /
                                  20, // Slight tilt for visual interest
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.map_outlined,
                                    color: AppColors.primaryColor,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Status options list
                    Expanded(
                      child: _buildStatusList(state, isDarkMode, theme),
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

  Widget _buildStatusList(
      CurrentStatusState state, bool isDarkMode, ThemeData theme) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Loading options...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CurrentStatusBloc>().add(
                      const CurrentStatusInitialized(),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.availableStatuses.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final status = state.availableStatuses[index];
        final isSelected = state.selectedStatus?.id == status.id;

        return _buildStatusCard(status, isSelected, isDarkMode, theme);
      },
    );
  }

  Widget _buildStatusCard(MigrationStatus status, bool isSelected,
      bool isDarkMode, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryColor.withValues(alpha: isDarkMode ? 0.3 : 0.1)
            : isDarkMode
                ? Colors.grey[850]
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryColor
              : isDarkMode
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Allow reselection of the same status when returning to screen
            if (!isSelected || _isReturningToScreen) {
              // Reset the returning flag to allow navigation on manual selection
              if (_isReturningToScreen) {
                setState(() {
                  _isReturningToScreen = false;
                  _statusSelected = false; // Reset to allow navigation
                });

                final logger = UnifiedLogger();
                logger.d('Manual selection detected - enabling navigation',
                    tag: 'CurrentStatusStep');
              }

              // Select the status
              context.read<CurrentStatusBloc>().add(
                    CurrentStatusSelected(status),
                  );

              // Provide haptic feedback
              HapticFeedback.selectionClick();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Emoji container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor.withValues(alpha: 0.2)
                        : isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      status.emoji,
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
                        status.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primaryColor
                              : isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection indicator
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

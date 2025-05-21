import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/immi_grove.dart';
import 'package:immigru/features/onboarding/presentation/bloc/immi_grove/immi_grove_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/immi_grove/immi_grove_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/immi_grove/immi_grove_state.dart';
import 'package:immigru/core/di/service_locator.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/core/logging/logger_interface.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_gradient_header.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_info_box.dart';
import 'package:immigru/features/onboarding/presentation/common/themed_card.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_theme.dart';

/// Widget for the ImmiGroves recommendation step in the onboarding process
class ImmiGroveStep extends StatefulWidget {
  /// Function called when ImmiGroves are selected
  final Function(List<String>) onImmiGrovesSelected;

  /// List of initially selected ImmiGrove IDs
  final List<String> selectedImmiGroveIds;

  /// Logger for tracking events
  final LoggerInterface logger;

  /// Creates a new ImmiGroveStep
  const ImmiGroveStep({
    super.key,
    required this.onImmiGrovesSelected,
    this.selectedImmiGroveIds = const [],
    required this.logger,
  });

  @override
  State<ImmiGroveStep> createState() => _ImmiGroveStepState();
}

class _ImmiGroveStepState extends State<ImmiGroveStep> {
  final Set<String> _selectedImmiGroveIds = {};
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _selectedImmiGroveIds.addAll(widget.selectedImmiGroveIds);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.instance<ImmiGroveBloc>()
        ..add(const LoadRecommendedImmiGroves())
        ..add(const LoadJoinedImmiGroves()),
      child: BlocConsumer<ImmiGroveBloc, ImmiGroveState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == ImmiGroveStatus.saved,
        listener: (context, state) {
          if (state.status == ImmiGroveStatus.saved && !_hasNavigated) {
            _hasNavigated = true;
            widget.logger.i(
                'ImmiGroveStep: Saving selected ImmiGroves: ${state.selectedImmiGroveIds}');
            widget.onImmiGrovesSelected(state.selectedImmiGroveIds.toList());
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            widget.logger.i('ImmiGroveStep: Loading ImmiGroves');
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null &&
              state.recommendedImmiGroves.isEmpty) {
            widget.logger.e(
                'ImmiGroveStep: Error loading ImmiGroves: ${state.errorMessage}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Failed to load ImmiGroves'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      widget.logger.i('ImmiGroveStep: Retrying ImmiGrove load');
                      context
                          .read<ImmiGroveBloc>()
                          .add(const RefreshImmiGroves());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return _buildImmiGrovesList(context, state);
        },
      ),
    );
  }

  Widget _buildImmiGrovesList(BuildContext context, ImmiGroveState state) {
    // Combine recommended and joined ImmiGroves, removing duplicates
    final allImmiGroves =
        {...state.recommendedImmiGroves, ...state.joinedImmiGroves}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Header with gradient background
        const OnboardingGradientHeader(
          title: "Join ImmiGroves",
          subtitle: "Connect with communities that match your interests",
          icon: Icons.people_alt,
        ),

        const SizedBox(height: 16),

        // Info box explaining ImmiGroves
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: OnboardingInfoBox(
            icon: Icons.info_outline,
            title: 'What are ImmiGroves?',
            message:
                'ImmiGroves are communities of people with similar immigration journeys and interests. Joining ImmiGroves helps you connect with others who share your experiences.',
          ),
        ),

        const SizedBox(height: 16),

        // ImmiGroves list
        Expanded(
          child: allImmiGroves.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: allImmiGroves.length,
                  itemBuilder: (context, index) {
                    final immiGrove = allImmiGroves[index];
                    final isSelected =
                        state.selectedImmiGroveIds.contains(immiGrove.id);

                    return _ImmiGroveCard(
                      immiGrove: immiGrove,
                      isSelected: isSelected,
                      onToggle: () {
                        if (isSelected) {
                          context
                              .read<ImmiGroveBloc>()
                              .add(LeaveImmiGrove(immiGrove.id));
                        } else {
                          context
                              .read<ImmiGroveBloc>()
                              .add(JoinImmiGrove(immiGrove.id));
                        }
                      },
                    );
                  },
                ),
        ),

        // We don't need a Finish button here since we already have one at the bottom
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 64,
            color: AppColors.icon(theme.brightness),
          ),
          const SizedBox(height: 16),
          Text(
            'No ImmiGroves available',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find any communities for you',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary(theme.brightness),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for individual ImmiGrove cards
class _ImmiGroveCard extends StatelessWidget {
  final ImmiGrove immiGrove;
  final bool isSelected;
  final VoidCallback onToggle;

  const _ImmiGroveCard({
    required this.immiGrove,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ThemedCard(
      isSelected: isSelected,
      onTap: onToggle,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // ImmiGrove icon or placeholder
            Container(
              width: 48,
              height: 48,
              decoration: OnboardingTheme.iconContainerDecoration(
                isSelected: isSelected,
                brightness: theme.brightness,
              ),
              child: Center(
                child: Icon(
                  Icons.people,
                  color: OnboardingTheme.iconColor(
                    isSelected: isSelected,
                    brightness: theme.brightness,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // ImmiGrove details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    immiGrove.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryColor : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    immiGrove.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary(theme.brightness),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: AppColors.textSecondary(theme.brightness),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${immiGrove.memberCount} ${immiGrove.memberCount == 1 ? 'member' : 'members'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(theme.brightness),
                        ),
                      ),
                      if (immiGrove.categories.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.tag,
                          size: 16,
                          color: AppColors.textSecondary(theme.brightness),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            immiGrove.categories.join(', '),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary(theme.brightness),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Join/Leave button
            ElevatedButton(
              onPressed: onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? AppColors.surfaceLight
                    : AppColors.primaryColor,
                foregroundColor: isSelected ? Colors.black87 : Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(80, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isSelected ? 'Leave' : 'Join',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/immi_grove.dart';
import 'package:immigru/features/onboarding/presentation/bloc/immi_grove/immi_grove_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/immi_grove/immi_grove_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/immi_grove/immi_grove_state.dart';
import 'package:immigru/core/di/service_locator.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/core/logging/logger_interface.dart';

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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Combine recommended and joined ImmiGroves, removing duplicates
    final allImmiGroves =
        {...state.recommendedImmiGroves, ...state.joinedImmiGroves}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Header with gradient background
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_alt,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Join ImmiGroves",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Connect with communities that match your interests",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.group_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No ImmiGroves available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'We couldn\'t find any communities for you',
            style: TextStyle(color: Colors.grey),
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
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: AppColors.primaryColor, width: 2)
            : BorderSide(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                width: 1,
              ),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // ImmiGrove icon or placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: immiGrove.iconUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          immiGrove.iconUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.people, size: 30);
                          },
                        ),
                      )
                    : const Icon(Icons.people, size: 30),
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
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
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
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${immiGrove.memberCount} ${immiGrove.memberCount == 1 ? 'member' : 'members'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                          ),
                        ),
                        if (immiGrove.categories.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.tag,
                            size: 16,
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              immiGrove.categories.join(', '),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
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
                      ? Colors.grey.shade200
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected ? Colors.black87 : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/di/injection_container.dart' as di;
import 'package:immigru/domain/entities/interest.dart';
import 'package:immigru/domain/usecases/interest_usecases.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the interest selection step in onboarding
class InterestStep extends StatefulWidget {
  final List<String> selectedInterests;
  final Function(List<String>) onInterestsSelected;

  const InterestStep({
    super.key,
    required this.selectedInterests,
    required this.onInterestsSelected,
  });

  @override
  State<InterestStep> createState() => _InterestStepState();
}

class _InterestStepState extends State<InterestStep>
    with AutomaticKeepAliveClientMixin {
  // Interest data
  final GetInterestsUseCase _interestsUseCase = di.sl<GetInterestsUseCase>();
  final SaveUserInterestsUseCase _saveUserInterestsUseCase =
      di.sl<SaveUserInterestsUseCase>();
  final GetUserInterestsUseCase _getUserInterestsUseCase =
      di.sl<GetUserInterestsUseCase>();
  List<Interest> _interests = [];
  List<String> _selectedInterests = [];
  Map<String, int> _interestIdMap = {}; // Maps interest names to IDs
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSaving = false;

  // Store a reference to the onboarding bloc
  late OnboardingBloc _onboardingBloc;

  // Keep this widget alive to prevent rebuilds
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely capture the bloc reference when dependencies change
    _onboardingBloc = BlocProvider.of<OnboardingBloc>(context);
  }

  @override
  void initState() {
    super.initState();
    _selectedInterests = List.from(widget.selectedInterests);
    _fetchInterests();
  }

  /// Fetch interests from the repository and user's selected interests
  Future<void> _fetchInterests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First fetch all available interests
      final interests = await _interestsUseCase();

      // Build a map of interest names to IDs for easier lookup
      final Map<String, int> idMap = {};
      for (var interest in interests) {
        idMap[interest.name] = interest.id;
      }

      setState(() {
        _interests = interests;
        _interestIdMap = idMap;
        _isLoading = false;
      });

      // Now fetch user's selected interests
      await _fetchUserInterests();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load interests. Please try again.';
        _isLoading = false;
      });
    }
  }

  /// Fetch user's previously selected interests
  Future<void> _fetchUserInterests() async {
    try {
      final userInterests = await _getUserInterestsUseCase();

      if (userInterests.isNotEmpty) {
        // Extract names of user interests
        final userInterestNames =
            userInterests.map((interest) => interest.name).toList();

        // Log for debugging
        // If we have user interests and no interests were passed from the parent widget,
        // use the user interests as the selected interests
        if (widget.selectedInterests.isEmpty) {
          setState(() {
            _selectedInterests = userInterestNames;
          });

          // Notify parent of the change
          widget.onInterestsSelected(_selectedInterests);

          // Update the onboarding bloc with the selected interests using the stored reference
          if (mounted) {
            _onboardingBloc.add(
              InterestsUpdated(_selectedInterests),
            );
          }
        }
      }
    } finally {
      // Ensure the widget is still mounted
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Toggle selection of an interest
  void _toggleInterestSelection(String interestName) {
    // Check if we're removing or adding
    final bool isRemoving = _selectedInterests.contains(interestName);

    // Only proceed if we're removing OR we haven't reached the limit
    if (isRemoving || _selectedInterests.length < 4) {
      // Create a new list to avoid direct state mutation
      final newSelectedInterests = List<String>.from(_selectedInterests);

      if (isRemoving) {
        newSelectedInterests.remove(interestName);
      } else {
        newSelectedInterests.add(interestName);
      }

      setState(() {
        // Update state
        _selectedInterests = newSelectedInterests;
      });

      // Notify parent of the change
      widget.onInterestsSelected(_selectedInterests);

      // Update the onboarding bloc with the selected interests
      if (context.mounted) {
        // Convert selected names to interest IDs
        final List<int> selectedIds = _selectedInterests
            .where((name) => _interestIdMap.containsKey(name))
            .map((name) => _interestIdMap[name]!)
            .toList();

        // Dispatch the interests updated event to the bloc
        BlocProvider.of<OnboardingBloc>(context).add(
          InterestsUpdated(_selectedInterests),
        );

        // Save interests to the database if at least 2 are selected
        if (selectedIds.length >= 2 && !_isSaving) {
          _saveInterests(selectedIds);
        }
      }
    }
  }

  /// Save selected interests to the database
  Future<void> _saveInterests(List<int> interestIds) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Save interests to the database
      final success = await _saveUserInterestsUseCase(interestIds);

      if (success) {
        // If successful, trigger save in the onboarding bloc using the stored reference
        if (mounted) {
          _onboardingBloc.add(const OnboardingSaved());
        }
      }
    } catch (e) {
      // Handle error silently, user can still continue onboarding
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? AppColors.darkBackground : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header with brand colors
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
                    Icons.interests,
                    color: AppColors.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "I'm interested in...",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Select 2-4 topics you're most interested in",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Selected interests count
            Text(
              "${_selectedInterests.length}/4 topics selected",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),

            const SizedBox(height: 16),

            // Interest grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchInterests,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                3, // Increased to 3 items per row for smaller widgets
                            childAspectRatio:
                                2.2, // Wider than tall for a more compact look
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _interests.length,
                          itemBuilder: (context, index) {
                            final interest = _interests[index];
                            return _InterestItem(
                              interest: interest,
                              isSelected:
                                  _selectedInterests.contains(interest.name),
                              isDarkMode: isDarkMode,
                              onToggle: (interestName) {
                                _toggleInterestSelection(interestName);
                              },
                              maxSelections: 4,
                              currentSelections: _selectedInterests.length,
                            );
                          },
                        ),
            ),

            // We've removed the large Next button as requested
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// A stateful widget for individual interest items to prevent rebuilding the entire grid
class _InterestItem extends StatefulWidget {
  final Interest interest;
  final bool isSelected;
  final bool isDarkMode;
  final Function(String) onToggle;
  final int maxSelections;
  final int currentSelections;

  const _InterestItem({
    required this.interest,
    required this.isSelected,
    required this.isDarkMode,
    required this.onToggle,
    required this.maxSelections,
    required this.currentSelections,
  });

  @override
  State<_InterestItem> createState() => _InterestItemState();
}

class _InterestItemState extends State<_InterestItem>
    with AutomaticKeepAliveClientMixin {
  // Use local state to avoid rebuilding the parent
  late bool _isSelected;

  // Keep this widget alive to prevent rebuilds
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(_InterestItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update local state if the selected state changed from parent
    if (oldWidget.isSelected != widget.isSelected) {
      setState(() {
        _isSelected = widget.isSelected;
      });
    }
  }

  void _handleToggle() {
    // If already selected, always allow deselection
    if (_isSelected) {
      setState(() {
        _isSelected = false;
      });
      // Notify parent after visual update is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onToggle(widget.interest.name);
      });
    }
    // If not selected, only allow selection if under the limit
    else if (widget.currentSelections < widget.maxSelections) {
      setState(() {
        _isSelected = true;
      });
      // Notify parent after visual update is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onToggle(widget.interest.name);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _isSelected
            ? AppColors.primaryColor.withValues(alpha: 0.1)
            : widget.isDarkMode
                ? AppColors.cardDark
                : AppColors.cardLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isSelected
              ? AppColors.primaryColor
              : widget.isDarkMode
                  ? AppColors.borderDark
                  : AppColors.borderLight,
          width: _isSelected ? 1.5 : 0.5,
        ),
        boxShadow: _isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.15),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Center(
              child: Text(
                widget.interest.name,
                style: TextStyle(
                  fontWeight: _isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                  color: _isSelected
                      ? AppColors.primaryColor
                      : widget.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

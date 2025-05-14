import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/di/injection_container.dart';
import 'package:immigru/domain/entities/immi_grove.dart';
import 'package:immigru/presentation/blocs/immi_grove/immi_grove_bloc.dart';
import 'package:immigru/presentation/blocs/immi_grove/immi_grove_event.dart';
import 'package:immigru/presentation/blocs/immi_grove/immi_grove_state.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_state.dart';
import 'package:immigru/presentation/theme/app_colors.dart';
import 'package:immigru/presentation/widgets/loading_indicator.dart';

/// Widget for individual ImmiGrove cards
class ImmiGroveCard extends StatelessWidget {
  final ImmiGrove immiGrove;
  final bool isSelected;
  final VoidCallback onToggle;
  
  const ImmiGroveCard({
    super.key,
    required this.immiGrove,
    required this.isSelected,
    required this.onToggle,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected 
                ? AppColors.primaryColor 
                : isDarkMode 
                    ? AppColors.borderDark 
                    : AppColors.borderLight,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (!isDarkMode)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8.0,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ImmiGrove name
              Text(
                immiGrove.name,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              
              // Member count
              Text(
                '${immiGrove.memberCount ?? 0} members',
                style: TextStyle(
                  fontSize: 12.0,
                  color: isDarkMode 
                      ? AppColors.textSecondaryDark 
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8.0),
              
              // Description
              Text(
                immiGrove.description ?? 'Join this community',
                style: TextStyle(
                  fontSize: 14.0,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              
              // Type tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  immiGrove.type ?? 'Community',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              
              // Join button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onToggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected 
                        ? AppColors.primaryColor 
                        : isDarkMode 
                            ? AppColors.surfaceDark 
                            : Colors.white,
                    foregroundColor: isSelected 
                        ? Colors.white 
                        : AppColors.primaryColor,
                    side: BorderSide(
                      color: AppColors.primaryColor,
                      width: 1.0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    isSelected ? 'Joined' : 'Join Community',
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
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
}

/// Widget for the ImmiGroves recommendation step in the onboarding process
class ImmiGrovesStep extends StatefulWidget {
  const ImmiGrovesStep({super.key});

  @override
  State<ImmiGrovesStep> createState() => _ImmiGrovesStepState();
}

class _ImmiGrovesStepState extends State<ImmiGrovesStep> {
  late ImmiGroveBloc _immiGroveBloc;
  Set<String> _selectedImmiGroves = {};

  @override
  void initState() {
    super.initState();
    // Get the ImmiGroveBloc from the dependency injection container
    _immiGroveBloc = sl<ImmiGroveBloc>();
    
    // Initialize selected ImmiGroves from the onboarding bloc state
    final state = context.read<OnboardingBloc>().state;
    _selectedImmiGroves = Set<String>.from(state.data.selectedImmiGroves);
    
    // Load both recommended and joined ImmiGroves to properly handle the case
    // where the user has already joined all available communities
    _immiGroveBloc.add(const RefreshImmiGroves());
  }

  @override
  void dispose() {
    // We don't close the bloc here since it's managed by the dependency injection container
    super.dispose();
  }

  void _toggleImmiGrove(String id) {
    setState(() {
      if (_selectedImmiGroves.contains(id)) {
        _selectedImmiGroves.remove(id);
        _immiGroveBloc.add(LeaveImmiGrove(id));
      } else {
        _selectedImmiGroves.add(id);
        _immiGroveBloc.add(JoinImmiGrove(id));
        
        // Refresh the recommended list after joining
        Future.delayed(const Duration(milliseconds: 500), () {
          _immiGroveBloc.add(const RefreshImmiGroves());
        });
      }
      
      // Dispatch event to update the onboarding bloc
      context.read<OnboardingBloc>().add(
        ImmiGrovesUpdated(_selectedImmiGroves.toList()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _immiGroveBloc,
      child: BlocBuilder<ImmiGroveBloc, ImmiGroveState>(
        builder: (context, immiGroveState) {
          return BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, onboardingState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Recommended ImmiGroves',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      
                      // Description
                      Text(
                        'Join communities of people with similar interests and immigration journeys.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      
                      // Loading state
                      if (immiGroveState.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: LoadingIndicator(),
                          ),
                        )
                      // Error state
                      else if (immiGroveState.status == ImmiGroveStatus.error)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  'Failed to load recommended communities',
                                  style: Theme.of(context).textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Please check your connection and try again',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24.0),
                                ElevatedButton(
                                  onPressed: () {
                                    _immiGroveBloc.add(const RefreshImmiGroves());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          ),
                        )
                      // Loaded state with empty results
                      else if (immiGroveState.recommendedImmiGroves.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'You\'ve joined all available communities!',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You can manage your communities or discover more from your profile page after onboarding.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      // Loaded state with results
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: immiGroveState.recommendedImmiGroves.length,
                          itemBuilder: (context, index) {
                            final immiGrove = immiGroveState.recommendedImmiGroves[index];
                            final isSelected = _selectedImmiGroves.contains(immiGrove.id);
                            
                            return ImmiGroveCard(
                              immiGrove: immiGrove,
                              isSelected: isSelected,
                              onToggle: () => _toggleImmiGrove(immiGrove.id),
                            );
                          },
                        ),
                      
                      const SizedBox(height: 24.0),
                      
                      // Info text
                      Text(
                        'You can always join or leave ImmiGroves later from your profile.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white60
                              : Colors.black45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

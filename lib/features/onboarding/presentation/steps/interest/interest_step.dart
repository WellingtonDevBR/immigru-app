import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/di/injection_container.dart';
import 'package:immigru/features/onboarding/presentation/bloc/interest/interest_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/interest/interest_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/interest/interest_state.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for the interest selection step in onboarding
class InterestStep extends StatefulWidget {
  /// Creates a new instance of [InterestStep]
  final List<int> selectedInterests;
  final Function(List<int>) onInterestsSelected;
  
  const InterestStep({
    super.key,
    required this.selectedInterests,
    required this.onInterestsSelected,
  });

  String get title => 'What are you interested in?';

  String get subtitle => 'Select interests to personalize your experience';

  @override
  State<InterestStep> createState() => _InterestStepState();
}

class _InterestStepState extends State<InterestStep> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    
    // Load interests when the widget is initialized
    Future.microtask(() {
      context.read<InterestBloc>().add(const InterestsLoaded());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InterestBloc>()..add(const InterestsLoaded()),
      child: BlocConsumer<InterestBloc, InterestState>(
        listenWhen: (previous, current) => 
            previous.saveSuccess != current.saveSuccess && current.saveSuccess,
        listener: (context, state) {
          if (state.saveSuccess && !_hasNavigated) {
            _hasNavigated = true;
            widget.onInterestsSelected(state.selectedInterestIds);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage ?? 'An error occurred',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<InterestBloc>().add(const InterestsLoaded());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return _buildInterestList(context, state);
        },
      ),
    );
  }

  Widget _buildInterestList(BuildContext context, InterestState state) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        // Header with gradient background
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
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
                  Icons.interests,
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
                      "What are you interested in?",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Select interests to personalize your experience",
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
        
        // Selected interests count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Selected: ${state.selectedInterestIds.length}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search interests...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
            onChanged: (query) {
              context.read<InterestBloc>().add(InterestSearchUpdated(query));
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Interest grid
        Expanded(
          child: state.filteredInterests.isEmpty
              ? _buildEmptyState(context)
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: state.filteredInterests.length,
                  itemBuilder: (context, index) {
                    final interest = state.filteredInterests[index];
                    final isSelected = state.selectedInterestIds.contains(interest.id);
                    
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isSelected
                            ? BorderSide(color: AppColors.primaryColor, width: 2)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        onTap: () {
                          context.read<InterestBloc>().add(
                                InterestToggled(interest.id),
                              );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  interest.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? AppColors.primaryColor : null,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        
        // Continue button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: state.selectedInterestIds.isNotEmpty
                ? () {
                    context.read<InterestBloc>().add(
                          InterestsSaved(state.selectedInterestIds),
                        );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No interests found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search term',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

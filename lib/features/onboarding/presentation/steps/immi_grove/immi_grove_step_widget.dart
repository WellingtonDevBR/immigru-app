import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/di/injection_container.dart';
import 'package:immigru/features/onboarding/domain/entities/immi_grove.dart';
import 'package:immigru/features/onboarding/presentation/bloc/immi_grove/immi_grove_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/immi_grove/immi_grove_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/immi_grove/immi_grove_state.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for the ImmiGroves recommendation step in the onboarding process
class ImmiGroveStepWidget extends StatefulWidget {
  /// Function called when ImmiGroves are selected
  final Function(List<String>) onImmiGrovesSelected;
  
  /// List of initially selected ImmiGrove IDs
  final List<String> selectedImmiGroveIds;

  /// Creates a new ImmiGroveStepWidget
  const ImmiGroveStepWidget({
    super.key,
    required this.onImmiGrovesSelected,
    this.selectedImmiGroveIds = const [],
  });

  @override
  State<ImmiGroveStepWidget> createState() => _ImmiGroveStepWidgetState();
}

class _ImmiGroveStepWidgetState extends State<ImmiGroveStepWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    
    // Load ImmiGroves when the widget is initialized
    Future.microtask(() {
      context.read<ImmiGroveBloc>().add(const LoadRecommendedImmiGroves());
      context.read<ImmiGroveBloc>().add(const LoadJoinedImmiGroves());
    });
    
    // Set initial selected ImmiGroves if available
    if (widget.selectedImmiGroveIds.isNotEmpty) {
      Future.microtask(() {
        final selectedIds = Set<String>.from(widget.selectedImmiGroveIds);
        context.read<ImmiGroveBloc>().add(
          ImmiGrovesPreselected(selectedIds),
        );
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ImmiGroveBloc>()
        ..add(const LoadRecommendedImmiGroves())
        ..add(const LoadJoinedImmiGroves()),
      child: BlocConsumer<ImmiGroveBloc, ImmiGroveState>(
        listenWhen: (previous, current) => 
            previous.selectedImmiGroveIds != current.selectedImmiGroveIds,
        listener: (context, state) {
          // Update the onboarding state when ImmiGroves are selected
          if (state.selectedImmiGroveIds.isNotEmpty) {
            widget.onImmiGrovesSelected(state.selectedImmiGroveIds.toList());
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.recommendedImmiGroves.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && state.recommendedImmiGroves.isEmpty) {
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
                      context.read<ImmiGroveBloc>().add(const RefreshImmiGroves());
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
    final allImmiGroves = {...state.recommendedImmiGroves, ...state.joinedImmiGroves}
        .toList();
    
    // Filter ImmiGroves based on search query
    final filteredImmiGroves = _searchQuery.isEmpty
        ? allImmiGroves
        : allImmiGroves
            .where((grove) => 
                grove.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                grove.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                grove.categories.any((category) => 
                    category.toLowerCase().contains(_searchQuery.toLowerCase())))
            .toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        
        // Modern header with gradient background and animation
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                Color(0xFF2E7D32), // Darker shade for depth
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Animated icon container
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [Colors.white, Colors.white.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: const Icon(
                    Icons.people_alt_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Text content with improved typography
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Join ImmiGroves",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Connect with communities that match your interests",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Selected count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Selected: ${state.selectedImmiGroveIds.length}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Modern search field with animation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ImmiGroves...',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade500,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // ImmiGroves list
        Expanded(
          child: filteredImmiGroves.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredImmiGroves.length,
                  itemBuilder: (context, index) {
                    final immiGrove = filteredImmiGroves[index];
                    final isSelected = state.selectedImmiGroveIds.contains(immiGrove.id);
                    
                    return _ImmiGroveCard(
                      immiGrove: immiGrove,
                      isSelected: isSelected,
                      onToggle: () {
                        if (isSelected) {
                          context.read<ImmiGroveBloc>().add(LeaveImmiGrove(immiGrove.id));
                        } else {
                          context.read<ImmiGroveBloc>().add(JoinImmiGrove(immiGrove.id));
                        }
                      },
                    );
                  },
                ),
        ),
        
        // Bottom padding to ensure content is visible
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated container with icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _searchQuery.isEmpty ? Icons.people_alt_rounded : Icons.search_off_rounded,
              size: 60,
              color: AppColors.primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty ? 'No ImmiGroves Available' : 'No Results Found',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _searchQuery.isEmpty
                  ? 'We couldn\'t find any communities for you at the moment.'
                  : 'Try adjusting your search terms to find communities.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Search'),
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
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected 
              ? AppColors.primaryColor 
              : isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // ImmiGrove icon with modern design
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: immiGrove.iconUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        immiGrove.iconUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.people_alt_rounded,
                            size: 28,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.people_alt_rounded,
                      size: 28,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
            ),
            const SizedBox(width: 16),
            
            // ImmiGrove details with improved typography
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
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${immiGrove.memberCount} ${immiGrove.memberCount == 1 ? 'member' : 'members'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Join/Leave button with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: isSelected 
                    ? Colors.transparent
                    : AppColors.primaryColor,
                border: Border.all(
                  color: isSelected 
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: Text(
                        isSelected ? 'Joined' : 'Join',
                        style: TextStyle(
                          color: isSelected 
                              ? AppColors.primaryColor
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

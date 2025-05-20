import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/profession/profession_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/profession/profession_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/profession/profession_state.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the profession selection step in onboarding
class ProfessionStep extends StatefulWidget {
  /// Creates a new instance of [ProfessionStep]
  final Function() onStepCompleted;
  
  const ProfessionStep({
    super.key,
    required this.onStepCompleted,
  });

  String get title => 'What is your profession?';

  String get subtitle => 'Select your profession or enter a custom one';

  @override
  State<ProfessionStep> createState() => _ProfessionStepState();
}

class _ProfessionStepState extends State<ProfessionStep> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _customProfessionController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfessionBloc>().add(const ProfessionInitialized());
    
    _searchController.addListener(() {
      context.read<ProfessionBloc>().add(SearchQueryChanged(_searchController.text));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _customProfessionController.dispose();
    _industryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfessionBloc, ProfessionState>(
      listenWhen: (previous, current) => 
          previous.status != current.status && 
          current.status == ProfessionStatus.saved,
      listener: (context, state) {
        if (state.status == ProfessionStatus.saved) {
          widget.onStepCompleted();
        }
      },
      builder: (context, state) {
        if (state.status == ProfessionStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ProfessionStatus.error) {
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
                    context.read<ProfessionBloc>().add(const ProfessionInitialized());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.showCustomInput) {
          return _buildCustomProfessionInput(context, state);
        }

        return _buildProfessionList(context, state);
      },
    );
  }

  Widget _buildProfessionList(BuildContext context, ProfessionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search professions or enter your own',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
          ),
        ),
        
        // Profession list
        Expanded(
          child: state.filteredProfessions.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                ),
        ),
        
        // Add custom profession button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<ProfessionBloc>().add(const ShowCustomInputToggled(true));
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Custom Profession'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomProfessionInput(BuildContext context, ProfessionState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter your profession',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customProfessionController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Profession',
              hintText: 'e.g., Software Developer, Chef, etc.',
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
          TextField(
            controller: _industryController,
            decoration: InputDecoration(
              labelText: 'Industry (Optional)',
              hintText: 'e.g., Technology, Hospitality, etc.',
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<ProfessionBloc>().add(const ShowCustomInputToggled(false));
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
                    if (_customProfessionController.text.trim().isNotEmpty) {
                      context.read<ProfessionBloc>().add(
                            CustomProfessionEntered(
                              _customProfessionController.text.trim(),
                              industry: _industryController.text.trim().isNotEmpty
                                  ? _industryController.text.trim()
                                  : null,
                            ),
                          );
                    }
                  },
                  style: ElevatedButton.styleFrom(
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
            _searchController.text.isEmpty
                ? 'No professions available'
                : 'No results found for "${_searchController.text}"',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<ProfessionBloc>().add(const ShowCustomInputToggled(true));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add Custom Profession'),
          ),
        ],
      ),
    );
  }
}

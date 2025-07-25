import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/domain/entities/profession.dart';
import 'package:immigru/features/onboarding/presentation/bloc/profession/profession_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/profession/profession_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/profession/profession_state.dart';
import 'package:immigru/core/di/service_locator.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/theme/app_theme.dart';

/// Widget for the profession selection step in onboarding
// class ProfessionStepWidget extends StatelessWidget {
//   final Function(String) onProfessionSelected;
//   final String? selectedProfession;

//   const ProfessionStepWidget({
//     super.key,
//     required this.onProfessionSelected,
//     this.selectedProfession,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => ServiceLocator.instance<ProfessionBloc>()
//         ..add(const ProfessionInitialized()),
//       child: _ProfessionStepContent(
//         onProfessionSelected: onProfessionSelected,
//         selectedProfession: selectedProfession,
//       ),
//     );
//   }
// }

// class _ProfessionStepContent extends StatefulWidget {
//   final Function(String) onProfessionSelected;
//   final String? selectedProfession;

//   const _ProfessionStepContent({
//     required this.onProfessionSelected,
//     this.selectedProfession,
//   });

//   @override
//   State<_ProfessionStepContent> createState() => _ProfessionStepContentState();
// }

// class _ProfessionStepContentState extends State<_ProfessionStepContent> with SingleTickerProviderStateMixin {
//   late TextEditingController _searchController;
//   late AnimationController _animationController;
//   late Animation<double> _fadeInAnimation;
//   late Animation<Offset> _slideAnimation;
  
//   // Track if a profession has been selected
//   bool _professionSelected = false;
  
//   @override
//   void initState() {
//     super.initState();
//     _searchController = TextEditingController();
    
//     // Setup animations
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
    
//     _fadeInAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeIn,
//     );
    
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOut,
//     ));
    
//     // Start animations
//     _animationController.forward();
    
//     // Add haptic feedback when screen appears
//     Future.delayed(const Duration(milliseconds: 100), () {
//       HapticFeedback.lightImpact();
//     });
    
//     // Listen for search changes
//     _searchController.addListener(() {
//       context.read<ProfessionBloc>().add(SearchQueryChanged(_searchController.text));
//     });
//   }
  
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<ProfessionBloc, ProfessionState>(
//       listenWhen: (previous, current) => 
//           previous.selectedProfession != current.selectedProfession && 
//           current.selectedProfession != null,
//       listener: (context, state) {
//         if (state.selectedProfession != null && !_professionSelected) {
//           setState(() {
//             _professionSelected = true;
//           });
          
//           // Call the callback with the selected profession name
//           widget.onProfessionSelected(state.selectedProfession!.name);
//         }
//       },
//       builder: (context, state) {
//         if (state.status == ProfessionStatus.loading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (state.status == ProfessionStatus.error) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   state.errorMessage ?? 'An error occurred',
//                   style: const TextStyle(color: Colors.red),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     context.read<ProfessionBloc>().add(const ProfessionInitialized());
//                   },
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           );
//         }

//         return _buildContent(context, state);
//       },
//     );
//   }

//   Widget _buildContent(BuildContext context, ProfessionState state) {
//     return FadeTransition(
//       opacity: _fadeInAnimation,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Text(
//                 'What is your profession?',
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Select your profession or enter a custom one',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Colors.black54,
//                 ),
//               ),
//               const SizedBox(height: 24),
              
//               // Search field
//               TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search professions or enter your own',
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16.0,
//                     vertical: 12.0,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Profession list
//               Expanded(
//                 child: state.showCustomInput
//                     ? _buildCustomProfessionInput(context, state)
//                     : _buildProfessionList(context, state),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildProfessionList(BuildContext context, ProfessionState state) {
//     if (state.filteredProfessions.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.search_off, size: 48, color: Colors.grey),
//             const SizedBox(height: 16),
//             Text(
//               'No professions found',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 color: Colors.grey[700],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Try a different search term or add a custom profession',
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () {
//                 context.read<ProfessionBloc>().add(const ShowCustomInputToggled(true));
//               },
//               icon: const Icon(Icons.add),
//               label: const Text('Add Custom Profession'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryColor,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             padding: EdgeInsets.zero,
//             itemCount: state.filteredProfessions.length,
//             itemBuilder: (context, index) {
//               final profession = state.filteredProfessions[index];
//               final isSelected = state.selectedProfession?.name == profession.name;
              
//               return Card(
//                 elevation: 1,
//                 margin: const EdgeInsets.only(bottom: 8.0),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   side: isSelected
//                       ? BorderSide(color: AppColors.primaryColor, width: 2)
//                       : BorderSide.none,
//                 ),
//                 child: InkWell(
//                   onTap: () {
//                     HapticFeedback.selectionClick();
//                     context.read<ProfessionBloc>().add(
//                           ProfessionSelected(profession),
//                         );
//                   },
//                   borderRadius: BorderRadius.circular(12),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             profession.name,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                         if (isSelected)
//                           Icon(
//                             Icons.check_circle,
//                             color: AppColors.primaryColor,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         const SizedBox(height: 16),
//         ElevatedButton.icon(
//           onPressed: () {
//             context.read<ProfessionBloc>().add(const ShowCustomInputToggled(true));
//           },
//           icon: const Icon(Icons.add),
//           label: const Text('Add Custom Profession'),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primaryColor,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCustomProfessionInput(BuildContext context, ProfessionState state) {
//     final TextEditingController customProfessionController = TextEditingController();
//     final TextEditingController industryController = TextEditingController();
    
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Custom profession input
//           TextField(
//             controller: customProfessionController,
//             decoration: InputDecoration(
//               labelText: 'Your Profession',
//               hintText: 'Enter your profession',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16.0,
//                 vertical: 12.0,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
          
//           // Industry input
//           TextField(
//             controller: industryController,
//             decoration: InputDecoration(
//               labelText: 'Industry (Optional)',
//               hintText: 'Enter your industry',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16.0,
//                 vertical: 12.0,
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
          
//           // Action buttons
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () {
//                     context.read<ProfessionBloc>().add(const ShowCustomInputToggled(false));
//                   },
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text('Cancel'),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (customProfessionController.text.trim().isNotEmpty) {
//                       final customProfession = Profession(
//                         name: customProfessionController.text.trim(),
//                         industry: industryController.text.trim().isNotEmpty
//                             ? industryController.text.trim()
//                             : null,
//                         isCustom: true,
//                       );
                      
//                       context.read<ProfessionBloc>().add(
//                             ProfessionSelected(customProfession),
//                           );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryColor,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text('Save'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Widget for the profession selection step in onboarding
// class ProfessionStepWidget extends StatelessWidget {
//   final Function(String) onProfessionSelected;
//   final String? selectedProfession;

//   const ProfessionStepWidget({
//     super.key,
//     required this.onProfessionSelected,
//     this.selectedProfession,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => ServiceLocator.instance<ProfessionBloc>()
//         ..add(const ProfessionInitialized()),
//       child: _ProfessionStepContent(
//         onProfessionSelected: onProfessionSelected,
//         selectedProfession: selectedProfession,
//       ),
//     );
//   }
// }

class _ProfessionStepContent extends StatefulWidget {
  final Function(String) onProfessionSelected;
  final String? selectedProfession;

  const _ProfessionStepContent({
    required this.onProfessionSelected,
    this.selectedProfession,
  });

  @override
  State<_ProfessionStepContent> createState() => _ProfessionStepContentState();
}

class _ProfessionStepContentState extends State<_ProfessionStepContent> with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Track if a profession has been selected
  bool _professionSelected = false;
  
  @override
  void initState() {
    super.initState();
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
    
    // Add haptic feedback when screen appears
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
    
    // Listen for search changes
    _searchController.addListener(() {
      context.read<ProfessionBloc>().add(SearchQueryChanged(_searchController.text));
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfessionBloc, ProfessionState>(
      listenWhen: (previous, current) => 
          previous.selectedProfession != current.selectedProfession && 
          current.selectedProfession != null,
      listener: (context, state) {
        if (state.selectedProfession != null && !_professionSelected) {
          setState(() {
            _professionSelected = true;
          });
          
          // Call the callback with the selected profession name
          widget.onProfessionSelected(state.selectedProfession!.name);
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

        return _buildContent(context, state);
      },
    );
  }

  Widget _buildContent(BuildContext context, ProfessionState state) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'What is your profession?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your profession or enter a custom one',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              
              // Search field
              TextField(
                controller: _searchController,
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
              const SizedBox(height: 16),
              
              // Profession list
              Expanded(
                child: state.showCustomInput
                    ? _buildCustomProfessionInput(context, state)
                    : _buildProfessionList(context, state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionList(BuildContext context, ProfessionState state) {
    if (state.filteredProfessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No professions found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term or add a custom profession',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProfessionBloc>().add(const ShowCustomInputToggled(true));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Custom Profession'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
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
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            context.read<ProfessionBloc>().add(const ShowCustomInputToggled(true));
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
          ),
        ),
      ],
    );
  }

  Widget _buildCustomProfessionInput(BuildContext context, ProfessionState state) {
    final TextEditingController customProfessionController = TextEditingController();
    final TextEditingController industryController = TextEditingController();
    
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
                    if (customProfessionController.text.trim().isNotEmpty) {
                      final customProfession = Profession(
                        name: customProfessionController.text.trim(),
                        industry: industryController.text.trim().isNotEmpty
                            ? industryController.text.trim()
                            : null,
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

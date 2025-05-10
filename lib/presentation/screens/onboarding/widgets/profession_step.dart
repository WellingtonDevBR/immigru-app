import 'package:flutter/material.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the profession selection step in onboarding
class ProfessionStep extends StatefulWidget {
  final String? selectedProfession;
  final Function(String) onProfessionSelected;

  const ProfessionStep({
    Key? key,
    this.selectedProfession,
    required this.onProfessionSelected,
  }) : super(key: key);

  @override
  State<ProfessionStep> createState() => _ProfessionStepState();
}

class _ProfessionStepState extends State<ProfessionStep> {
  // List of common professions (this would typically come from an API or larger dataset)
  final List<String> _commonProfessions = [
    'Healthcare Professional',
    'Engineer',
    'IT Professional',
    'Teacher/Educator',
    'Business/Management',
    'Finance Professional',
    'Skilled Trade',
    'Student',
    'Researcher/Academic',
    'Legal Professional',
    'Arts/Creative',
    'Hospitality',
    'Agriculture',
    'Retired',
    'Other',
  ];

  // Controller for the search/custom field
  late TextEditingController _professionController;
  
  // Flag to show custom profession input
  bool _showCustomInput = false;

  @override
  void initState() {
    super.initState();
    _professionController = TextEditingController();
    
    // Set initial text if a profession is already selected
    if (widget.selectedProfession != null && widget.selectedProfession!.isNotEmpty) {
      _professionController.text = widget.selectedProfession!;
      
      // Check if it's a custom profession
      if (!_commonProfessions.contains(widget.selectedProfession)) {
        _showCustomInput = true;
      }
    }
  }

  @override
  void dispose() {
    _professionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Your Profession',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            'This helps us tailor resources to your needs',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Custom profession input
          if (_showCustomInput) ...[
            Text(
              'Enter your profession',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _professionController,
                onChanged: widget.onProfessionSelected,
                decoration: InputDecoration(
                  hintText: 'Enter your profession',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showCustomInput = false;
                        _professionController.clear();
                      });
                    },
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Center(
              child: Text(
                'or select from common professions below',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
          
          // Profession list
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _commonProfessions.length,
              itemBuilder: (context, index) {
                final profession = _commonProfessions[index];
                final isSelected = widget.selectedProfession == profession;
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : isDarkMode
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isDarkMode
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: InkWell(
                    onTap: () {
                      widget.onProfessionSelected(profession);
                      
                      // If "Other" is selected, show custom input
                      if (profession == 'Other') {
                        setState(() {
                          _showCustomInput = true;
                          _professionController.clear();
                        });
                      } else {
                        setState(() {
                          _showCustomInput = false;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          profession,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Add custom profession button
          if (!_showCustomInput)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showCustomInput = true;
                    });
                  },
                  icon: Icon(
                    Icons.add,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    'Add custom profession',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

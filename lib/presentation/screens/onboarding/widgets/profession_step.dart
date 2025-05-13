import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the profession selection step in onboarding
class ProfessionStep extends StatefulWidget {
  final String? selectedProfession;
  final Function(String) onProfessionSelected;

  const ProfessionStep({
    super.key,
    this.selectedProfession,
    required this.onProfessionSelected,
  });

  @override
  State<ProfessionStep> createState() => _ProfessionStepState();
}

class _ProfessionStepState extends State<ProfessionStep> {
  // Flag to show custom profession input screen
  bool _showCustomInputScreen = false;
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
  
  // Flag to show custom profession input (deprecated, using _showCustomInputScreen instead)
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
        _showCustomInputScreen = true;
      }
    }
  }

  @override
  void dispose() {
    _professionController.dispose();
    super.dispose();
  }

  // Build example chip widget for the custom profession screen
  Widget _buildExampleChip(String text, ThemeData theme, bool isDarkMode) {
    return InkWell(
      onTap: () {
        setState(() {
          _professionController.text = text;
          widget.onProfessionSelected(text);
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Sanitize input to prevent XSS and other security issues
  String sanitizeInput(String input) {
    // Remove any potentially dangerous HTML/script tags
    final sanitized = input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'javascript:'), '')
        .trim();
    
    // Limit length to prevent buffer overflow attacks
    return sanitized.length > 100 ? sanitized.substring(0, 100) : sanitized;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // If showing custom input screen
    if (_showCustomInputScreen) {
      return Container(
        color: isDarkMode ? AppColors.darkBackground : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _showCustomInputScreen = false;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Back to professions',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Header with brand colors
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryColor.withValues(alpha:0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: AppColors.primaryColor,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tell us your profession...",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Enter your specific profession or role",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Custom profession input with modern design
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha:0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha:0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _professionController,
                  onChanged: (value) {
                    // Sanitize input before passing it to the callback
                    final sanitized = sanitizeInput(value);
                    widget.onProfessionSelected(sanitized);
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your profession',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    prefixIcon: Icon(
                      Icons.work_outline,
                      color: AppColors.primaryColor.withValues(alpha:0.7),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  maxLength: 100, // Limit input length for security
                  textInputAction: TextInputAction.done,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Helpful examples
              Text(
                'Examples:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildExampleChip('Software Developer', theme, isDarkMode),
                  _buildExampleChip('Graphic Designer', theme, isDarkMode),
                  _buildExampleChip('Marketing Specialist', theme, isDarkMode),
                  _buildExampleChip('Freelance Writer', theme, isDarkMode),
                  _buildExampleChip('Data Analyst', theme, isDarkMode),
                ],
              ),
              
              const Spacer(),
              
              // Continue button
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _professionController.text.trim().isNotEmpty
                        ? () {
                            // One final sanitization before submitting
                            final sanitized = sanitizeInput(_professionController.text);
                            widget.onProfessionSelected(sanitized);
                            
                            // Trigger save to ensure the profession is saved to UserProfile
                            if (context.mounted) {
                              // Add OnboardingSaved event to the bloc
                              BlocProvider.of<OnboardingBloc>(context).add(const OnboardingSaved());
                              
                              // Automatically proceed to next step
                              BlocProvider.of<OnboardingBloc>(context).add(const NextStepRequested());
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
    
    // Main profession selection screen
    return Container(
      color: isDarkMode ? AppColors.darkBackground : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Animated header with brand colors - matching steps 1 and 2
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryColor.withValues(alpha:0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    color: AppColors.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "I'm currently a...",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This helps us tailor resources to your needs',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
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
                                color: theme.colorScheme.primary.withValues(alpha:0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: InkWell(
                      onTap: () {
                        widget.onProfessionSelected(profession);
                        
                        // If "Other" is selected, show custom input screen
                        if (profession == 'Other') {
                          setState(() {
                            _showCustomInputScreen = true;
                            _professionController.clear();
                          });
                        } else {
                          // For any other profession, automatically save and proceed to next step
                          // This will trigger the bloc to save the profession to UserProfile
                          widget.onProfessionSelected(profession);
                          
                          // Trigger save after a short delay to ensure the bloc state is updated
                          Future.delayed(const Duration(milliseconds: 300), () {
                            // Add OnboardingSaved event to the bloc
                            if (context.mounted) {
                              BlocProvider.of<OnboardingBloc>(context).add(const OnboardingSaved());
                              
                              // Automatically proceed to next step
                              BlocProvider.of<OnboardingBloc>(context).add(const NextStepRequested());
                            }
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
            
            // No custom profession button
          ],
        ),
      ),
    );
  }
}

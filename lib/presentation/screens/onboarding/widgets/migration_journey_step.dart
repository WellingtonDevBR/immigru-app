import 'package:flutter/material.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the migration journey step in onboarding
class MigrationJourneyStep extends StatefulWidget {
  final String birthCountry;
  final List<MigrationStep> migrationSteps;
  final Function(MigrationStep) onAddStep;
  final Function(int, MigrationStep) onUpdateStep;
  final Function(int) onRemoveStep;

  const MigrationJourneyStep({
    Key? key,
    required this.birthCountry,
    required this.migrationSteps,
    required this.onAddStep,
    required this.onUpdateStep,
    required this.onRemoveStep,
  }) : super(key: key);

  @override
  State<MigrationJourneyStep> createState() => _MigrationJourneyStepState();
}

class _MigrationJourneyStepState extends State<MigrationJourneyStep> {
  // Controllers for the add step form
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Flag to show/hide the add step form
  bool _showAddForm = false;

  @override
  void dispose() {
    _countryController.dispose();
    _yearController.dispose();
    _statusController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Reset the form fields
  void _resetForm() {
    _countryController.clear();
    _yearController.clear();
    _statusController.clear();
    _notesController.clear();
    setState(() {
      _showAddForm = false;
    });
  }

  // Add a new migration step
  void _addStep() {
    if (_countryController.text.isEmpty || _yearController.text.isEmpty) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Country and year are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create new step
    final newStep = MigrationStep(
      country: _countryController.text,
      year: int.tryParse(_yearController.text) ?? DateTime.now().year,
      status: _statusController.text,
      notes: _notesController.text,
    );

    // Add step
    widget.onAddStep(newStep);

    // Reset form
    _resetForm();
  }

  // Show edit dialog for a step
  void _showEditDialog(int index, MigrationStep step) {
    final TextEditingController editCountryController = TextEditingController(text: step.country);
    final TextEditingController editYearController = TextEditingController(text: step.year.toString());
    final TextEditingController editStatusController = TextEditingController(text: step.status);
    final TextEditingController editNotesController = TextEditingController(text: step.notes);

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        
        return AlertDialog(
          title: const Text('Edit Migration Step'),
          backgroundColor: isDarkMode ? AppColors.cardDark : AppColors.cardLight,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Country field
                TextField(
                  controller: editCountryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    hintText: 'Enter country name',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Year field
                TextField(
                  controller: editYearController,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    hintText: 'Enter year (e.g., 2020)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                
                // Status field
                TextField(
                  controller: editStatusController,
                  decoration: const InputDecoration(
                    labelText: 'Visa/Status',
                    hintText: 'Enter visa type or status',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Notes field
                TextField(
                  controller: editNotesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Enter any additional notes',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Update step
                final updatedStep = MigrationStep(
                  country: editCountryController.text,
                  year: int.tryParse(editYearController.text) ?? DateTime.now().year,
                  status: editStatusController.text,
                  notes: editNotesController.text,
                );
                
                widget.onUpdateStep(index, updatedStep);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
            'Your Migration Journey',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            'Add the countries you\'ve lived in (optional)',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Timeline
          Expanded(
            child: widget.migrationSteps.isEmpty && !_showAddForm
                ? _buildEmptyState(context)
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Birth country (starting point)
                        _buildTimelineItem(
                          context,
                          country: widget.birthCountry,
                          year: 'Birth',
                          isFirst: true,
                          isLast: widget.migrationSteps.isEmpty && !_showAddForm,
                          isDarkMode: isDarkMode,
                        ),
                        
                        // Migration steps
                        ...List.generate(
                          widget.migrationSteps.length,
                          (index) {
                            final step = widget.migrationSteps[index];
                            return _buildTimelineItem(
                              context,
                              country: step.country,
                              year: step.year.toString(),
                              status: step.status,
                              notes: step.notes,
                              isFirst: false,
                              isLast: index == widget.migrationSteps.length - 1 && !_showAddForm,
                              isDarkMode: isDarkMode,
                              onEdit: () => _showEditDialog(index, step),
                              onDelete: () => widget.onRemoveStep(index),
                            );
                          },
                        ),
                        
                        // Add step form
                        if (_showAddForm)
                          _buildAddStepForm(context, isDarkMode),
                      ],
                    ),
                  ),
          ),
          
          // Add step button
          if (!_showAddForm)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showAddForm = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add Migration Step'),
              ),
            ),
        ],
      ),
    );
  }

  // Build empty state widget
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 64,
            color: isDarkMode ? Colors.white54 : Colors.black38,
          ),
          const SizedBox(height: 16),
          Text(
            'No migration steps added yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first step',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white54 : Colors.black45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build timeline item widget
  Widget _buildTimelineItem(
    BuildContext context, {
    required String country,
    required String year,
    String? status,
    String? notes,
    required bool isFirst,
    required bool isLast,
    required bool isDarkMode,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    final theme = Theme.of(context);
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top line (hidden for first item)
                Container(
                  width: 2,
                  height: 30,
                  color: isFirst
                      ? Colors.transparent
                      : theme.colorScheme.primary,
                ),
                
                // Dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? Colors.black : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
                
                // Bottom line (hidden for last item)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country and year
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            country,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            year,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Status
                    if (status != null && status.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                    
                    // Notes
                    if (notes != null && notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        notes,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                    
                    // Edit/Delete buttons (not for birth country)
                    if (onEdit != null && onDelete != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Edit button
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              size: 18,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                            onPressed: onEdit,
                            tooltip: 'Edit',
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: const EdgeInsets.all(8),
                          ),
                          
                          // Delete button
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              size: 18,
                              color: theme.colorScheme.error,
                            ),
                            onPressed: onDelete,
                            tooltip: 'Delete',
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: const EdgeInsets.all(8),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build add step form widget
  Widget _buildAddStepForm(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top line
                Container(
                  width: 2,
                  height: 30,
                  color: theme.colorScheme.primary,
                ),
                
                // Dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? Colors.black : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Form
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Add Migration Step',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Country field
                    TextField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        hintText: 'Enter country name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Year field
                    TextField(
                      controller: _yearController,
                      decoration: InputDecoration(
                        labelText: 'Year',
                        hintText: 'Enter year (e.g., ${DateTime.now().year})',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    
                    // Status field
                    TextField(
                      controller: _statusController,
                      decoration: const InputDecoration(
                        labelText: 'Visa/Status',
                        hintText: 'Enter visa type or status',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes field
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Enter any additional notes',
                      ),
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Cancel button
                        TextButton(
                          onPressed: _resetForm,
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Add button
                        ElevatedButton(
                          onPressed: _addStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Add Step'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

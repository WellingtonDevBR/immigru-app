import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the display name step in profile setup
class DisplayNameStep extends StatefulWidget {
  final String displayName;

  const DisplayNameStep({
    super.key,
    required this.displayName,
  });

  @override
  State<DisplayNameStep> createState() => _DisplayNameStepState();
}

class _DisplayNameStepState extends State<DisplayNameStep> {
  late final TextEditingController _displayNameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.displayName);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? AppColors.darkBackground : Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            onChanged: _updateDisplayName,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Text(
                    'Choose a Display Name',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                
                // Display name explanation
                Text(
                  'Your display name is how other users will see you in the community. Choose a name that represents you while maintaining your privacy.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 32.0),
                
                // Display name field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Display name',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Tooltip(
                          message: 'This name will be visible to all users in the community',
                          child: Icon(
                            Icons.info_outline,
                            size: 16.0,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _displayNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a display name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your display name',
                        helperText: 'How other users will see you publicly',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => _updateDisplayName(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                
                // Visibility note
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        color: isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                        size: 20.0,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          'This name will be visible to all users in the community.',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Update display name in the bloc
  void _updateDisplayName() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(
            DisplayNameUpdated(_displayNameController.text),
          );
    }
  }
}

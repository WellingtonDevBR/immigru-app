import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_event.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_state.dart';

/// Widget for selecting post categories using choice chips
class CategoryPickerWidget extends StatelessWidget {
  /// List of available categories
  final List<String> categories;

  /// Constructor
  const CategoryPickerWidget({
    super.key,
    this.categories = const ['General', 'Question', 'Event', 'News', 'Other'],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return BlocBuilder<PostCreationBloc, PostCreationState>(
      buildWhen: (previous, current) => previous.category != current.category,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final isSelected = state.category == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          context.read<PostCreationBloc>().add(CategorySelected(category));
                          HapticFeedback.lightImpact();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Modern dialog for creating a new post
class CreatePostDialog extends StatefulWidget {
  final User user;
  final Function(String, String, String?) onPost;

  const CreatePostDialog({
    super.key,
    required this.user,
    required this.onPost,
  });

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = 'General';
  String? _imageUrl;
  bool _isSubmitting = false;

  // Available post categories
  final List<String> _categories = [
    'General',
    'Immigration News',
    'Legal Advice',
    'Community',
    'Question',
    'Experience',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// Submit the post
  void _submitPost() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    widget.onPost(
      _contentController.text.trim(),
      _selectedCategory,
      _imageUrl,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Create Post',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: widget.user.photoUrl != null
                      ? NetworkImage(widget.user.photoUrl!)
                      : null,
                  child: widget.user.photoUrl == null
                      ? Text(
                          widget.user.displayName?[0] ?? 'U',
                          style: const TextStyle(fontSize: 18),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.displayName ?? 'User',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    
                    // Category dropdown
                    DropdownButton<String>(
                      value: _selectedCategory,
                      isDense: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, size: 16),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Content text field
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDarkMode
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            
            // Image preview (if selected)
            if (_imageUrl != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _imageUrl = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha:0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            
            // Action buttons
            Row(
              children: [
                // Add image button
                IconButton(
                  icon: Icon(
                    Icons.image,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    // TODO: Implement image selection
                    setState(() {
                      _imageUrl = 'https://picsum.photos/500/300';
                    });
                  },
                  tooltip: 'Add Image',
                ),
                const Spacer(),
                
                // Post button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

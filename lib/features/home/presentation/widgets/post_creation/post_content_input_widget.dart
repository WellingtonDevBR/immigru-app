import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_event.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_state.dart';

/// Widget for inputting post content with character counter
class PostContentInputWidget extends StatefulWidget {
  /// User avatar URL
  final String? userAvatarUrl;

  /// User display name
  final String? userDisplayName;

  /// Maximum character count
  final int maxCharCount;

  /// Constructor
  const PostContentInputWidget({
    super.key,
    this.userAvatarUrl,
    this.userDisplayName,
    this.maxCharCount = 500,
  });

  @override
  State<PostContentInputWidget> createState() => _PostContentInputWidgetState();
}

class _PostContentInputWidgetState extends State<PostContentInputWidget> {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasAutoFocused = false;

  @override
  void initState() {
    super.initState();

    // Listen for text changes and update the bloc
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _contentController.removeListener(_onTextChanged);
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Update the bloc when text changes
  void _onTextChanged() {
    context.read<PostCreationBloc>().add(
          PostContentChanged(_contentController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Auto-focus only once when the widget is first built
    if (!_hasAutoFocused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(_focusNode);
          setState(() {
            _hasAutoFocused = true;
          });
        }
      });
    }

    return BlocBuilder<PostCreationBloc, PostCreationState>(
      buildWhen: (previous, current) => previous.content != current.content,
      builder: (context, state) {
        // Update the controller if the state changes from elsewhere
        if (_contentController.text != state.content) {
          _contentController.text = state.content;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and input field
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar
                CircleAvatar(
                  radius: 24,
                  backgroundImage: widget.userAvatarUrl != null &&
                          widget.userAvatarUrl!.startsWith('http')
                      ? NetworkImage(widget.userAvatarUrl!)
                      : null,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                  child: widget.userAvatarUrl == null
                      ? Text(
                          widget.userDisplayName?[0].toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Text input field
                Expanded(
                  child: Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(16),
                    color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: TextField(
                        controller: _contentController,
                        focusNode: _focusNode,
                        maxLines: null,
                        minLines: 4,
                        maxLength: widget.maxCharCount,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText: "What's on your mind?",
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        // Remove the built-in counter
                        buildCounter: (context,
                                {required currentLength,
                                required isFocused,
                                maxLength}) =>
                            null,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Character counter
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 60),
              child: Text(
                '${_contentController.text.length}/${widget.maxCharCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: _contentController.text.length >
                          widget.maxCharCount * 0.8
                      ? _contentController.text.length >= widget.maxCharCount
                          ? Colors.red
                          : Colors.amber[700]
                      : isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

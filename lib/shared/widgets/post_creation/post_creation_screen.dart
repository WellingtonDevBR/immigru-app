import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_event.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_state.dart';
import 'package:immigru/shared/widgets/post_creation/components/index.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:get_it/get_it.dart';

/// Screen for creating new posts with media attachments and category selection
/// This is a shared component that can be used across different features
class PostCreationScreen extends StatefulWidget {
  /// The current user
  final User user;

  /// Scroll controller for the modal bottom sheet
  final ScrollController scrollController;

  /// Callback when a post is submitted
  /// Parameters: content, category, mediaUrls
  final Function(String, String, List<PostMedia>) onPost;

  /// Constructor
  const PostCreationScreen({
    super.key,
    required this.user,
    required this.scrollController,
    required this.onPost,
  });

  @override
  State<PostCreationScreen> createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen>
    with SingleTickerProviderStateMixin {
  // Check if we can pop the screen (returns true if it's safe to pop)
  Future<bool> _onWillPop(PostCreationState state) async {
    final hasUnsaved = state.content.isNotEmpty || state.media.isNotEmpty;
    if (!hasUnsaved) return true;
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard post?'),
        content: const Text(
            'You have unsaved changes. Do you want to discard your post? All text and attachments will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return shouldDiscard == true;
  }

  final _logger = GetIt.instance<UnifiedLogger>();
  final ImagePicker _imagePicker = ImagePicker();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _animationController;
  bool _showSuccessAnimation = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onAnimationComplete();
      }
    });

    // Initialize the BLoC with default state
    context.read<PostCreationBloc>().add(PostCreationReset());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  /// Submit the post using the BLoC
  void _submitPost(PostCreationState state) {
    _logger.d('Submitting post', tag: 'PostCreationScreen');

    // Show success animation
    setState(() {
      _showSuccessAnimation = true;
    });

    _animationController.forward(from: 0.0);

    // Submit the post via BLoC
    context.read<PostCreationBloc>().add(
          PostSubmitted(
            userId: widget.user.id,
            content: state.content,
            category: state.category,
            media: state.media,
          ),
        );

    // Call the onPost callback
    widget.onPost(
      state.content,
      state.category,
      state.media,
    );
  }

  /// Handle animation completion
  void _onAnimationComplete() {
    // Reset the animation state
    if (mounted) {
      setState(() {
        _showSuccessAnimation = false;
      });

      // Reset the form
      context.read<PostCreationBloc>().add(PostCreationReset());
    }
  }

  /// Build the success animation widget
  Widget _buildSuccessAnimation() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scaleValue = Tween<double>(begin: 0.0, end: 1.0)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
              ),
            )
            .value;

        final opacityValue = Tween<double>(begin: 1.0, end: 0.0)
            .animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
              ),
            )
            .value;

        return Opacity(
          opacity: opacityValue,
          child: Transform.scale(
            scale: scaleValue,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Pick an image from gallery or camera
  Future<void> _pickImage() async {
    _logger.d('Add photo button pressed', tag: 'PostCreationScreen');

    // Show bottom sheet with options
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _getImageFromSource(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _getImageFromSource(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Pick a video from gallery or camera
  Future<void> _pickVideo() async {
    _logger.d('Add video button pressed', tag: 'PostCreationScreen');

    // Show bottom sheet with options
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.video_library),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _getVideoFromSource(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text('Record a video'),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _getVideoFromSource(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get image from the specified source
  Future<void> _getImageFromSource(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null && mounted) {
        // Create a PostMedia object
        final media = PostMedia(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          path: pickedFile.path,
          name: pickedFile.name,
          type: MediaType.image,
          createdAt: DateTime.now(),
        );

        // Add the media to the bloc
        context.read<PostCreationBloc>().add(MediaAdded(media));

        _logger.d('Image selected: ${pickedFile.path}',
            tag: 'PostCreationScreen');
      }
    } catch (e) {
      _logger.e('Error picking image: $e', tag: 'PostCreationScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  /// Get video from the specified source
  Future<void> _getVideoFromSource(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 1),
      );

      if (pickedFile != null && mounted) {
        // Create a PostMedia object
        final media = PostMedia(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          path: pickedFile.path,
          name: pickedFile.name,
          type: MediaType.video,
          createdAt: DateTime.now(),
        );

        // Add the media to the bloc
        context.read<PostCreationBloc>().add(MediaAdded(media));

        _logger.d('Video selected: ${pickedFile.path}',
            tag: 'PostCreationScreen');
      }
    } catch (e) {
      _logger.e('Error picking video: $e', tag: 'PostCreationScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting video: $e')),
        );
      }
    }
  }

  /// Build a media icon button for the bottom action bar
  Widget _buildMediaIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCreationBloc, PostCreationState>(
      listenWhen: (previous, current) =>
          previous.isSuccess != current.isSuccess ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return PopScope<dynamic>(
          canPop: false, // Prevent automatic pop
          onPopInvokedWithResult: (didPop, result) async {
            // If already popped by system, do nothing
            if (didPop) return;

            // Check if we can safely pop
            final canPop = await _onWillPop(state);
            if (canPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: _buildScaffold(context, state),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, PostCreationState state) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // Update text controller with state content if needed
    if (_textController.text != state.content) {
      _textController.text = state.content;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }

    return BlocConsumer<PostCreationBloc, PostCreationState>(
      listenWhen: (previous, current) =>
          previous.isSuccess != current.isSuccess ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        // Show error message if needed
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return GestureDetector(
              // Dismiss keyboard when tapping outside the text field
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                height: size.height,
                width: size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkMode
                        ? [
                            Colors.black,
                            Color(0xFF1A1A1A),
                          ]
                        : [
                            AppColors.sproutGreen.withValues(alpha: 0.05),
                            Colors.white,
                          ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Success animation overlay
                    if (_showSuccessAnimation)
                      Center(child: _buildSuccessAnimation()),

                    // Main content container
                    Column(
                      children: [
                        // Header with drag handle and user info
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.black : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Drag handle
                              Container(
                                width: 40,
                                height: 5,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? (Colors.grey[700] ?? Colors.grey)
                                      : (Colors.grey[300] ?? Colors.grey),
                                  borderRadius: BorderRadius.circular(2.5),
                                ),
                              ),

                              // User info row
                              Row(
                                children: [
                                  // User avatar
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.1),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundImage: widget.user.photoUrl !=
                                                  null &&
                                              widget.user.photoUrl!
                                                  .startsWith('http')
                                          ? NetworkImage(widget.user.photoUrl!)
                                          : null,
                                      backgroundColor: theme.colorScheme.primary
                                          .withValues(alpha: 0.2),
                                      child: widget.user.photoUrl == null
                                          ? Text(
                                              widget.user.displayName?[0]
                                                      .toUpperCase() ??
                                                  'U',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // User name and posting info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.user.displayName ?? 'User',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Posting to your profile',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Character counter
                                  CharacterCounter(text: state.content),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Content area (expandable)
                        Expanded(
                          child: Container(
                            color: isDarkMode ? Colors.black : Colors.white,
                            child: SingleChildScrollView(
                              controller: widget.scrollController,
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text input field
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 16, 16, 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? (Colors.grey[900] ?? Colors.black)
                                                .withValues(alpha: 0.5)
                                            : (Colors.grey[50] ?? Colors.white),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: TextField(
                                        controller: _textController,
                                        focusNode: _focusNode,
                                        maxLines: null,
                                        minLines: 3, // Reduced from 5 to make it more compact
                                        maxLength: 500,
                                        maxLengthEnforcement:
                                            MaxLengthEnforcement.enforced,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        textDirection: TextDirection.ltr,
                                        onChanged: (value) {
                                          context.read<PostCreationBloc>().add(
                                                PostContentChanged(value),
                                              );
                                        },
                                        style: TextStyle(
                                          fontSize: 15, // Slightly smaller font
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                          height: 1.3, // Slightly tighter line height
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "What's on your mind?",
                                          hintStyle: TextStyle(
                                            color: isDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                            fontSize: 16,
                                            height: 1.4,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.all(16),
                                          counterText: '',
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Selected media display
                                  if (state.media.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: MediaDisplay(
                                        media: state.media,
                                        onRemoveMedia: (mediaId) {
                                          context.read<PostCreationBloc>().add(
                                                MediaRemoved(mediaId),
                                              );
                                        },
                                      ),
                                    ),

                                  // Category selection
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: CategoryPicker(
                                      selectedCategory: state.category,
                                      onCategorySelected: (category) {
                                        context.read<PostCreationBloc>().add(
                                              CategorySelected(category),
                                            );
                                      },
                                    ),
                                  ),

                                  // Add a small spacer to ensure proper spacing between elements
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom action bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.black : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Media buttons
                              _buildMediaIconButton(
                                icon: Icons.image_outlined,
                                color: AppColors.sproutGreen,
                                onTap: _pickImage,
                              ),
                              const SizedBox(width: 12),
                              _buildMediaIconButton(
                                icon: Icons.videocam_outlined,
                                color: AppColors.skyBlue,
                                onTap: _pickVideo,
                              ),
                              const SizedBox(width: 12),

                              // Spacer
                              const Spacer(),

                              // Post button
                              SizedBox(
                                width: 100,
                                height: 44,
                                child: PostButton(
                                  enabled: state.content.trim().isNotEmpty,
                                  isSubmitting: state.isSubmitting ||
                                      _showSuccessAnimation,
                                  onTap: () => _submitPost(state),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_event.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_state.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Screen for creating new posts with media attachments and category selection
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

class _PostCreationScreenState extends State<PostCreationScreen> with SingleTickerProviderStateMixin {
  Future<bool> _onWillPop(PostCreationState state) async {
    final hasUnsaved = state.content.isNotEmpty || state.media.isNotEmpty;
    if (!hasUnsaved) return true;
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard post?'),
        content: const Text('You have unsaved changes. Do you want to discard your post? All text and attachments will be lost.'),
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
  final _logger = UnifiedLogger();
  final ImagePicker _imagePicker = ImagePicker();
  final FocusNode _focusNode = FocusNode();
  
  late AnimationController _animationController;
  bool _showSuccessAnimation = false;
  bool _hasAutoFocused = false;

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
        final scaleValue = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
          ),
        ).value;
        
        final opacityValue = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
          ),
        ).value;
        
        return Opacity(
          opacity: opacityValue,
          child: Transform.scale(
            scale: scaleValue,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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

  /// Build the post content input widget
  Widget _buildPostContentInput(PostCreationState state) {
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
    
    // Create a controller that updates the BLoC when text changes
    final controller = TextEditingController(text: state.content);
    controller.addListener(() {
      if (controller.text != state.content) {
        context.read<PostCreationBloc>().add(
          PostContentChanged(controller.text),
        );
      }
    });
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User avatar
        CircleAvatar(
          radius: 24,
          backgroundImage: widget.user.photoUrl != null &&
                  widget.user.photoUrl!.startsWith('http')
              ? NetworkImage(widget.user.photoUrl!)
              : null,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
          child: widget.user.photoUrl == null
              ? Text(
                  widget.user.displayName?[0].toUpperCase() ?? 'U',
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
                controller: controller,
                focusNode: _focusNode,
                maxLines: null,
                minLines: 4,
                maxLength: 500,
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
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build character counter below the input field
  Widget _buildCharacterCounter(String text) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    const maxCount = 500;
    
    final color = text.length > maxCount * 0.8
        ? text.length >= maxCount
            ? Colors.red
            : Colors.amber[700]
        : isDarkMode
            ? Colors.grey[400]
            : Colors.grey[600];
            
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 60),
      child: Text(
        '${text.length}/$maxCount',
        style: TextStyle(
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }

  /// Build the selected media list widget
  Widget _buildSelectedMediaList(PostCreationState state) {
    if (state.media.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.media.length,
        itemBuilder: (context, index) {
          final media = state.media[index];
          return _buildMediaChip(media);
        },
      ),
    );
  }

  /// Build a media chip for the selected media list
  Widget _buildMediaChip(PostMedia media) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Extract filename from path
    final fileName = media.name.length > 15 
        ? '${media.name.substring(0, 12)}...' 
        : media.name;
    
    // Determine if it's an image or video
    final isVideo = media.type == MediaType.video;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
              ),
              child: SizedBox(
                width: 50,
                height: 50,
                child: _buildThumbnail(media.path, isVideo),
              ),
            ),
            
            // Filename and type icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    isVideo ? Icons.videocam : Icons.image,
                    size: 16,
                    color: isVideo 
                        ? Colors.blue 
                        : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            
            // Remove button
            GestureDetector(
              onTap: () {
                context.read<PostCreationBloc>().add(MediaRemoved(media.id));
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a thumbnail for a media item
  Widget _buildThumbnail(String path, bool isVideo) {
    try {
      if (path.startsWith('http')) {
        // Network image
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              path,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorThumbnail();
              },
            ),
            if (isVideo)
              const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
          ],
        );
      } else {
        // Local file
        final file = File(path);
        if (file.existsSync()) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorThumbnail();
                },
              ),
              if (isVideo)
                const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
            ],
          );
        } else {
          return _buildErrorThumbnail();
        }
      }
    } catch (e) {
      return _buildErrorThumbnail();
    }
  }

  /// Build a placeholder for when the thumbnail can't be loaded
  Widget _buildErrorThumbnail() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.white54,
          size: 20,
        ),
      ),
    );
  }

  /// Build the category picker widget
  Widget _buildCategoryPicker(PostCreationState state) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final categories = ['General', 'Question', 'Event', 'News', 'Other'];
    
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
  }

  /// Build the media selection buttons
  Widget _buildMediaSelectionButtons() {
    return Row(
      children: [
        _buildMediaButton(
          icon: Icons.image_outlined,
          label: 'Photo',
          color: AppColors.sproutGreen,
          onTap: () {
            HapticFeedback.lightImpact();
            _pickImage();
          },
        ),
        const SizedBox(width: 12),
        _buildMediaButton(
          icon: Icons.videocam_outlined,
          label: 'Video',
          color: AppColors.skyBlue,
          onTap: () {
            HapticFeedback.lightImpact();
            _pickVideo();
          },
        ),
      ],
    );
  }

  /// Build a styled media selection button
  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /// Pick an image from gallery or camera
  Future<void> _pickImage() async {
    _logger.d('Add photo button pressed', tag: 'PostCreationScreen');
    
    // Get the current bloc and state before showing the bottom sheet
    final bloc = context.read<PostCreationBloc>();
    final currentState = bloc.state;
    
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
    
    // Get the current bloc and state before showing the bottom sheet
    final bloc = context.read<PostCreationBloc>();
    final currentState = bloc.state;
    
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
        
        _logger.d('Image selected: ${pickedFile.path}', tag: 'PostCreationScreen');
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
        
        _logger.d('Video selected: ${pickedFile.path}', tag: 'PostCreationScreen');
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

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final isDarkMode = theme.brightness == Brightness.dark;

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
      return WillPopScope(
        onWillPop: () => _onWillPop(state),
        child: _buildScaffold(context, state),
      );
    },
  );
}

Widget _buildScaffold(BuildContext context, PostCreationState state) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

            return GestureDetector(
              // Dismiss keyboard when tapping outside the text field
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  // Blurred background
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                  
                  // Main content
                  Material(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Success animation overlay
                        if (_showSuccessAnimation)
                          Center(
                            child: _buildSuccessAnimation(),
                          ),
                        
                        // Scrollable content
                        SingleChildScrollView(
                          controller: widget.scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Drag handle
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 5,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(2.5),
                                  ),
                                ),
                              ),
                              
                              // Post content input with user avatar
                              _buildPostContentInput(state),
                              
                              // Character counter
                              _buildCharacterCounter(state.content),
                              
                              const SizedBox(height: 16),
                              
                              // Selected media display
                              _buildSelectedMediaList(state),
                              
                              const SizedBox(height: 16),
                              
                              // Category picker
                              _buildCategoryPicker(state),
                              
                              const SizedBox(height: 16),
                              
                              // Media selection and post button row
                              Row(
                                children: [
                                  // Media selection buttons
                                  _buildMediaSelectionButtons(),
                                  
                                  const SizedBox(width: 12),
                                  
                                  // Post button - expanded to fill available space
                                  Expanded(
                                    child: ElevatedButton(
                                    onPressed: state.content.trim().isEmpty ||
                                              state.isSubmitting ||
                                              _showSuccessAnimation
                                        ? null
                                        : () {
                                            HapticFeedback.mediumImpact();
                                            _submitPost(state);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: isDarkMode
                                          ? Colors.grey[800]
                                          : theme.colorScheme.primary.withOpacity(0.3),
                                      disabledForegroundColor: isDarkMode
                                          ? Colors.grey[600]
                                          : Colors.white.withOpacity(0.8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: state.isSubmitting
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Text(
                                            'Post',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Floating preview above keyboard
                        if (isKeyboardVisible && state.content.trim().isNotEmpty)
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: keyboardHeight + 8,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: 1.0,
                              child: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(12),
                                color: isDarkMode ? Colors.grey[850] : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Text(
                                    state.content.trim(),
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white70 : Colors.black87,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

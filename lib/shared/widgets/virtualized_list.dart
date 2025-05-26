import 'package:flutter/material.dart';
import 'package:immigru/core/logging/unified_logger.dart';

/// A virtualized list widget that only renders items that are visible on screen
/// 
/// This widget improves performance by:
/// 1. Only building items that are visible in the viewport
/// 2. Recycling item widgets when they scroll out of view
/// 3. Pre-loading items just outside the viewport for smoother scrolling
/// 4. Efficiently handling large lists with minimal memory usage
class VirtualizedList<T> extends StatefulWidget {
  /// The list of items to display
  final List<T> items;
  
  /// Builder function to create widgets for each item
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  
  /// Optional builder for placeholders when items are loading
  final Widget Function(BuildContext context, int index)? placeholderBuilder;
  
  /// Number of items to preload outside the viewport
  final int preloadItemCount;
  
  /// Height of each item (can be estimated if variable)
  final double estimatedItemHeight;
  
  /// Callback when the user scrolls to the end of the list
  final VoidCallback? onEndReached;
  
  /// Threshold to trigger onEndReached (0.0 to 1.0)
  final double endReachedThreshold;
  
  /// Whether the list is currently loading more items
  final bool isLoading;
  
  /// Scroll controller for the list
  final ScrollController? scrollController;
  
  /// Padding around the list
  final EdgeInsetsGeometry? padding;
  
  /// Physics for the scroll view
  final ScrollPhysics? physics;
  
  /// Whether the list should shrink wrap its contents
  final bool shrinkWrap;
  
  const VirtualizedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.placeholderBuilder,
    this.preloadItemCount = 5,
    this.estimatedItemHeight = 100.0,
    this.onEndReached,
    this.endReachedThreshold = 0.8,
    this.isLoading = false,
    this.scrollController,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  State<VirtualizedList<T>> createState() => _VirtualizedListState<T>();
}

class _VirtualizedListState<T> extends State<VirtualizedList<T>> {
  final _logger = UnifiedLogger();
  late ScrollController _scrollController;
  
  // Visible item range
  int _firstVisibleIndex = 0;
  int _lastVisibleIndex = 0;
  
  // Flag to track if we've reached the end
  bool _hasReachedEnd = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_handleScroll);
    
    // Initialize visible range based on viewport size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateVisibleRange();
    });
  }
  
  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_handleScroll);
    }
    super.dispose();
  }
  
  @override
  void didUpdateWidget(VirtualizedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update scroll controller if needed
    if (widget.scrollController != oldWidget.scrollController) {
      if (oldWidget.scrollController == null) {
        _scrollController.removeListener(_handleScroll);
        _scrollController.dispose();
      } else {
        oldWidget.scrollController!.removeListener(_handleScroll);
      }
      
      _scrollController = widget.scrollController ?? ScrollController();
      _scrollController.addListener(_handleScroll);
    }
    
    // Reset end reached flag if items changed
    if (widget.items.length != oldWidget.items.length) {
      _hasReachedEnd = false;
      
      // Update visible range after items change
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateVisibleRange();
      });
    }
  }
  
  void _handleScroll() {
    _updateVisibleRange();
    
    // Check if we've reached the end of the list
    if (!_hasReachedEnd && 
        widget.onEndReached != null && 
        !widget.isLoading &&
        _scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * widget.endReachedThreshold) {
      _hasReachedEnd = true;
      widget.onEndReached!();
      _logger.d('Reached end of virtualized list', tag: 'VirtualizedList');
    }
    
    // Reset end reached flag when scrolling back up
    if (_hasReachedEnd && 
        _scrollController.position.pixels < 
        _scrollController.position.maxScrollExtent * (widget.endReachedThreshold - 0.1)) {
      _hasReachedEnd = false;
    }
  }
  
  void _updateVisibleRange() {
    if (!_scrollController.hasClients || widget.items.isEmpty) return;
    
    final viewportHeight = _scrollController.position.viewportDimension;
    final scrollOffset = _scrollController.offset;
    
    // Calculate visible range based on scroll position and viewport size
    final firstVisible = (scrollOffset / widget.estimatedItemHeight).floor();
    final lastVisible = ((scrollOffset + viewportHeight) / widget.estimatedItemHeight).ceil();
    
    // Add preload buffer
    final newFirstVisible = (firstVisible - widget.preloadItemCount).clamp(0, widget.items.length - 1);
    final newLastVisible = (lastVisible + widget.preloadItemCount).clamp(0, widget.items.length - 1);
    
    if (newFirstVisible != _firstVisibleIndex || newLastVisible != _lastVisibleIndex) {
      setState(() {
        _firstVisibleIndex = newFirstVisible;
        _lastVisibleIndex = newLastVisible;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.items.length + (widget.isLoading ? widget.preloadItemCount : 0),
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemBuilder: (context, index) {
        // Show loading placeholders at the end if loading
        if (index >= widget.items.length) {
          return widget.placeholderBuilder != null
              ? widget.placeholderBuilder!(context, index)
              : SizedBox(height: widget.estimatedItemHeight);
        }
        
        // Only build items within the visible range
        final item = widget.items[index];
        if (index >= _firstVisibleIndex && index <= _lastVisibleIndex) {
          return widget.itemBuilder(context, item, index);
        } else {
          // Return a sized box for items outside the visible range
          return SizedBox(height: widget.estimatedItemHeight);
        }
      },
    );
  }
}

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

/// A custom like button that shows a small tree that shakes and drops leaves when clicked.
/// Symbolizes growth and connection in the Immigru app.
class GroveLikeButton extends StatefulWidget {
  /// The size of the button
  final double size;

  /// Duration of the animation
  final Duration animationDuration;

  /// Color of the trunk and branches
  final Color trunkColor;

  /// Color of the root
  final Color rootColor;

  /// Color of the leaves
  final Color leafColor;

  /// Initial liked state
  final bool initialLiked;

  /// Callback when the like state changes
  final Function(bool)? onLikeChanged;

  const GroveLikeButton({
    super.key,
    this.size = 28,
    this.animationDuration = const Duration(milliseconds: 600),
    this.trunkColor = const Color(0xFF2E7D32), // Colors.green.shade800
    this.rootColor = const Color(0xFF6D4C41), // Colors.brown.shade600
    this.leafColor = const Color(0xFF8BC34A), // Colors.lightGreen.shade400
    this.initialLiked = false,
    this.onLikeChanged,
  });

  @override
  State<GroveLikeButton> createState() => _GroveLikeButtonState();
}

class _GroveLikeButtonState extends State<GroveLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _growthAnimation;
  late Animation<double> _leafFallAnimation;
  bool _isLiked = false;
  final List<FallingLeaf> _fallingLeaves = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialLiked;

    // Initialize the animation controller
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Setup the shake animation
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.03), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.03, end: 0.03), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.03, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    // Setup the growth animation
    _growthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    // Setup leaf fall animation
    _leafFallAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 1.0, curve: Curves.easeInOut),
    );

    // Add a listener to rebuild the widget when the animation value changes
    _controller.addListener(() {
      setState(() {});
    });

    // Add a status listener to clean up falling leaves when animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Clear falling leaves after animation completes
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _fallingLeaves.clear();
            });
          }
        });
      }
    });

    // If initially liked, show the full tree
    if (_isLiked) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(GroveLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle external changes to the liked state
    if (widget.initialLiked != oldWidget.initialLiked) {
      _isLiked = widget.initialLiked;

      if (_isLiked && _controller.value == 0.0) {
        // If changed to liked and animation hasn't run yet, run it
        _generateFallingLeaves();
        _controller.forward(from: 0.0);
      } else if (!_isLiked && _controller.value > 0.0) {
        // If changed to not liked, reset the animation
        _controller.value = 0.0;
        _fallingLeaves.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _generateFallingLeaves();
        _controller.forward(from: 0.0);
      } else {
        // Reset animation when unliked
        _controller.value = 0.0;
        _fallingLeaves.clear();
      }
    });

    // Notify parent of the change if callback is provided
    if (widget.onLikeChanged != null) {
      widget.onLikeChanged!(_isLiked);
    }
  }

  void _generateFallingLeaves() {
    // Generate 3-5 falling leaves
    final count = _random.nextInt(3) + 3;
    _fallingLeaves.clear();

    for (int i = 0; i < count; i++) {
      _fallingLeaves.add(FallingLeaf(
        startX: _random.nextDouble() * widget.size * 0.8 - widget.size * 0.4,
        startY: -widget.size * 0.3 - _random.nextDouble() * widget.size * 0.2,
        fallSpeed: 0.5 + _random.nextDouble() * 0.5,
        swayFactor: 0.1 + _random.nextDouble() * 0.2,
        rotationSpeed: _random.nextDouble() * 0.1 - 0.05,
        size: widget.size * (0.08 + _random.nextDouble() * 0.04),
        color: HSLColor.fromColor(widget.leafColor)
            .withLightness((HSLColor.fromColor(widget.leafColor).lightness +
                    (_random.nextDouble() * 0.2 - 0.1))
                .clamp(0.0, 1.0))
            .toColor(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Tree with shake and growth animation
            Transform.rotate(
              angle: _controller.isAnimating ? _shakeAnimation.value : 0.0,
              child: Transform.scale(
                scale: _controller.isAnimating
                    ? 0.6 + 0.4 * _growthAnimation.value
                    : (_isLiked ? 1.0 : 0.6),
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: TreePainter(
                    isLiked: _isLiked,
                    trunkColor: widget.trunkColor,
                    rootColor: widget.rootColor,
                    leafColor: widget.leafColor,
                    animationValue: _controller.isAnimating
                        ? _growthAnimation.value
                        : _isLiked
                            ? 1.0
                            : 0.0,
                  ),
                ),
              ),
            ),

            // Falling leaves animation
            if (_fallingLeaves.isNotEmpty)
              ...List.generate(_fallingLeaves.length, (index) {
                final leaf = _fallingLeaves[index];
                final progress =
                    _controller.isAnimating ? _leafFallAnimation.value : 1.0;

                // Calculate leaf position based on animation progress
                final x = leaf.startX +
                    sin(progress * 5 * leaf.swayFactor) * widget.size * 0.2;
                final y = leaf.startY + progress * widget.size * leaf.fallSpeed;
                final rotation = progress * pi * 2 * leaf.rotationSpeed;

                // Only show leaves that are within the visible area
                if (y > widget.size * 0.5) return const SizedBox.shrink();

                return Positioned(
                  left: widget.size / 2 + x,
                  top: widget.size / 2 + y,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Opacity(
                      opacity: 1.0 - progress * 0.7,
                      child: Container(
                        width: leaf.size,
                        height: leaf.size,
                        decoration: BoxDecoration(
                          color: leaf.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// Model class for a falling leaf
class FallingLeaf {
  final double startX;
  final double startY;
  final double fallSpeed;
  final double swayFactor;
  final double rotationSpeed;
  final double size;
  final Color color;

  FallingLeaf({
    required this.startX,
    required this.startY,
    required this.fallSpeed,
    required this.swayFactor,
    required this.rotationSpeed,
    required this.size,
    required this.color,
  });
}

/// Custom painter that draws a fuller tree with brown branches and green gradient leaves
class TreePainter extends CustomPainter {
  final bool isLiked;
  final Color trunkColor;
  final Color rootColor;
  final Color leafColor;
  final double animationValue; // Add animation value for smooth transition

  TreePainter({
    required this.isLiked,
    required this.trunkColor,
    required this.rootColor,
    required this.leafColor,
    this.animationValue = 1.0, // Default to fully animated
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height * 0.8);
    final trunkTop = Offset(center.dx, size.height * 0.4);

    // Animate trunk thickness from tiny to full
    final trunkPaint = Paint()
      ..color = trunkColor
      ..strokeWidth = lerpDouble(1.0, size.width * 0.12, animationValue)!
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, trunkTop, trunkPaint);

    // Animate branches (appear after a while)
    final branchPaint = Paint()
      ..color = trunkColor
      ..strokeWidth = lerpDouble(0.0, size.width * 0.06, animationValue)!
      ..strokeCap = StrokeCap.round;

    if (animationValue > 0.1) {
      final branchOpacity = animationValue.clamp(0.0, 1.0);
      final fadedPaint = branchPaint
        ..color = branchPaint.color.withValues(alpha: branchOpacity);

      final leftBranch = Offset(
          center.dx - size.width * 0.15 * animationValue, size.height * 0.5);
      final rightBranch = Offset(
          center.dx + size.width * 0.15 * animationValue, size.height * 0.5);

      canvas.drawLine(
          Offset(center.dx, size.height * 0.6), leftBranch, fadedPaint);
      canvas.drawLine(
          Offset(center.dx, size.height * 0.6), rightBranch, fadedPaint);
    }

    // Leaf setup
    final leafPaint = Paint()..style = PaintingStyle.fill;
    final baseLeafColor =
        leafColor.withValues(alpha: 0.6 + 0.4 * animationValue);
    final darkLeafColor =
        Color.lerp(baseLeafColor, Colors.green.shade900, 0.25)!;
    final clusterSize = size.width * 0.35 * animationValue;

    final clusterOpacity = animationValue;

    // Center cluster (top)
    if (animationValue > 0.0) {
      _drawLeafCluster(canvas, leafPaint, baseLeafColor, darkLeafColor,
          Offset(center.dx, size.height * 0.35), clusterSize, clusterOpacity);
    }

    // Side clusters
    if (animationValue > 0.3) {
      _drawLeafCluster(
          canvas,
          leafPaint,
          baseLeafColor,
          darkLeafColor,
          Offset(center.dx - clusterSize * 0.8, size.height * 0.4),
          clusterSize * 0.9,
          clusterOpacity);
      _drawLeafCluster(
          canvas,
          leafPaint,
          baseLeafColor,
          darkLeafColor,
          Offset(center.dx + clusterSize * 0.8, size.height * 0.4),
          clusterSize * 0.9,
          clusterOpacity);
    }

    // Bottom cluster
    if (animationValue > 0.6) {
      _drawLeafCluster(
          canvas,
          leafPaint,
          baseLeafColor,
          darkLeafColor,
          Offset(center.dx, size.height * 0.45),
          clusterSize * 0.8,
          clusterOpacity);
    }
  }

  void _drawLeafCluster(Canvas canvas, Paint paint, Color baseColor,
      Color darkColor, Offset center, double size, double opacity) {
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.9,
      colors: [
        baseColor.withValues(alpha: opacity),
        darkColor.withValues(alpha: opacity),
      ],
      stops: const [0.4, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: size));

    paint.shader = gradient;

    final ovalRect =
        Rect.fromCenter(center: center, width: size * 1.2, height: size);
    canvas.drawOval(ovalRect, paint);

    paint.shader = null;
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) {
    return oldDelegate.isLiked != isLiked;
  }
}

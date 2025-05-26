import 'dart:math';
import 'package:flutter/material.dart';

/// A button that symbolizes commenting, using a growing seed and sprouting animation.
/// Matches the style and feel of the GroveLikeButton for consistency.
class SeedCommentButton extends StatefulWidget {
  /// The size of the button
  final double size;

  /// Duration of the animation
  final Duration animationDuration;

  /// Color of the seed
  final Color seedColor;

  /// Color of the sprout
  final Color sproutColor;

  /// Initial commented state
  final bool initialCommented;
  
  /// Flag to control when animation should play
  final bool shouldPlayAnimation;

  /// Callback when the comment state changes
  final Function(bool)? onCommentedChanged;

  const SeedCommentButton({
    super.key,
    this.size = 28,
    this.animationDuration = const Duration(milliseconds: 600),
    this.seedColor = const Color(0xFF795548), // brown seed
    this.sproutColor = const Color(0xFF8BC34A), // light green sprout
    this.initialCommented = false,
    this.shouldPlayAnimation = false,
    this.onCommentedChanged,
  });

  @override
  State<SeedCommentButton> createState() => _SeedCommentButtonState();
}

class _SeedCommentButtonState extends State<SeedCommentButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _growthAnimation;
  late Animation<double> _sproutAnimation;
  late Animation<double> _shakeAnimation;
  bool _isCommented = false;
  final List<SproutParticle> _sproutParticles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _isCommented = widget.initialCommented;

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _growthAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _sproutAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    ));

    _generateSproutParticles();

    if (_isCommented) {
      _controller.value = 1.0;
    }

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Clear sprout particles after animation completes
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _sproutParticles.clear();
            });
          }
        });
      }
    });

    if (_isCommented) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SeedCommentButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update internal state if the commented state changes
    if (oldWidget.initialCommented != widget.initialCommented) {
      _isCommented = widget.initialCommented;
      
      // Only play animation when transitioning from uncommented to commented
      if (_isCommented && !oldWidget.initialCommented) {
        _generateSproutParticles();
        _controller.forward(from: 0.0);
      } else if (!_isCommented && oldWidget.initialCommented) {
        // Reset controller without animation when uncommenting
        _controller.value = 0.0;
        _sproutParticles.clear();
      }
    }
  }

  void _generateSproutParticles() {
    // Create 3-5 sprout particles
    final count = _random.nextInt(3) + 3;
    _sproutParticles.clear();

    for (int i = 0; i < count; i++) {
      _sproutParticles.add(SproutParticle(
        angle: _random.nextDouble() * pi * 2,
        distance: _random.nextDouble() * widget.size * 0.5 + widget.size * 0.2,
        size: _random.nextDouble() * widget.size * 0.15 + widget.size * 0.1,
        delay: _random.nextDouble() * 0.3,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // This is now controlled by the parent widget
        // We don't handle tap events directly anymore
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _shakeAnimation.value * pi / 10,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: SeedPainter(
                  isCommented: _isCommented,
                  seedColor: widget.seedColor,
                  sproutColor: widget.sproutColor,
                  growthValue: _growthAnimation.value,
                  sproutValue: _sproutAnimation.value,
                  sproutParticles: _sproutParticles,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Model class for a sprout particle
class SproutParticle {
  final double angle;
  final double distance;
  final double size;
  final double delay;

  SproutParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });
}

/// Custom painter that draws a seed with sprouting animation
class SeedPainter extends CustomPainter {
  final bool isCommented;
  final Color seedColor;
  final Color sproutColor;
  final double growthValue;
  final double sproutValue;
  final List<SproutParticle> sproutParticles;

  SeedPainter({
    required this.isCommented,
    required this.seedColor,
    required this.sproutColor,
    required this.growthValue,
    required this.sproutValue,
    required this.sproutParticles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Clip to prevent overflow
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height / 2);

    // Draw the seed
    _drawSeed(canvas, size, center);

    // Draw sprouts if commented
    if (isCommented && sproutValue > 0) {
      _drawSprouts(canvas, size, center);
    }

    // Draw sprout particles
    if (sproutParticles.isNotEmpty && sproutValue > 0) {
      _drawSproutParticles(canvas, size, center);
    }
  }

  void _drawSeed(Canvas canvas, Size size, Offset center) {
    final seedPaint = Paint()..color = seedColor;

    // Calculate seed dimensions based on growth value
    final seedWidth = size.width * 0.4 * growthValue;
    final seedHeight = size.height * 0.55 * growthValue;

    // Create seed path
    final path = Path();
    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCenter(
        center: center,
        width: seedWidth,
        height: seedHeight,
      ),
      -pi / 2,
      pi,
      false,
    );
    path.arcTo(
      Rect.fromCenter(
        center: center,
        width: seedWidth,
        height: seedHeight,
      ),
      pi / 2,
      pi,
      false,
    );
    path.close();

    canvas.drawPath(path, seedPaint);
  }

  void _drawSprouts(Canvas canvas, Size size, Offset center) {
    // Draw main sprout stem
    final stemPaint = Paint()
      ..color = sproutColor
      ..strokeWidth = size.width * 0.08 * sproutValue
      ..strokeCap = StrokeCap.round;

    final stemHeight = size.height * 0.4 * sproutValue;
    final stemTop = Offset(center.dx, center.dy - stemHeight);

    canvas.drawLine(center, stemTop, stemPaint);

    // Draw leaves
    final leafPaint = Paint()..color = sproutColor.withValues(alpha:0.9);

    // Left leaf
    if (sproutValue > 0.3) {
      final leafProgress = ((sproutValue - 0.3) / 0.7).clamp(0.0, 1.0);
      final leftLeafSize = size.width * 0.25 * leafProgress;
      final leftLeafOffset = Offset(
        center.dx - leftLeafSize * 0.7,
        center.dy - stemHeight * 0.6,
      );

      final leftLeafPath = Path();
      leftLeafPath.moveTo(stemTop.dx, stemTop.dy + stemHeight * 0.4);
      leftLeafPath.quadraticBezierTo(
        leftLeafOffset.dx,
        leftLeafOffset.dy,
        stemTop.dx - leftLeafSize * 0.2,
        stemTop.dy + stemHeight * 0.3,
      );
      leftLeafPath.quadraticBezierTo(
        stemTop.dx - leftLeafSize * 0.1,
        stemTop.dy + stemHeight * 0.35,
        stemTop.dx,
        stemTop.dy + stemHeight * 0.4,
      );

      canvas.drawPath(leftLeafPath, leafPaint);
    }

    // Right leaf
    if (sproutValue > 0.5) {
      final leafProgress = ((sproutValue - 0.5) / 0.5).clamp(0.0, 1.0);
      final rightLeafSize = size.width * 0.2 * leafProgress;
      final rightLeafOffset = Offset(
        center.dx + rightLeafSize * 0.7,
        center.dy - stemHeight * 0.7,
      );

      final rightLeafPath = Path();
      rightLeafPath.moveTo(stemTop.dx, stemTop.dy + stemHeight * 0.3);
      rightLeafPath.quadraticBezierTo(
        rightLeafOffset.dx,
        rightLeafOffset.dy,
        stemTop.dx + rightLeafSize * 0.2,
        stemTop.dy + stemHeight * 0.2,
      );
      rightLeafPath.quadraticBezierTo(
        stemTop.dx + rightLeafSize * 0.1,
        stemTop.dy + stemHeight * 0.25,
        stemTop.dx,
        stemTop.dy + stemHeight * 0.3,
      );

      canvas.drawPath(rightLeafPath, leafPaint);
    }
  }

  void _drawSproutParticles(Canvas canvas, Size size, Offset center) {
    final particlePaint = Paint()..color = sproutColor.withValues(alpha:0.7);

    for (final particle in sproutParticles) {
      // Calculate particle progress based on sprout value and particle delay
      final particleProgress =
          ((sproutValue - particle.delay) / (1.0 - particle.delay))
              .clamp(0.0, 1.0);

      if (particleProgress <= 0) continue;

      // Calculate particle position
      final particleX = center.dx +
          cos(particle.angle) * particle.distance * particleProgress;
      final particleY = center.dy +
          sin(particle.angle) * particle.distance * particleProgress;
      final particleOffset = Offset(particleX, particleY);

      // Draw particle
      canvas.drawCircle(
        particleOffset,
        particle.size * particleProgress,
        particlePaint
          ..color = sproutColor.withValues(alpha:0.7 * (1 - particleProgress)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SeedPainter oldDelegate) {
    return oldDelegate.isCommented != isCommented ||
        oldDelegate.growthValue != growthValue ||
        oldDelegate.sproutValue != sproutValue ||
        oldDelegate.seedColor != seedColor ||
        oldDelegate.sproutColor != sproutColor;
  }
}

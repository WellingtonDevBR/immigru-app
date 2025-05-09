import 'package:flutter/material.dart';
import 'package:immigru/core/constants/app_colors.dart';
import 'package:immigru/core/di/injection_container.dart';
import 'package:immigru/core/services/onboarding_service.dart';
import 'package:immigru/presentation/screens/auth/login_screen.dart';
import 'dart:ui';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _planeAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeInTextAnimation;
  late Animation<double> _fadeInButtonAnimation;
  late Animation<double> _planePositionAnimation;
  late Animation<double> _planeRotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startAnimations();
      }
    });
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeAnimationController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _planeAnimationController.repeat(reverse: false);
      }
    });
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _fadeInTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    _fadeInButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _planeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );
    _planePositionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _planeAnimationController,
        curve: Curves.linearToEaseOut,
      ),
    );
    _planeRotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.05).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: -0.05).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.0).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 20,
      ),
    ]).animate(_planeAnimationController);
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _planeAnimationController.dispose();
    super.dispose();
  }

  void _navigateToLogin() async {
    await sl<OnboardingService>().markWelcomeScreenAsSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.darkBackground, AppColors.darkSurface],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Logo in top left corner
              Positioned(
                top: 16,
                left: 16,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/immigru-logo.png',
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Immigru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animation container
                    SizedBox(
                      height: 200,
                      child: RepaintBoundary(
                        child: Stack(
                          children: [
                            // Connection paths
                            Positioned.fill(
                              child: FadeTransition(
                                opacity: _fadeInAnimation,
                                child: CustomPaint(
                                  painter: _ConnectionsPainter(
                                    color: AppColors.primaryColor.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                            // Plane animation (placeholder for actual plane widget)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: FadeTransition(
                                opacity: _fadeInAnimation,
                                child: AnimatedBuilder(
                                  animation: _planeAnimationController,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                        150 * _planePositionAnimation.value,
                                        -20 * _planePositionAnimation.value,
                                      ),
                                      child: Transform.rotate(
                                        angle: _planeRotationAnimation.value,
                                        child: Icon(
                                          Icons.flight_takeoff,
                                          size: 48,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeTransition(
                      opacity: _fadeInTextAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Welcome to Immigru',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ) ?? const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your journey, simplified. Connect, organize, and thrive with the immigrant community.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ) ?? const TextStyle(fontSize: 16, color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeTransition(
                      opacity: _fadeInButtonAnimation,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _navigateToLogin,
                        child: const Text(
                          'Get Started',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
    );
  }
}

/// Custom painter that draws connection paths between nodes
class _ConnectionsPainter extends CustomPainter {
  final Color color;
  _ConnectionsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final path = Path();
    // Draw a few quadratic bezier curves for illustration
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.5, size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.7, size.height, size.width, size.height * 0.6);
    canvas.drawPath(_createDashedPath(path, 8, 8), paint);
  }

  Path _createDashedPath(Path path, double dashLength, double dashSpace) {
    final Path dashedPath = Path();
    double distance = 0.0;
    for (final PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final double nextDash = distance + dashLength;
        dashedPath.addPath(
          pathMetric.extractPath(distance, nextDash.clamp(0.0, pathMetric.length)),
          Offset.zero,
        );
        distance = nextDash + dashSpace;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant _ConnectionsPainter oldDelegate) => false;
}

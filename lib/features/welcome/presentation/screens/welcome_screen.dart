import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/auth/presentation/screens/login_screen.dart';
import 'package:immigru/features/welcome/presentation/bloc/welcome_bloc.dart';
import 'package:immigru/features/welcome/presentation/bloc/welcome_event.dart';
import 'package:immigru/features/welcome/presentation/bloc/welcome_state.dart';
import 'package:immigru/core/di/service_locator.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Welcome screen that serves as the entry point to the app
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
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
        tween: Tween<double>(begin: -0.05, end: 0.05)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: -0.05)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
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

  void _navigateToLogin() {
    context.read<WelcomeBloc>().add(const WelcomeCompleted());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.instance<WelcomeBloc>()
        ..add(const WelcomeInitialized()),
      child: BlocConsumer<WelcomeBloc, WelcomeState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
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
                                          color: AppColors.primaryColor
                                              .withValues(alpha: 0.3),
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
                                              150 *
                                                  _planePositionAnimation.value,
                                              -20 *
                                                  _planePositionAnimation.value,
                                            ),
                                            child: Transform.rotate(
                                              angle:
                                                  _planeRotationAnimation.value,
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
                          // Welcome text
                          FadeTransition(
                            opacity: _fadeInTextAnimation,
                            child: const Text(
                              'Welcome to Immigru',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Description text
                          FadeTransition(
                            opacity: _fadeInTextAnimation,
                            child: const Text(
                              'Your companion for navigating the immigration journey. Connect with others, share experiences, and find the resources you need.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Get Started button
                          FadeTransition(
                            opacity: _fadeInButtonAnimation,
                            child: ElevatedButton(
                              onPressed: _navigateToLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                minimumSize: const Size(200, 50),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
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
        },
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
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw connection paths
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.1,
      size.width * 0.8,
      size.height * 0.4,
    );

    final dashedPath = _createDashedPath(path, 5, 5);
    canvas.drawPath(dashedPath, paint);

    // Draw nodes
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.1), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.4), 4, dotPaint);
  }

  Path _createDashedPath(Path path, double dashLength, double dashSpace) {
    final dashedPath = Path();
    final metrics = path.computeMetrics().toList();

    for (final metric in metrics) {
      double distance = 0;
      bool draw = true;

      while (distance < metric.length) {
        final len = draw ? dashLength : dashSpace;
        if (distance + len > metric.length) {
          dashedPath.addPath(
            metric.extractPath(distance, metric.length),
            Offset.zero,
          );
          break;
        } else {
          final extractedPath = metric.extractPath(distance, distance + len);
          if (draw) {
            dashedPath.addPath(extractedPath, Offset.zero);
          }
          distance += len;
          draw = !draw;
        }
      }
    }

    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant _ConnectionsPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

import 'package:flutter/material.dart';

/// A Floating Action Button with a pulsing animation to draw attention
class PulsingFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final String tooltip;
  final IconData icon;
  
  const PulsingFAB({
    Key? key,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.tooltip,
    required this.icon,
  }) : super(key: key);
  
  @override
  _PulsingFABState createState() => _PulsingFABState();
}

class _PulsingFABState extends State<PulsingFAB> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundColor.withOpacity(0.3),
                  blurRadius: 12 * _animation.value,
                  spreadRadius: 2 * _animation.value,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: widget.onPressed,
              backgroundColor: widget.backgroundColor,
              foregroundColor: widget.foregroundColor,
              elevation: 4,
              tooltip: widget.tooltip,
              child: Icon(widget.icon),
            ),
          ),
        );
      },
    );
  }
}

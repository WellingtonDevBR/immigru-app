import 'package:flutter/material.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_theme.dart';

/// A reusable themed card component for onboarding steps
class ThemedCard extends StatelessWidget {
  /// The child widget to display
  final Widget child;
  
  /// Whether the card is selected
  final bool isSelected;
  
  /// The callback when the card is tapped
  final VoidCallback? onTap;
  
  /// Optional margin for the card
  final EdgeInsetsGeometry margin;
  
  /// Optional padding for the card content
  final EdgeInsetsGeometry padding;
  
  /// Optional border radius for the card
  final BorderRadius borderRadius;
  
  /// Optional selected color for the card
  final Color? selectedColor;

  /// Creates a new ThemedCard
  const ThemedCard({
    super.key,
    required this.child,
    this.isSelected = false,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: margin,
      decoration: OnboardingTheme.cardDecoration(
        isSelected: isSelected,
        brightness: theme.brightness,
        borderRadius: borderRadius,
        selectedColor: selectedColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

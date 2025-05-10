import 'package:flutter/material.dart';
import 'package:immigru/presentation/widgets/feature/feature_item.dart';

/// A grid of feature items for the home screen
class FeatureGrid extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onFeatureSelected;
  final bool isTablet;
  final bool isDesktop;
  final Function(int)? onItemTap;

  const FeatureGrid({
    Key? key,
    required this.selectedIndex,
    required this.onFeatureSelected,
    this.isTablet = false,
    this.isDesktop = false,
    this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final features = ImmigrationFeatures.getFeatures(
      onTapCallbacks: List.generate(
        4,
        (index) => () => onFeatureSelected(index),
      ),
      selectedIndex: selectedIndex,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we should use a grid or list based on available width
        final useGrid = constraints.maxWidth > 600;
        
        if (useGrid) {
          return GridView.count(
            crossAxisCount: constraints.maxWidth > 900 ? 4 : 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: features,
          );
        } else {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: features.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => features[index],
          );
        }
      },
    );
  }
}

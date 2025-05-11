import 'package:flutter/material.dart';
import 'package:immigru/presentation/screens/home/widgets/feature_grid.dart';

class ImmiGrovesTab extends StatelessWidget {
  final bool isTablet;
  final bool isDesktop;
  final VoidCallback onAddDocument;

  const ImmiGrovesTab({
    super.key,
    this.isTablet = false,
    this.isDesktop = false,
    required this.onAddDocument,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My ImmiGroves',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your immigration documents and tools',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            
            // Feature grid showing immigration tools
            Expanded(
              child: FeatureGrid(
                selectedIndex: 2, // Community/ImmiGroves is selected
                onFeatureSelected: (index) {
                  // Handle feature selection
                },
                isTablet: isTablet,
                isDesktop: isDesktop,
                onItemTap: (index) {
                  if (index == 0) {
                    // Add document
                    onAddDocument();
                  }
                  // Handle other feature taps as needed
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

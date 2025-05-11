import 'package:flutter/material.dart';
import 'package:immigru/presentation/widgets/community/community_feed_item.dart';

class AllPostsTab extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final bool isTablet;
  final bool isDesktop;

  const AllPostsTab({
    super.key,
    required this.posts,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.isTablet = false,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // For desktop, show a multi-column layout
        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories sidebar (1/4 width)
              SizedBox(
                width: constraints.maxWidth * 0.25,
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryItem(context, 'All Posts', isSelected: selectedCategory == 'All Posts'),
                      _buildCategoryItem(context, 'Immigration News', isSelected: selectedCategory == 'Immigration News'),
                      _buildCategoryItem(context, 'Legal Advice', isSelected: selectedCategory == 'Legal Advice'),
                      _buildCategoryItem(context, 'Community Events', isSelected: selectedCategory == 'Community Events'),
                      _buildCategoryItem(context, 'Success Stories', isSelected: selectedCategory == 'Success Stories'),
                    ],
                  ),
                ),
              ),
              
              // Posts (3/4 width)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Show all posts without filtering
                    ...posts.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CommunityFeedItem(
                        category: item['category'],
                        userName: item['userName'],
                        timeAgo: item['timeAgo'],
                        location: item['location'],
                        content: item['content'],
                        commentCount: item['commentCount'],
                        imageUrl: item['imageUrl'],
                      ),
                    ))
                  ],
                ),
              ),
            ],
          );
        }
        
        // For mobile and tablet, show a single column layout
        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: 16,
          ),
          children: [
            // Categories horizontal list
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip(context, 'All Posts', isSelected: selectedCategory == 'All Posts'),
                  _buildCategoryChip(context, 'Immigration News', isSelected: selectedCategory == 'Immigration News'),
                  _buildCategoryChip(context, 'Legal Advice', isSelected: selectedCategory == 'Legal Advice'),
                  _buildCategoryChip(context, 'Community Events', isSelected: selectedCategory == 'Community Events'),
                  _buildCategoryChip(context, 'Success Stories', isSelected: selectedCategory == 'Success Stories'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Show all posts without filtering
            ...posts.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CommunityFeedItem(
                category: item['category'],
                userName: item['userName'],
                timeAgo: item['timeAgo'],
                location: item['location'],
                content: item['content'],
                commentCount: item['commentCount'],
                imageUrl: item['imageUrl'],
              ),
            )),
          ],
        );
      },
    );
  }
  
  Widget _buildCategoryItem(BuildContext context, String name, {bool isSelected = false}) {
    return ListTile(
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      leading: Icon(
        Icons.category_outlined,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      selected: isSelected,
      onTap: () => onCategorySelected(name),
    );
  }
  
  Widget _buildCategoryChip(BuildContext context, String name, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(name),
        selected: isSelected,
        onSelected: (selected) => onCategorySelected(name),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        checkmarkColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

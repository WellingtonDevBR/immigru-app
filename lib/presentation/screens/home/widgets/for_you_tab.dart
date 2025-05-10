import 'package:flutter/material.dart';
import 'package:immigru/domain/entities/user.dart';
import 'package:immigru/presentation/screens/home/widgets/create_post_card.dart';
import 'package:immigru/presentation/widgets/community/community_feed_item.dart';

class ForYouTab extends StatelessWidget {
  final User? user;
  final List<Map<String, dynamic>> posts;
  final Function(String, String?) onCreatePost;
  final bool isTablet;
  final bool isDesktop;

  const ForYouTab({
    Key? key,
    required this.user,
    required this.posts,
    required this.onCreatePost,
    this.isTablet = false,
    this.isDesktop = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: 16,
          ),
          children: [
            // Create post card
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CreatePostCard(
                user: user,
                onCreatePost: onCreatePost,
              ),
            ),
            const SizedBox(height: 16),
            
            // Feed items
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
            )).toList(),
          ],
        );
      },
    );
  }
}

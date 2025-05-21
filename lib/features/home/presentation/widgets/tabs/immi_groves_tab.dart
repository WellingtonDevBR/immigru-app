import 'package:flutter/material.dart';
import 'package:immigru/features/home/data/models/immi_grove_model.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';

/// "ImmiGroves" tab showing communities
class ImmiGrovesTab extends StatefulWidget {
  const ImmiGrovesTab({super.key});

  @override
  State<ImmiGrovesTab> createState() => _ImmiGrovesTabState();
}

class _ImmiGrovesTabState extends State<ImmiGrovesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<ImmiGroveModel> _filteredImmiGroves = [];
  List<ImmiGroveModel> _allImmiGroves = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchImmiGroves();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetch ImmiGroves from the API
  void _fetchImmiGroves() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call with sample data
    Future.delayed(const Duration(seconds: 1), () {
      final sampleImmiGroves = [
        ImmiGroveModel(
          id: '1',
          name: 'Newcomers to Australia',
          description: 'A community for people who recently moved to Australia',
          memberCount: 1250,
          isJoined: true,
          imageUrl: 'https://picsum.photos/id/1018/300/200',
        ),
        ImmiGroveModel(
          id: '2',
          name: 'Tech Professionals',
          description: 'For tech workers navigating immigration processes',
          memberCount: 850,
          isJoined: false,
          imageUrl: 'https://picsum.photos/id/1019/300/200',
        ),
        ImmiGroveModel(
          id: '3',
          name: 'Family Visa Support',
          description: 'Support group for family visa applicants',
          memberCount: 620,
          isJoined: false,
          imageUrl: 'https://picsum.photos/id/1020/300/200',
        ),
        ImmiGroveModel(
          id: '4',
          name: 'Student Visa Community',
          description: 'For international students and graduates',
          memberCount: 1540,
          isJoined: true,
          imageUrl: 'https://picsum.photos/id/1021/300/200',
        ),
        ImmiGroveModel(
          id: '5',
          name: 'Healthcare Professionals',
          description: 'For doctors, nurses and healthcare workers',
          memberCount: 430,
          isJoined: false,
          imageUrl: 'https://picsum.photos/id/1022/300/200',
        ),
      ];

      if (mounted) {
        setState(() {
          _allImmiGroves = sampleImmiGroves;
          _filteredImmiGroves = sampleImmiGroves;
          _isLoading = false;
        });
      }
    });
  }

  /// Handle search query changes
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterImmiGroves();
    });
  }

  /// Filter ImmiGroves based on search query
  void _filterImmiGroves() {
    if (_searchQuery.isEmpty) {
      _filteredImmiGroves = _allImmiGroves;
    } else {
      _filteredImmiGroves = _allImmiGroves.where((grove) {
        return grove.name.toLowerCase().contains(_searchQuery) ||
            (grove.description?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }
  }

  /// Toggle join/leave status for an ImmiGrove
  void _toggleJoinStatus(ImmiGroveModel grove) {
    setState(() {
      final index = _allImmiGroves.indexWhere((g) => g.id == grove.id);
      if (index != -1) {
        _allImmiGroves[index] = ImmiGroveModel(
          id: grove.id,
          name: grove.name,
          description: grove.description,
          memberCount: grove.memberCount + (grove.isJoined ? -1 : 1),
          isJoined: !grove.isJoined,
          imageUrl: grove.imageUrl,
        );
        _filterImmiGroves();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ImmiGroves...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),

        // ImmiGroves list
        Expanded(
          child: _isLoading
              ? const Center(child: LoadingIndicator())
              : _filteredImmiGroves.isEmpty
                  ? _buildEmptyState(context)
                  : RefreshIndicator(
                      onRefresh: () async {
                        _fetchImmiGroves();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _filteredImmiGroves.length,
                        itemBuilder: (context, index) {
                          final grove = _filteredImmiGroves[index];
                          return _buildImmiGroveCard(grove);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  /// Build an ImmiGrove card
  Widget _buildImmiGroveCard(ImmiGroveModel grove) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ImmiGrove image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: grove.imageUrl != null && grove.imageUrl!.isNotEmpty
                ? Image.network(
                    grove.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 120,
                    width: double.infinity,
                    color: theme.colorScheme.primary.withAlpha(50),
                    child: Icon(
                      Icons.groups,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
          ),

          // ImmiGrove details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        grove.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${grove.memberCount} members',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (grove.description != null && grove.description!.isNotEmpty) ...[  
                  const SizedBox(height: 8),
                  Text(
                    grove.description!,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // View button
                    OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to ImmiGrove details
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('View'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    // Join/Leave button
                    ElevatedButton.icon(
                      onPressed: () => _toggleJoinStatus(grove),
                      icon: Icon(grove.isJoined ? Icons.check : Icons.add),
                      label: Text(grove.isJoined ? 'Joined' : 'Join'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: grove.isJoined
                            ? Colors.green
                            : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the empty state when no ImmiGroves are found
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.shade800.withValues(alpha:0.5)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _searchQuery.isEmpty ? Icons.groups_outlined : Icons.search_off_rounded,
                size: 60,
                color: theme.colorScheme.primary.withValues(alpha:0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isEmpty ? 'No ImmiGroves Available' : 'No Results Found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isEmpty
                  ? 'There are no ImmiGroves available at the moment.'
                  : 'Try adjusting your search terms to find communities.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_searchQuery.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Clear Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

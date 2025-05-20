import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/home/domain/entities/event.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/home_event.dart';
import 'package:immigru/features/home/presentation/bloc/home_state.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/widgets/error_message_widget.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';

/// "Events" tab showing upcoming events
class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final ScrollController _scrollController = ScrollController();
  bool _showUpcomingOnly = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle scroll events for pagination
  void _onScroll() {
    if (_isBottom) {
      final homeBloc = BlocProvider.of<HomeBloc>(context);
      final currentState = homeBloc.state;

      if (currentState is EventsLoaded && !currentState.hasReachedMax) {
        homeBloc.add(FetchMoreEvents(upcoming: _showUpcomingOnly));
      }
    }
  }

  /// Check if the user has scrolled to the bottom
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Handle different states
        if (state is EventsLoading) {
          return _buildLoadingState(state);
        } else if (state is EventsLoaded) {
          return _buildLoadedState(state);
        } else if (state is EventsError) {
          return ErrorMessageWidget(
            message: state.message,
            onRetry: () {
              BlocProvider.of<HomeBloc>(context).add(
                FetchEvents(upcoming: _showUpcomingOnly, refresh: true),
              );
            },
          );
        }

        // Initial state or other states
        return _buildLoadingState(null);
      },
    );
  }

  /// Build the loading state
  Widget _buildLoadingState(EventsLoading? state) {
    if (state != null && state.currentEvents != null && state.currentEvents!.isNotEmpty) {
      // Show current events with loading indicator at bottom
      return Column(
        children: [
          _buildFilterToggle(),
          Expanded(
            child: _buildEventsList(
              state.currentEvents!,
              showBottomLoader: true,
              hasReachedMax: false,
            ),
          ),
        ],
      );
    }

    // Show full loading indicator
    return Column(
      children: [
        _buildFilterToggle(),
        const Expanded(
          child: Center(
            child: LoadingIndicator(),
          ),
        ),
      ],
    );
  }

  /// Build the loaded state with events
  Widget _buildLoadedState(EventsLoaded state) {
    return Column(
      children: [
        _buildFilterToggle(),
        Expanded(
          child: state.events.isEmpty
              ? _buildEmptyState()
              : _buildEventsList(
                  state.events,
                  showBottomLoader: !state.hasReachedMax,
                  hasReachedMax: state.hasReachedMax,
                ),
        ),
      ],
    );
  }

  /// Build the filter toggle for upcoming/all events
  Widget _buildFilterToggle() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Events',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const Text('Show upcoming only'),
          const SizedBox(width: 8),
          Switch(
            value: _showUpcomingOnly,
            onChanged: (value) {
              setState(() {
                _showUpcomingOnly = value;
              });
              
              BlocProvider.of<HomeBloc>(context).add(
                FetchEvents(upcoming: value, refresh: true),
              );
            },
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  /// Build the list of events
  Widget _buildEventsList(
    List<Event> events, {
    bool showBottomLoader = false,
    required bool hasReachedMax,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        BlocProvider.of<HomeBloc>(context).add(
          FetchEvents(upcoming: _showUpcomingOnly, refresh: true),
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: events.length + (showBottomLoader ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= events.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: LoadingIndicator(size: 24),
              ),
            );
          }

          final event = events[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  /// Build an event card
  Widget _buildEventCard(Event event) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Format date and time
    final dateFormat = DateFormat('E, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final formattedDate = dateFormat.format(event.eventDate);
    final formattedTime = timeFormat.format(event.eventDate);
    
    // Check if event is today
    final now = DateTime.now();
    final isToday = event.eventDate.year == now.year &&
        event.eventDate.month == now.month &&
        event.eventDate.day == now.day;
    
    // Check if event is upcoming
    final isUpcoming = event.eventDate.isAfter(now);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event header with date badge
          Stack(
            children: [
              // Event image or placeholder
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: event.imageUrl != null
                    ? Image.network(
                        event.imageUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 120,
                        width: double.infinity,
                        color: theme.colorScheme.primary.withValues(alpha:0.2),
                        child: Icon(
                          event.icon,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                      ),
              ),
              
              // Date badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.green
                        : isUpcoming
                            ? theme.colorScheme.primary
                            : Colors.grey,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    isToday ? 'Today' : formattedDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Event details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  event.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Time and location
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                // Description (if available)
                if (event.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    event.description!,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Details button
                    OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to event details
                      },
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    
                    // Register button
                    ElevatedButton.icon(
                      onPressed: isUpcoming ? () {
                        // Register for event
                      } : null,
                      icon: Icon(event.isRegistered ? Icons.check : Icons.calendar_today),
                      label: Text(event.isRegistered ? 'Registered' : 'Register'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: event.isRegistered
                            ? Colors.green
                            : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
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

  /// Build the empty state when no events are available
  Widget _buildEmptyState() {
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
                Icons.event_busy,
                size: 60,
                color: theme.colorScheme.primary.withValues(alpha:0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _showUpcomingOnly ? 'No Upcoming Events' : 'No Events Found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _showUpcomingOnly
                  ? 'There are no upcoming events scheduled at the moment.'
                  : 'There are no events available at the moment.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_showUpcomingOnly)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showUpcomingOnly = false;
                  });
                  
                  BlocProvider.of<HomeBloc>(context).add(
                    const FetchEvents(upcoming: false, refresh: true),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('View Past Events'),
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

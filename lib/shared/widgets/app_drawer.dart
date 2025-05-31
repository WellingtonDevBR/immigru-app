import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/core/storage/i_supabase_storage.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/theme/theme_provider.dart';
import 'package:immigru/features/auth/domain/entities/user.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_event.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:immigru/features/profile/presentation/bloc/profile_event.dart';
import 'package:immigru/features/profile/presentation/screens/profile_screen.dart';
import 'package:provider/provider.dart';

/// App drawer widget that provides navigation to different sections of the app
class AppDrawer extends StatelessWidget {
  /// Helper method to get the appropriate image provider for a user avatar
  /// Returns an AssetImage as fallback when URL is invalid
  ImageProvider? _getAvatarImage(String? url, {String? userName}) {
    if (url == null || url.isEmpty) return null;
    
    // Use the provided userName or default to 'User'
    final displayName = userName ?? 'User';
    
    // Get the processed URL from SupabaseStorageUtils
    final processedUrl = GetIt.instance<ISupabaseStorage>().getImageUrl(
      url,
      displayName: displayName,
    );
    
    // Check if it's an asset path
    if (processedUrl.startsWith('assets/')) {
      return AssetImage(processedUrl);
    }
    
    // Otherwise treat as network image
    return NetworkImage(processedUrl);
  }
  /// Constructor
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final User? currentUser = state.user;
          
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // Drawer header with user profile info
              _buildDrawerHeader(context, currentUser),
              
              // Home
              _buildDrawerItem(
                context,
                icon: Icons.home_outlined,
                title: 'Home',
                onTap: () {
                  Navigator.pop(context);
                  // If we're already on the home screen, don't navigate
                  if (ModalRoute.of(context)?.settings.name != '/home') {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ),
              
              // Profile
              if (currentUser != null)
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider<ProfileBloc>(
                          create: (_) {
                            final bloc = GetIt.instance<ProfileBloc>();
                            // Initialize the profile data immediately
                            bloc.add(LoadUserProfile(userId: currentUser.id));
                            return bloc;
                          },
                          child: ProfileScreen(
                            userId: currentUser.id,
                            isCurrentUser: true,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              
              // Explore
              _buildDrawerItem(
                context,
                icon: Icons.explore_outlined,
                title: 'Explore',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to explore screen
                },
              ),
              
              // Messages
              if (currentUser != null)
                _buildDrawerItem(
                  context,
                  icon: Icons.message_outlined,
                  title: 'Messages',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to messages screen
                  },
                ),
              
              // Divider
              const Divider(),
              
              // Settings
              _buildDrawerItem(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to settings screen
                },
              ),
              
              // Dark/Light mode toggle
              _buildThemeToggle(context),
              
              // Help & Support
              _buildDrawerItem(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to help screen
                },
              ),
              
              // About
              _buildDrawerItem(
                context,
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to about screen
                },
              ),
              
              // Sign out (only if user is logged in)
              if (currentUser != null)
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Sign Out',
                  onTap: () {
                    Navigator.pop(context);
                    // Show confirmation dialog before signing out
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Dispatch sign out event to the AuthBloc
                              context.read<AuthBloc>().add(AuthSignOutEvent());
                              // Navigate to the login screen after signing out
                              Navigator.pushNamedAndRemoveUntil(
                                context, 
                                '/login', 
                                (route) => false,
                              );
                            },
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              
              // Sign in (only if user is not logged in)
              if (currentUser == null)
                _buildDrawerItem(
                  context,
                  icon: Icons.login,
                  title: 'Sign In',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  /// Build the drawer header with user profile info
  Widget _buildDrawerHeader(BuildContext context, User? currentUser) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
      ),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: currentUser != null
            ? () {
                Navigator.pop(context);
                // Create a ProfileBloc and wrap the ProfileScreen with it
                final profileBloc = GetIt.instance<ProfileBloc>();
                
                // Load the user profile data
                profileBloc.add(LoadUserProfile(userId: currentUser.id));
                
                // Navigate to the profile screen with the bloc provider
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider<ProfileBloc>.value(
                      value: profileBloc,
                      child: ProfileScreen(
                        userId: currentUser.id,
                        isCurrentUser: true,
                      ),
                    ),
                  ),
                );
              }
            : () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // User avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: currentUser?.photoUrl != null ? 
                    _getAvatarImage(
                      currentUser!.photoUrl,
                      userName: currentUser.displayName ?? currentUser.email,
                    ) : null,
                child: currentUser?.photoUrl == null
                    ? Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white.withValues(alpha: 0.8),
                      )
                    : null,
              ),
              
              const SizedBox(height: 12),
              
              // User name
              Text(
                currentUser?.displayName ?? 'Guest User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // User email or sign in prompt
              Text(
                currentUser != null
                    ? currentUser.email ?? currentUser.phone ?? ''
                    : 'Tap here to sign in',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a drawer item with icon, title, and onTap callback
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
  
  /// Build a theme toggle switch for dark/light mode
  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return ListTile(
      leading: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
      ),
      title: const Text('Dark Mode'),
      trailing: Switch(
        value: isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme();
        },
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      onTap: () {
        themeProvider.toggleTheme();
      },
    );
  }
}

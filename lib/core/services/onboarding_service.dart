import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _hasSeenWelcomeScreenKey = 'has_seen_welcome_screen';
  
  /// Checks if the user has seen the welcome screen before
  Future<bool> hasSeenWelcomeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenWelcomeScreenKey) ?? false;
  }
  
  /// Marks the welcome screen as seen
  Future<void> markWelcomeScreenAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenWelcomeScreenKey, true);
  }
  
  /// Resets the welcome screen status (for testing purposes)
  Future<void> resetWelcomeScreenStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenWelcomeScreenKey, false);
  }
}

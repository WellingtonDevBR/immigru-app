import 'package:get_it/get_it.dart';
import 'package:immigru/features/auth/di/auth_module.dart';
import 'package:immigru/features/home/di/comment_module.dart';
import 'package:immigru/features/home/di/event_module.dart';
import 'package:immigru/features/home/di/home_module.dart';
import 'package:immigru/features/home/di/immi_grove_module.dart';
import 'package:immigru/features/home/di/post_module.dart';
import 'package:immigru/features/onboarding/di/onboarding_module.dart';
import 'package:immigru/features/profile/di/profile_module.dart';
import 'package:immigru/features/welcome/di/welcome_module.dart';

/// Feature module for dependency injection
/// Registers all feature-specific dependencies
class FeatureModule {
  /// Register all feature modules
  static Future<void> registerAll(GetIt sl) async {
    // Register welcome feature
    await WelcomeModule.register(sl);
    
    // Register auth feature
    await AuthModule.register(sl);
    
    // Register onboarding feature
    await OnboardingModule.register(sl);
    
    // Register post feature first (since HomeModule depends on it)
    PostModule.register(sl);
    
    // Register comment feature
    CommentModule.init(sl);
    
    // Register event feature
    EventModule.register(sl);
    
    // Register ImmiGrove feature
    ImmiGroveModule.register(sl);
    
    // Register home feature
    HomeModule.init(sl);
    
    // Register profile feature
    registerProfileDependencies(sl);
  }
}

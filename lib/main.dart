import 'package:flutter/material.dart';
import 'package:immigru/app.dart';
import 'package:immigru/core/di/injection_container.dart' as di;
import 'package:immigru/core/services/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logger
  final logger = LoggerService();
  logger.info('App', 'Starting Immigru application');
  
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://kkdhnvapcbwwqapsnnfg.supabase.co'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrZGhudmFwY2J3d3FhcHNubmZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM5OTkzMTAsImV4cCI6MjA1OTU3NTMxMH0._Xf1x7dSkdVYP1HcV6yZSsyyq6xT_xkrjJgdzg9z-yM'),
      debug: true,
    );
    
    logger.info('App', 'Supabase initialized successfully');
    
    // Initialize dependency injection
    await di.init();
    logger.info('App', 'Dependency injection initialized successfully');
  } catch (e, stackTrace) {
    logger.error('App', 'Failed to initialize app', error: e, stackTrace: stackTrace);
  }
  
  runApp(const ImmigruApp());
}
// Main app implementation is now in app.dart

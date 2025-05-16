import 'package:flutter/material.dart';
import 'package:immigru/app.dart' as old_app;
import 'package:immigru/app_new.dart' as new_app;
import 'package:immigru/core/di/injection_container.dart' as di;
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/new_core/di/service_locator.dart' as new_di;
import 'package:supabase_flutter/supabase_flutter.dart';

const bool useNewArchitecture = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final logger = LoggerService();
  logger.info('App', 'Starting Immigru application');
  
  try {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://kkdhnvapcbwwqapsnnfg.supabase.co'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrZGhudmFwY2J3d3FhcHNubmZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM5OTkzMTAsImV4cCI6MjA1OTU3NTMxMH0._Xf1x7dSkdVYP1HcV6yZSsyyq6xT_xkrjJgdzg9z-yM'),
      debug: true,
    );
    
    logger.info('App', 'Supabase initialized successfully');
    
    if (useNewArchitecture) {
      await new_di.ServiceLocator.init();
      logger.info('App', 'New architecture DI initialized successfully');
      
      runApp(const new_app.ImmigruApp());
    } else {
      await di.init();
      logger.info('App', 'Old architecture DI initialized successfully');
      
      runApp(const old_app.ImmigruApp());
    }
  } catch (e, stackTrace) {
    logger.error('App', 'Failed to initialize app', error: e, stackTrace: stackTrace);
    if (useNewArchitecture) {
      try {
        await di.init();
        runApp(const old_app.ImmigruApp());
      } catch (e) {
        runApp(MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Failed to initialize app: ${e.toString()}'),
            ),
          ),
        ));
      }
    }
  }
}

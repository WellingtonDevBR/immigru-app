import 'package:flutter/material.dart';
import 'package:immigru/app.dart';
import 'package:immigru/new_core/di/service_locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const bool useNewArchitecture = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL',
          defaultValue: 'https://kkdhnvapcbwwqapsnnfg.supabase.co'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
          defaultValue:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrZGhudmFwY2J3d3FhcHNubmZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM5OTkzMTAsImV4cCI6MjA1OTU3NTMxMH0._Xf1x7dSkdVYP1HcV6yZSsyyq6xT_xkrjJgdzg9z-yM'),
      debug: true,
    );

    // Initialize the service locator
    await ServiceLocator.init();

    runApp(const ImmigruApp());
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

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A utility class for debugging authentication issues
class AuthDebugHelper {


  /// Check if Google Play Services is available
  static Future<bool> isGooglePlayServicesAvailable() async {
    try {
      // Simple check to see if Google Sign-In is available
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signInSilently();
      return true;
    } catch (e) {
      if (e.toString().contains('sign_in_required')) {
        // This is normal if not signed in yet
        return true;
      } else {

        return false;
      }
    }
  }

  /// Debug Google Sign-In process
  static Future<void> debugGoogleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );
      
      // Check if signed in already

      final isSignedIn = await googleSignIn.isSignedIn();
      if (!isSignedIn) {

      } else {

        final account = await googleSignIn.signInSilently();
        if (account != null) {

        }
      }
      
      // Check Google Play Services

      try {
        // Simple check to see if Google Sign-In is available
        await googleSignIn.signInSilently();

      } catch (e) {
        if (e.toString().contains('sign_in_required')) {
          // This is normal if not signed in yet

        } else {

        }
      }
    } catch (e) {

    }
  }
  
  /// Debug API exception
  static void debugApiException(dynamic exception) {

    
    if (exception.toString().contains('ApiException: 10')) {
    }
  }
  
  /// Log network request
  static void logRequest(String method, String url, {dynamic data}) {
    if (kDebugMode) {

      if (data != null) {

      }
    }
  }
  
  /// Log network response
  static void logResponse(String method, String url, dynamic response, {int? statusCode}) {
    if (kDebugMode) {



    }
  }
  
  /// Log network error
  static void logError(String method, String url, dynamic error) {
    if (kDebugMode) {


    }
  }
}

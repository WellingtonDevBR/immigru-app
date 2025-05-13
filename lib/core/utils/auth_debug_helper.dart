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
      print('''
⚠️ GOOGLE SIGN-IN ERROR CODE 10: Developer Error
This typically means one of the following:
1. SHA-1 fingerprint in Firebase console doesn't match your app's signing certificate
2. Package name in Google Cloud Console doesn't match your app's package name
3. OAuth client ID is incorrect or missing
4. Google Play Services is not installed or outdated on the device

RECOMMENDED ACTIONS:
1. Verify SHA-1 fingerprint in Firebase console
2. Check package name in Google Cloud Console
3. Ensure OAuth client ID is correctly configured
4. Update Google Play Services on the device
''');
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

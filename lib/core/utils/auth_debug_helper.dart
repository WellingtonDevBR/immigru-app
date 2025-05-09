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
        print('❌ Google Play Services check failed: $e');
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
      print('🔍 Checking Google Sign-In status...');
      final isSignedIn = await googleSignIn.isSignedIn();
      if (!isSignedIn) {
        print('⚠️ Not signed in with any Google account');
      } else {
        print('✅ Already signed in with Google');
        final account = await googleSignIn.signInSilently();
        if (account != null) {
          print('   - ${account.displayName} (${account.email})');
        }
      }
      
      // Check if already signed in
      final alreadySignedIn = await googleSignIn.isSignedIn();
      print('🔐 Is already signed in with Google: $alreadySignedIn');
      
      // Check Google Play Services
      print('🔍 Checking Google Play Services availability...');
      try {
        // Simple check to see if Google Sign-In is available
        await googleSignIn.signInSilently();
        print('✅ Google Play Services appears to be available');
      } catch (e) {
        if (e.toString().contains('sign_in_required')) {
          // This is normal if not signed in yet
          print('✅ Google Play Services appears to be available (not signed in)');
        } else {
          print('❌ Google Play Services check failed: $e');
        }
      }
    } catch (e) {
      print('❌ Google Sign-In debug failed: $e');
    }
  }
  
  /// Debug API exception
  static void debugApiException(dynamic exception) {
    print('❌ API EXCEPTION: $exception');
    
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
      print('📤 $method REQUEST: $url');
      if (data != null) {
        print('📦 REQUEST DATA: $data');
      }
    }
  }
  
  /// Log network response
  static void logResponse(String method, String url, dynamic response, {int? statusCode}) {
    if (kDebugMode) {
      print('📥 $method RESPONSE: $url');
      print('🔢 STATUS CODE: $statusCode');
      print('📦 RESPONSE DATA: $response');
    }
  }
  
  /// Log network error
  static void logError(String method, String url, dynamic error) {
    if (kDebugMode) {
      print('❌ $method ERROR: $url');
      print('❌ ERROR DETAILS: $error');
    }
  }
}

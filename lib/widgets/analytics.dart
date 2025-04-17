
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters:
            parameters?.map((key, value) => MapEntry(key, value as Object)),
      );
    } catch (e) {
      print("Error logging event: $e");
    }
  }
 static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? 'Unknown',
      );
    } catch (e) {
      print("Error logging screen view: $e");
    }
  }


  static void logFirebaseAuthEvent(User? user, String method) {
    if (user == null) return; 

 
    final isSignUp = user.metadata.creationTime?.isAtSameMomentAs(
            user.metadata.lastSignInTime ?? DateTime.now()) ??
        false;

   
    final authEvent = isSignUp ? 'sign_up' : 'login';
  print('kkkkkkk$authEvent');
    print('ooo${user.uid}');

  
    AnalyticsService.logEvent(
      eventName: authEvent,
      parameters: {'method': method, 'user_id': user.uid},
    );
  }
}

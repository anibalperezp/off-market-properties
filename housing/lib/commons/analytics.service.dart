import 'package:firebase_analytics/firebase_analytics.dart';

class AnalitysService {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static final AnalitysService _instance = AnalitysService._internal();

  factory AnalitysService() {
    return _instance;
  }

  AnalitysService._internal();

  observerAnalytics() {
    return observer;
  }

  Future<void> sendAnalyticsEvent(String event,
      [Map<String, dynamic>? parameters]) async {
    await analytics.logEvent(name: event, parameters: parameters);
  }

  Future<void> setCurrentScreen(String screenName, String screenClass) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'firebase_screen': screenName,
        'firebase_screen_class': screenClass,
      },
    );
  }

  Future<void> logCustomEvent(String buttonName, String screenName) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'button_pressed',
      parameters: <String, dynamic>{
        'button_name': buttonName,
        'screen_name': screenName,
      },
    );
  }
}

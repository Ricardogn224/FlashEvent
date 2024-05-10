import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/events_screen.dart';
import 'screens/event_details_screen.dart';
import 'screens/splash_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/login':
      return MaterialPageRoute(builder: (_) => LoginScreen());
    case '/register':
      return MaterialPageRoute(builder: (_) => RegisterScreen());
    case '/event':
      return MaterialPageRoute(builder: (_) => EventsScreen());
    case '/event_details':
      return MaterialPageRoute(builder: (_) => EventDetailsScreen());
    default:
      return MaterialPageRoute(builder: (_) => SplashScreen());
  }
}

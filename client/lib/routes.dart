import 'package:flutter/material.dart';
import 'package:flutter_flash_event/screens/invitation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/events_screen.dart';
import 'screens/event_details_screen.dart';
import 'screens/event_new_screen.dart';
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
    case '/event_new':
      return MaterialPageRoute(builder: (_) => EventNewScreen());
    case '/invitations':
      return MaterialPageRoute(builder: (_) => InvitationScreen());
    default:
      return MaterialPageRoute(builder: (_) => SplashScreen());
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_flash_event/screens/invitation_screen.dart';
import 'package:flutter_flash_event/screens/item_event_new_screen.dart';
import 'package:flutter_flash_event/screens/items_event_screen.dart';
import 'package:flutter_flash_event/screens/my_account_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/events_screen.dart';
import 'screens/event_details_screen.dart';
import 'screens/event_new_screen.dart';
import 'screens/event_participants_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/admin_home_desktop_screen.dart';

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
    case '/event_participants':
      return MaterialPageRoute(builder: (_) => EventParticipantsScreen());
    case '/event_new':
      return MaterialPageRoute(builder: (_) => EventNewScreen());
    case '/invitations':
      return MaterialPageRoute(builder: (_) => InvitationScreen());
    case '/admin':
      return MaterialPageRoute(builder: (_) => AdminHomeDesktop());
    case '/manage-users':
      return MaterialPageRoute(builder: (_) => ManageUsersScreen());
    case '/item-event':
      return MaterialPageRoute(builder: (_) => ItemsEventScreen());
    case '/item-new':
      return MaterialPageRoute(builder: (_) => ItemNewScreen());
    case '/manage-events':
      return MaterialPageRoute(builder: (_) => ManageEventsScreen());
    case '/my-account':
      return MaterialPageRoute(builder: (_) => MyAccountScreen());
    default:
      return MaterialPageRoute(builder: (_) => SplashScreen());
  }
}

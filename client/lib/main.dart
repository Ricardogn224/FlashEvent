import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/events_screen.dart';
import 'screens/event_details_screen.dart';
// import 'screens/event_messages_screen.dart';
// import 'screens/event_participants_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flash Event',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => RegisterScreen());
          case '/event':
            return MaterialPageRoute(builder: (_) => EventsScreen());
          case '/event_details':
            return MaterialPageRoute(builder: (_) => EventDetailsScreen());
          // case '/event_messages':
          //   return MaterialPageRoute(builder: (_) => EventMessagesScreen());
          // case '/event_participants':
          //   return MaterialPageRoute(builder: (_) => EventParticipantsScreen());
          default:
            return MaterialPageRoute(builder: (_) => SplashScreen());
        }
      },
    );
  }
}

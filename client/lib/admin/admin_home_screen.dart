import 'package:flutter/material.dart';
import 'package:flutter_flash_event/admin/admin_event_screen.dart';
import 'package:flutter_flash_event/admin/admin_feature_screen.dart';
import 'package:flutter_flash_event/admin/admin_user_screen.dart';
import 'package:flutter_flash_event/widgets/admin_button.dart';

import '../login/login_screen.dart';
import '../widgets/main_screen.dart';

class AdminHomeDesktop extends StatelessWidget {
  static const String routeName = '/admin';

  const AdminHomeDesktop();

  static navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Interface admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Interface'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AdminButton(
                title: 'Gestion des utilisateurs',
                onPressed: () {
                  // Navigate to Manage Users screen
                  AdminUserScreen.navigateTo(context);
                },
              ),
              const SizedBox(height: 20),
              AdminButton(
                title: 'Gestion des évènements',
                onPressed: () {
                  // Navigate to Manage Events screen
                  AdminEventScreen.navigateTo(context);
                },
              ),
              const SizedBox(height: 20),
              AdminButton(
                title: 'Fonctionnalités',
                onPressed: () {
                  // Navigate to Manage Features screen
                  AdminFeatureScreen.navigateTo(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add this to handle the named route with userRole
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: MainScreen.routeName,
      routes: {
        MainScreen.routeName: (context) => MainScreen(userRole: 'User'), // Default user role for testing
        LoginScreen.routeName: (context) => LoginScreen(),
        AdminHomeDesktop.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return AdminHomeDesktop();
        },
        // Add other routes as necessary
      },
    );
  }
}

void main() {
  runApp(MyApp());
}

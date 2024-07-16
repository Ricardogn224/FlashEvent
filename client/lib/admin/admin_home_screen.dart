import 'package:flutter/material.dart';
import 'package:flutter_flash_event/admin/admin_event_screen.dart';
import 'package:flutter_flash_event/admin/admin_feature_screen.dart';
import 'package:flutter_flash_event/admin/admin_user_screen.dart';
import 'package:flutter_flash_event/widgets/admin_button.dart';

class AdminHomeDesktop extends StatelessWidget {

  static const String routeName = '/admin';

  static navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const AdminHomeDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interface admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('admin Interface'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AdminButton(
                title: 'Gestion des utlisateurs',
                onPressed: () {
                  // Navigate to Manage Users screen
                  AdminUserScreen.navigateTo(context);
                },
              ),
              SizedBox(height: 20),
              AdminButton(
                title: 'Gestion des évènements',
                onPressed: () {
                  // Navigate to Manage Events screen
                  AdminEventScreen.navigateTo(context);
                },
              ),
              SizedBox(height: 20),
              AdminButton(
                title: 'Fonctionnalités',
                onPressed: () {
                  // Navigate to Manage Events screen
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
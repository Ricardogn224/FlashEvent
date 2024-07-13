import 'package:flutter/material.dart';
import 'package:flutter_flash_event/widgets/admin_button.dart';

/*class AdminHomeDesktop extends StatelessWidget {
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
                  Navigator.pushNamed(context, '/manage-users');
                },
              ),
              SizedBox(height: 20),
              AdminButton(
                title: 'Gestion des évènements',
                onPressed: () {
                  // Navigate to Manage Events screen
                  Navigator.pushNamed(context, '/manage-events');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManageUsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
      ),
      body: Center(
        child: Text('User Management Screen'),
      ),
    );
  }
}

class ManageEventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Events'),
      ),
      body: Center(
        child: Text('Event Management Screen'),
      ),
    );
  }
}*/
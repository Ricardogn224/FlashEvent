import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  static const String routeName = '/notifications';

  static navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text('N$index'),
            ),
            title: Text('Notification $index'),
            subtitle: Text('Subtitle $index'),
          );
        },
      ),
    );
  }
}

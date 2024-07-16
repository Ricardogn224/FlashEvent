import 'package:flutter/material.dart';

class ConnectionsScreen extends StatelessWidget {
  static const String routeName = '/connections';

  static navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text('C$index'),
            ),
            title: Text('Connection $index'),
            subtitle: Text('Subtitle $index'),
          );
        },
      ),
    );
  }
}

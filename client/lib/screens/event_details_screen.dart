import 'package:flutter/material.dart';

class EventDetailsScreen extends StatelessWidget {

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const EventDetailsScreen();
      },
    ));
  }

  const EventDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détail Événement'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Présentation événement'),
            subtitle: Text('Description brève de l\'événement.'),
          ),
          ListTile(
            title: Text('Liste des participants'),
            trailing: Icon(Icons.people),
            onTap: () {
              // Naviguer vers la liste des participants
            },
          ),
          ListTile(
            title: Text('Liste des choses à ramener'),
            trailing: Icon(Icons.add),
            onTap: () {
              // Naviguer vers la liste des choses à ramener
            },
          ),
          ListTile(
            title: Text('Messagerie'),
            trailing: Icon(Icons.message),
            onTap: () {
              // Naviguer vers la messagerie de l'événement
            },
          ),
        ],
      ),
    );
  }
}

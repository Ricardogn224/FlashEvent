import 'package:flutter/material.dart';
import 'package:flutter_flash_event/screens/items_event_screen.dart';

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
              Navigator.pushNamed(context, '/event_participants');
            },
          ),
          ListTile(
            title: Text('Liste des choses à ramener'),
            trailing: Icon(Icons.add),
            onTap: () {
              // Navigate to EventItemsScreen when tapped
              Navigator.pushNamed(context, '/item-event');
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

import 'package:flutter/material.dart';
import 'package:flutter_flash_event/widgets/event_row.dart';
import 'event_details_screen.dart';


class EventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Événements'),
        centerTitle: true,
      ),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(8.0),
        child: Scrollbar(child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un événement',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            EventRow(icon: Icon(Icons.arrow_right), text: "Evenement 1", onPressed: () {Navigator.of(context).pushNamed('/event_details');}, border: Colors.black),
            ],
          ),
        )),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action pour ajouter un nouvel événement
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_flash_event/widgets/event_row.dart';
import 'package:flutter_flash_event/core/services/api_services.dart';
import 'event_details_screen.dart';

class EventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Événements'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
              SizedBox(height: 20), // Add spacing between search bar and events
              Expanded(
                child: FutureBuilder(
                  future: ApiServices.getEvents(),
                  builder: (context, snapshot) {
                    final loading = snapshot.connectionState == ConnectionState.waiting;
                    if (loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          snapshot.error.toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final events = snapshot.data!.take(10).toList(); // Limit to the first 10 items

                    return ListView(
                      children: events.map((event) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EventRow(
                              icon: Icon(Icons.chevron_right),
                              text: event.title,
                              onPressed: () {
                                // Navigate to the add event screen
                                Navigator.pushNamed(context, '/event_new');
                              },
                              border: Colors.black,
                            ),
                            SizedBox(height: 20), // Add spacing between EventRows
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the add event screen
          Navigator.pushNamed(context, '/event_new');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

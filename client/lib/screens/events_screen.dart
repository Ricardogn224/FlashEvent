import 'package:flutter/material.dart';
import 'package:flutter_flash_event/widgets/event_row.dart';
import 'package:flutter_flash_event/core/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'event_details_screen.dart';


class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Événements'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to the account screen
              Navigator.pushNamed(context, '/my-account');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    _email ?? '',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0), // Add bottom padding
                child: GestureDetector(
                  onTap: () {
                    // Navigate to the add event screen
                    Navigator.pushNamed(context, '/invitations');
                  },
                  child: Text(
                    "Voir mes invitations",
                    style: TextStyle(
                      color: Colors.blue, // Set text color to blue for link
                      decoration: TextDecoration.underline, // Add underline for link
                      fontSize: 18, // Set the font size
                    ),
                  ),
                ),
              ),
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
                              text: event.name,
                              onPressed: () {
                                // Navigate to the add event screen
                                Navigator.pushNamed(context, '/event_details', arguments: event.id);
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

import 'package:flutter/material.dart';
import 'package:flutter_flash_event/core/services/item_services.dart';

import '../core/services/api_services.dart';

class ItemsEventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Implement the UI to display the items of the event
    return Scaffold(
      appBar: AppBar(
        title: Text('Utilitaires'),
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
              SizedBox(height: 20), // Add spacing between search bar and events
              Expanded(
                child: FutureBuilder(
                  future: ItemServices.getItems(),
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

                    final items = snapshot.data!.take(10).toList(); // Limit to the first 10 items

                    return ListView(
                      children: items.map((item) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 20), // Add spacing between items
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
          Navigator.pushNamed(context, '/item-new');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
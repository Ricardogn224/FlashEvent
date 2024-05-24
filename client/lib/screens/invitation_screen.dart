import 'package:flutter/material.dart';
import 'package:flutter_flash_event/widgets/event_row.dart';
import 'package:flutter_flash_event/core/services/api_services.dart';
import 'event_details_screen.dart';

class Invitation {
  final String title;

  Invitation({required this.title});
}


List<Invitation> fakeInvitations = [
  Invitation(title: 'Invitation 1'),
  Invitation(title: 'Invitation 2'),
  Invitation(title: 'Invitation 3'),
  // Add more fake invitations as needed
];

class InvitationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60.0, left: 16.0, right: 16.0), // Adjust padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Center the content horizontally
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate back to the previous screen
                    Navigator.pop(context);
                  },
                  child: Text('Back'),
                ),
                SizedBox(width: 38), // Add spacing between the "Back" button and the "New Event" title
                Text(
                  'Mes invitations',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: fakeInvitations.length,
              itemBuilder: (context, index) {
                final invitation = fakeInvitations[index];
                return ListTile(
                  title: Text(invitation.title),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle accept button press
                        },
                        icon: Icon(Icons.check),
                        label: Text('Accept'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle refuse button press
                        },
                        icon: Icon(Icons.close),
                        label: Text('Refuse'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



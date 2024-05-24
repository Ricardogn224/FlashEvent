import 'package:flutter/material.dart';

class EventNewScreen extends StatelessWidget {
  const EventNewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Event'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to the previous screen
                    Navigator.pop(context);
                  },
                  child: Text('Back'),
                ),
              ),
              SizedBox(width: 8), // Add spacing between the "Back" button and the "New Event" title
              Text(
                'New Event',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter Event Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add your form submission logic here
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



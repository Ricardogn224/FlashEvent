import 'package:flutter/material.dart';

class EventParticipantsScreen extends StatefulWidget {
  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const EventParticipantsScreen();
      },
    ));
  }

  const EventParticipantsScreen({super.key});

  @override
  _EventParticipantsScreenState createState() => _EventParticipantsScreenState();
}

class _EventParticipantsScreenState extends State<EventParticipantsScreen> {
  List<Map<String, String>> participants = [
    {'name': 'Participant 1', 'email': 'participant1@example.com'},
    {'name': 'Participant 2', 'email': 'participant2@example.com'},
    {'name': 'Participant 3', 'email': 'participant3@example.com'},
  ];

  void _addParticipant(String name, String email) {
    setState(() {
      participants.add({'name': name, 'email': email});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Participants'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: participants.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.person),
            title: Text(participants[index]['name']!),
            subtitle: Text('Email: ${participants[index]['email']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newParticipant = await Navigator.of(context).push<Map<String, String>>(
            MaterialPageRoute(
              builder: (context) => AddParticipantScreen(),
            ),
          );

          if (newParticipant != null) {
            _addParticipant(newParticipant['name']!, newParticipant['email']!);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddParticipantScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Participant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop({
                      'name': _nameController.text,
                      'email': _emailController.text,
                    });
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

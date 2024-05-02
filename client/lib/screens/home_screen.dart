import 'package:flutter/material.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event manager'),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate to the Events page
            },
            child: Text(
              'Events',
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to the Messages page
            },
            child: Text(
              'Messages',
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to the LoginPage when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text('Login'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Organisez et gérer vos évènements en toute simplicité', // Welcoming text in the principal content section
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
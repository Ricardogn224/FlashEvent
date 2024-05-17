import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[200], // Background color of the page
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Inscription',
                style: TextStyle(
                  fontSize: 24, // Font size resembling an H1 heading
                  fontWeight: FontWeight.bold, // Bold font weight
                ),
              ),
              SizedBox(height: 30),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  labelText: 'Email',
                  fillColor: Colors.white, // Text field background color
                  filled: true,
                  border: OutlineInputBorder(), // Text field border
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter your first name',
                  labelText: 'First Name',
                  fillColor: Colors.white, // Text field background color
                  filled: true,
                  border: OutlineInputBorder(), // Text field border
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter your last name',
                  labelText: 'Last Name',
                  fillColor: Colors.white, // Text field background color
                  filled: true,
                  border: OutlineInputBorder(), // Text field border
                ),
              ),
              SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  labelText: 'Password',
                  fillColor: Colors.white, // Text field background color
                  filled: true,
                  border: OutlineInputBorder(), // Text field border
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle registration button press
                },
                child: Text('Register'),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to the registration page when the text is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  'Already registered? Click here',
                  style: TextStyle(
                    color: Colors.blue, // Text color of the clickable text
                    decoration: TextDecoration.underline, // Underline the text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
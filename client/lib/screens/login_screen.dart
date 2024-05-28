import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flash_event/core/services/auth_services.dart';
import 'events_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String email = _emailController.text;
      String password = _passwordController.text;

      try {
        final response = await AuthServices.loginUser(email, password);
        if (response.statusCode == 200) {
          // Store username in session
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', email);

          // Navigate to events screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EventsScreen()),
          );
        } else {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[200], // Background color of the page
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize: 24, // Font size resembling an H1 heading
                    fontWeight: FontWeight.bold, // Bold font weight
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    labelText: 'Email',
                    fillColor: Colors.white, // Text field background color
                    filled: true,
                    border: OutlineInputBorder(), // Text field border
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    labelText: 'Password',
                    fillColor: Colors.white, // Text field background color
                    filled: true,
                    border: OutlineInputBorder(), // Text field border
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _login,
                  child: Text('Login'),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to the registration page when the text is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    'Not registered yet? Click here',
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import 'package:flutter_flash_event/core/services/auth_services.dart';
import 'package:flutter_flash_event/core/models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User newUser = User(
        firstname: _firstNameController.text,
        lastname: _lastNameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      try {
        final response = await AuthServices.registerUser(newUser);
        if (response.statusCode == 201) {
          // Registration successful, navigate to login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed')),
          );
        }
      } catch (e) {
        print('Error: $e');
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
                  'Inscription',
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
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your first name',
                    labelText: 'First Name',
                    fillColor: Colors.white, // Text field background color
                    filled: true,
                    border: OutlineInputBorder(), // Text field border
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your last name',
                    labelText: 'Last Name',
                    fillColor: Colors.white, // Text field background color
                    filled: true,
                    border: OutlineInputBorder(), // Text field border
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    labelText: 'Username',
                    fillColor: Colors.white, // Text field background color
                    filled: true,
                    border: OutlineInputBorder(), // Text field border
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
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
                ElevatedButton(
                  onPressed: _register,
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
      ),
    );
  }
}
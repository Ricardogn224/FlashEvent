import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/blocs/authentication/authentication_bloc.dart';
import 'package:flutter_flash_event/blocs/authentication/authentication_event.dart';
import 'package:flutter_flash_event/blocs/login/login_bloc.dart';
import 'package:flutter_flash_event/blocs/login/login_event.dart';
import 'package:flutter_flash_event/blocs/login/login_state.dart';
import 'events_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => LoginBloc(),
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginLoading) {
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
            } else if (state is LoginSuccess) {
              Navigator.of(context).pop(); // Dismiss the loading indicator
              context.read<AuthenticationBloc>().add(LoggedIn());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EventsScreen()),
              );
            } else if (state is LoginFailure) {
              Navigator.of(context).pop(); // Dismiss the loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Connexion',
                    style: TextStyle(
                      fontSize: 24, // Font size resembling an H1 heading
                      fontWeight: FontWeight.bold, // Bold font weight
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 20),
                  BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            BlocProvider.of<LoginBloc>(context).add(
                              LoginButtonPressed(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            );
                          }
                        },
                        child: state is LoginLoading
                            ? const CircularProgressIndicator()
                            : const Text('Login'),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to the registration page when the text is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
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
      ),
    );
  }
}

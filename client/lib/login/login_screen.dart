import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/admin/admin_home_screen.dart';
import 'package:flutter_flash_event/authentication/authentication_bloc.dart';
import 'package:flutter_flash_event/authentication/authentication_event.dart';
import 'package:flutter_flash_event/login/bloc/login_bloc.dart';
import 'package:flutter_flash_event/login/bloc/login_event.dart';
import 'package:flutter_flash_event/login/bloc/login_state.dart';
import 'package:flutter_flash_event/widgets/main_screen.dart';
import 'package:flutter_flash_event/screens/base_screen.dart';
import 'package:flutter_flash_event/widgets/main_screen.dart';
import '../screens/register_screen.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Couleur de fond de l'écran
      body: BlocProvider(
        create: (context) => LoginBloc(),
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginLoading) {
              // Afficher un indicateur de chargement
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );
            } else if (state is LoginSuccess) {
              Navigator.of(context).pop(); // Fermer l'indicateur de chargement
              context.read<AuthenticationBloc>().add(LoggedIn());

              if (state.userRole == 'AdminPlatform') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminHomeDesktop()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              }
            } else if (state is LoginFailure) {
              Navigator.of(context).pop(); // Fermer l'indicateur de chargement
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage('assets/flash-event-logo.png'),
                      height: 150,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Entrez votre email',
                        labelText: 'Email',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Entrez votre mot de passe',
                        labelText: 'Mot de passe',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        } else if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Builder(
                      // Utilisation de Builder pour obtenir le bon contexte
                      builder: (context) => SizedBox(
                        width: double
                            .infinity, // Assurer que le bouton ait la même largeur que les input
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                                0xFF6058E9), // Couleur personnalisée du bouton
                            foregroundColor:
                                Colors.white, // Couleur du texte sur le bouton
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                          ),
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
                          child: const Text('Connexion'),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Pas encore inscrit ? Cliquez ici',
                          style: TextStyle(
                            color: Theme.of(context)
                                .primaryColor, // Utilise la couleur principale du thème
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

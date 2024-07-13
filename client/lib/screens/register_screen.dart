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
        id: 0,
      );

      try {
        final response = await AuthServices.registerUser(newUser);
        if (response.statusCode == 201) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de l\'inscription')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
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
      backgroundColor: Color(0xFFF9F9F9),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage('assets/flash-event-logo.png'),
                    height: 120,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Inscription',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(_emailController, 'Entrez votre email', 'Email'),
                  _buildTextField(_firstNameController, 'Entrez votre prénom', 'Prénom'),
                  _buildTextField(_lastNameController, 'Entrez votre nom', 'Nom'),
                  _buildTextField(_usernameController, 'Entrez votre nom d’utilisateur', 'Nom d’utilisateur'),
                  _buildTextField(_passwordController, 'Entrez votre mot de passe', 'Mot de passe', isPassword: true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6058E9),
                      foregroundColor: Colors.white, // Corrected property
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: _register,
                    child: const Text('S\'inscrire'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Déjà inscrit ? Cliquez ici',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor, // Utilise la couleur principale du thème
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
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, String labelText, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez entrer votre $labelText';
          }
          return null;
        },
      ),
    );
  }
}

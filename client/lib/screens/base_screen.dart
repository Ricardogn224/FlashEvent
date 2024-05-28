import 'package:flutter/material.dart';
import 'package:flutter_flash_event/screens/admin_home_desktop_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'events_screen.dart';


class BaseScreen extends StatefulWidget {
  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  void _checkLoginStatus() async {
    // Simulation de la vérification de l'état de connexion
    // Vous devez remplacer cette logique par votre mécanisme de vérification d'authentification
    bool isLoggedIn = false;

    if (isLoggedIn) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EventsScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  Future<bool> _getLoginStatus() async {
    // Cette fonction devrait vérifier l'état de connexion de l'utilisateur
    // Pour la démonstration, nous retournons simplement 'false'
    return false; // Changez cela en fonction de l'état réel de l'utilisateur
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Montrez un indicateur de chargement en attendant
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'base_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BaseScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF9F9F9), // Définit la couleur de fond en hexadécimal
        child: const Center(
          child: Image(
            image: AssetImage('assets/flash-event-logo.png'), // Chemin vers votre logo
            height: 300, // Ajustez la hauteur du logo si nécessaire
          ),
        ),
      ),
    );
  }
}

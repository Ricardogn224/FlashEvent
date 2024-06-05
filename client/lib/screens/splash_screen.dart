import 'package:flutter/material.dart';
import 'home_screen.dart';
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
        color: Color.fromARGB(255, 0, 0, 0), // Définit la couleur de fond en hexadécimal
        child: const Center(
          child: Text(
            'Flash Event',
            style: TextStyle(
              fontSize: 24,
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic 
            ),
            ),
        ),
      ),
    );
  }
}

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
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BaseScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF57A441), // Définit la couleur de fond en hexadécimal
        child: Center(
          child: Text('FLASH EVENT'),
        ),
      ),
    );
  }
}

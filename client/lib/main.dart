// main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'routes.dart';  // Assurez-vous d'ajuster le chemin d'importation selon votre structure de dossier

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flash Event',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      onGenerateRoute: generateRoute,  // Utilisez la fonction de routes.dart
    );
  }
}

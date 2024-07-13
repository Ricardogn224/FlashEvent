import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/api/firebase_api.dart';
import 'package:flutter_flash_event/authentication/authentication_bloc.dart';
import 'package:flutter_flash_event/authentication/authentication_event.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'routes.dart';  // Ensure this import path is correct for your folder structure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) => AuthenticationBloc()..add(AppStarted()),
        ),
      ],
      child: MaterialApp(
        title: 'Flash Event',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
        onGenerateRoute: generateRoute,  // Use the route generation function from routes.dart
      ),
    );
  }
}

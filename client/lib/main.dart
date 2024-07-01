import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/authentication/authentication_bloc.dart';
import 'package:flutter_flash_event/authentication/authentication_event.dart';
import 'screens/splash_screen.dart';
import 'routes.dart';  // Ensure this import path is correct for your folder structure

void main() {
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

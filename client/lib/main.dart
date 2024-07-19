import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/authentication/authentication_bloc.dart';
import 'package:flutter_flash_event/authentication/authentication_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_flash_event/firebase_options.dart';
import 'package:flutter_flash_event/screens/splash_screen.dart';
import 'package:flutter_flash_event/routes.dart';
import 'package:flutter_flash_event/widgets/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clear the preferences at the start of the app
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  await prefs.remove('email');
  await prefs.remove('userId');
  await prefs.remove('role');

  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    print('Firebase initialization skipped for this platform');
  }

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
        onGenerateRoute: (settings) => generateRoute(settings),
      ),
    );
  }
}

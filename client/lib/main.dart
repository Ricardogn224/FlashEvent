import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/authentication/authentication_bloc.dart';
import 'package:flutter_flash_event/authentication/authentication_event.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_flash_event/firebase_options.dart';
import 'package:flutter_flash_event/routes.dart' as custom_routes;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        initialRoute: '/splash',
        onGenerateRoute: custom_routes.generateRoute, // Use the route generation function from routes.dart
      ),
    );
  }
}

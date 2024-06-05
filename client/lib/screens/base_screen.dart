import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/blocs/authentication/authentication_bloc.dart';
import 'package:flutter_flash_event/blocs/authentication/authentication_event.dart';
import 'package:flutter_flash_event/blocs/authentication/authentication_state.dart';
import 'events_screen.dart';
import 'login_screen.dart';

class BaseScreen extends StatelessWidget {
  const BaseScreen({super.key});  

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthenticationBloc()..add(AppStarted()),
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationLoading || state is AuthenticationUninitialized) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is AuthenticationAuthenticated) {
            return EventsScreen();
          } else if (state is AuthenticationUnauthenticated) {
            return LoginScreen();
          } else {
            return const Scaffold(
              body: Center(
                child: Text('Unknown state'),
              ),
            );
          }
        },
      ),
    );
  }
}

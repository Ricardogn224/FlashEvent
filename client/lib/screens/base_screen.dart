import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/authentication/authentication_bloc.dart';
import 'package:flutter_flash_event/authentication/authentication_event.dart';
import 'package:flutter_flash_event/authentication/authentication_state.dart';
import 'package:flutter_flash_event/home/home_screen.dart';
import 'package:flutter_flash_event/login/login_screen.dart';
import 'package:flutter_flash_event/widgets/main_screen.dart';

class BaseScreen extends StatelessWidget {
  const BaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthenticationBloc()..add(AppStarted()),
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationLoading ||
              state is AuthenticationUninitialized) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is AuthenticationAuthenticated) {
            return MainScreen();
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

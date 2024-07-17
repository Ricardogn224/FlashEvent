import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/myAccount/bloc/my_account_bloc.dart';
import 'package:flutter_flash_event/core/services/auth_services.dart';

class MyAccountScreen extends StatelessWidget {
  static const String routeName = '/my-account';

  static navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const MyAccountScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthServices.logoutUser();
    // Navigate to login screen or home
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyAccountBloc()..add(MyAccountDataLoaded()),
      child: BlocBuilder<MyAccountBloc, MyAccountState>(
        builder: (context, state) {
          final user = state.user;
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF9F9F9),
              appBar: AppBar(
                title: const Text('Mon compte'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                ],
              ),
              body: state.status == MyAccountStatus.loading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : user != null
                  ? Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${user.firstname} - ${user.lastname}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    )
                  ],
                ),
              )
                  : const Center(
                child: Text('Event not found'),
              ),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/admin/blocFormUser/admin_form_user_bloc.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:flutter_flash_event/home/home_screen.dart';

class AdminUserNewScreen extends StatelessWidget {
  static const String routeName = '/admin-user-new';

  static navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const AdminUserNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminFormUserBloc()..add(InitNewEvent()),
      child: BlocBuilder<AdminFormUserBloc, AdminFormUserState>(
        builder: (context, state) {
          final email = state.email.value;
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF9F9F9),
              appBar: AppBar(
                title: const Text('Admmin Nouvel utilisateur'),
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
              body:
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomFormField(
                                hintText: 'Nom',
                                onChange: (val) {
                                  BlocProvider.of<AdminFormUserBloc>(context)
                                      .add(
                                    FirstnameChanged(
                                      firstname: BlocFormItem(value: val!),
                                    ),
                                  );
                                },
                                validator: (val) {
                                  return state.firstname.error;
                                },
                              ),
                              CustomFormField(
                                hintText: 'Prénom',
                                onChange: (val) {
                                  BlocProvider.of<AdminFormUserBloc>(context)
                                      .add(
                                    LastnameChanged(
                                      lastname: BlocFormItem(value: val!),
                                    ),
                                  );
                                },
                                validator: (val) {
                                  return state.lastname.error;
                                },
                              ),
                              CustomFormField(
                                hintText: 'Username',
                                onChange: (val) {
                                  BlocProvider.of<AdminFormUserBloc>(context)
                                      .add(
                                    UsernameChanged(
                                      username: BlocFormItem(value: val!),
                                    ),
                                  );
                                },
                                validator: (val) {
                                  return state.username.error;
                                },
                              ),
                              CustomFormField(
                                hintText: 'Password',
                                onChange: (val) {
                                  BlocProvider.of<AdminFormUserBloc>(context)
                                      .add(
                                    PasswordChanged(
                                      password: BlocFormItem(value: val!),
                                    ),
                                  );
                                },
                                validator: (val) {
                                  return state.password.error;
                                },
                              ),
                              const SizedBox(height: 30),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      BlocProvider.of<AdminFormUserBloc>(
                                              context)
                                          .add(
                                        FormSubmitEvent(
                                          onSuccess: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomeScreen(),
                                              ),
                                            );
                                          },
                                          onError: (errorMessage) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(errorMessage)),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: const Text('SUBMIT'),
                                  ),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      BlocProvider.of<AdminFormUserBloc>(
                                              context)
                                          .add(const FormResetEvent());
                                    },
                                    child: const Text('RESET'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
            ),
          );
        },
      ),
    );
  }
}

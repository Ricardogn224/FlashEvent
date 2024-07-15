import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/admin/blocFormUser/admin_form_user_bloc.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:flutter_flash_event/home/home_screen.dart';

class AdminUserEditScreen extends StatelessWidget {
  static const String routeName = '/admin-user-edit';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int id;

  const AdminUserEditScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminFormUserBloc()..add(InitEvent(id: id)),
      child: BlocBuilder<AdminFormUserBloc, AdminFormUserState>(
        builder: (context, state) {
          final email = state.email.value;
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF9F9F9),
              appBar: AppBar(
                title: const Text('Admin Évènement Detail'),
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
              body: state.status == FormStatus.inProgress
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : email != ''
                  ? Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: state.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFormField(
                        initialValue: state.firstname.value,
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
                        initialValue: state.lastname.value,
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
                        initialValue: state.username.value,
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
                      SwitchListTile(
                        title: const Text('Admin'),
                        value: state.role.value,
                        onChanged: (val) {
                          BlocProvider.of<AdminFormUserBloc>(context).add(
                            RoleChanged(role: val),
                          );
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
                                  id: id, // pass the user ID here
                                  onSuccess: () {
                                    Navigator.pop(context);
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
                ),
              )
                  : const Center(
                child: Text('User non trouvé'),
              ),
            ),
          );
        },
      ),
    );
  }
}

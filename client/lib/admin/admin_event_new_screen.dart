import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/admin/blocFormEvent/admin_form_bloc.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flash_event/home/home_screen.dart';

class AdminEventNewScreen extends StatelessWidget {
  static const String routeName = '/admin-event-new';

  static navigateTo(BuildContext context,) {
    Navigator.of(context).pushNamed(routeName);
  }


  const AdminEventNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminFormBloc()..add(InitNewEvent()),
      child: BlocBuilder<AdminFormBloc, AdminFormState>(
        builder: (context, state) {
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF9F9F9),
              appBar: AppBar(
                title: const Text('Admin New Event'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: state.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFormField(
                        hintText: 'Name',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[a-zA-Z\s]+"),
                          )
                        ],
                        onChange: (val) {
                          BlocProvider.of<AdminFormBloc>(context).add(
                            NameChanged(name: BlocFormItem(value: val!)),
                          );
                        },
                        validator: (val) {
                          return state.name.error;
                        },
                      ),
                      CustomFormField(
                        hintText: 'Description',
                        onChange: (val) {
                          BlocProvider.of<AdminFormBloc>(context).add(
                            DescriptionChanged(
                              description: BlocFormItem(value: val!),
                            ),
                          );
                        },
                        validator: (val) {
                          return state.description.error;
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Activate Transport'),
                        value: state.transportActive.value,
                        onChanged: (val) {
                          BlocProvider.of<AdminFormBloc>(context).add(
                            TransportActiveChanged(transportActive: val),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              BlocProvider.of<AdminFormBloc>(context).add(
                                FormNewSubmitEvent(
                                  onSuccess: () {
                                    Navigator.pop(context);
                                  },
                                  onError: (errorMessage) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMessage)),
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
                              BlocProvider.of<AdminFormBloc>(context)
                                  .add(const FormResetEvent());
                            },
                            child: const Text('RESET'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
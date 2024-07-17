import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/admin/admin_event_edit_screen.dart';
import 'package:flutter_flash_event/admin/blocFormEvent/admin_form_bloc.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:flutter/services.dart';

import '../core/models/event.dart';

class AdminUserAddParticipantScreen extends StatelessWidget {
  static const String routeName = '/admin-new-participant';

  static navigateTo(BuildContext context, {required Event event}) {
    Navigator.of(context).pushNamed(routeName, arguments: event);
  }

  final Event event;

  const AdminUserAddParticipantScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminFormBloc()..add(const InitAddEmail()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin création participant'),
        ),
        body: BlocBuilder<AdminFormBloc, AdminFormState>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: state.formKey,
                child: Column(
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        BlocProvider.of<AdminFormBloc>(context)
                            .add(FetchEmailSuggestions(query: textEditingValue.text, eventId: event.id));
                        return state.emailSuggestions.where((String option) {
                          return option.contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        BlocProvider.of<AdminFormBloc>(context)
                            .add(EmailChanged(email: BlocFormItem(value: selection)));
                      },
                      fieldViewBuilder: (
                        BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        return CustomFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          hintText: 'Email',
                          onChange: (val) {
                            BlocProvider.of<AdminFormBloc>(context)
                                .add(EmailChanged(email: BlocFormItem(value: val!)));
                          },
                          validator: (val) {
                            return state.email.error;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<AdminFormBloc>(context).add(FormParticipantSubmitEvent(
                              onSuccess: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => AdminEventEditScreen(event: event)),
                                );
                              },
                              onError: (errorMessage) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMessage)),
                                );
                              },
                              eventId: event.id,
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6058E9), // Couleur personnalisée du bouton
                            foregroundColor: Colors.white, // Couleur du texte sur le bouton
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          ),
                          child: const Text('SUBMIT'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<AdminFormBloc>(context).add(const FormResetEvent());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Couleur personnalisée du bouton
                            foregroundColor: Colors.white, // Couleur du texte sur le bouton
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          ),
                          child: const Text('RESET'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
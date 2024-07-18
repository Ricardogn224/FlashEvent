import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/eventParty/event_details_screen.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/formParticipant/bloc/form_participant_bloc.dart';
import 'package:flutter_flash_event/participant/participant_screen.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flash_event/home/home_screen.dart';

class FormParticipantScreen extends StatelessWidget {
  static const String routeName = '/new-participant';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int eventId;

  const FormParticipantScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormParticipantBloc(eventId: eventId)..add(InitEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Form Validation'),
        ),
        body: BlocBuilder<FormParticipantBloc, FormParticipantState>(
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
                        BlocProvider.of<FormParticipantBloc>(context)
                            .add(FetchEmailSuggestions(query: textEditingValue.text, eventId: eventId));
                        return state.emailSuggestions.where((String option) {
                          return option.contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        BlocProvider.of<FormParticipantBloc>(context)
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
                            BlocProvider.of<FormParticipantBloc>(context)
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
                            BlocProvider.of<FormParticipantBloc>(context).add(FormSubmitEvent(
                              onSuccess: () {
                                EventScreen.navigateTo(context, id: eventId);
                              },
                              onError: (errorMessage) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMessage)),
                                );
                              },
                            ));
                          },
                          child: const Text('SUBMIT'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<FormParticipantBloc>(context).add(const FormResetEvent());
                          },
                          child: const Text('RESET'),
                        ),
                      ],
                    )
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

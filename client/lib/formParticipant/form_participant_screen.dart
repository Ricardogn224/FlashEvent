import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/formParticipant/bloc/form_participant_bloc.dart';
import 'package:flutter_flash_event/participant/participant_screen.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flash_event/home/home_screen.dart';

class FormParticipantScreen extends StatelessWidget {

  static const String routeName = '/new-particpant';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int eventId;

  const FormParticipantScreen(this.eventId, {super.key});

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
                    CustomFormField(
                      hintText: 'Email',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[a-zA-Z]+|\s"),
                        )
                      ],
                      onChange: (val) {
                        BlocProvider.of<FormParticipantBloc>(context)
                            .add(EmailChanged(email: BlocFormItem(value: val!)));
                      },
                      validator: (val) {
                        return state.email.error;
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<FormParticipantBloc>(context).add(FormSubmitEvent(
                              onSuccess: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => ParticipantScreen(id: eventId)),
                                );
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

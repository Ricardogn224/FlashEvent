import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/cagnotte/cagnotte_screen.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/formCagnotte/bloc/form_cagnotte_bloc.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flash_event/home/home_screen.dart';

class FormCagnotteScreen extends StatelessWidget {
  static const String routeName = '/contribution';

  static navigateTo(BuildContext context, {required int eventId}) {
    Navigator.of(context).pushNamed(routeName, arguments: eventId);
  }

  final int eventId;

  const FormCagnotteScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormCagnotteBloc(eventId: eventId)..add(InitEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contribution cagnotte'),
        ),
        body: BlocBuilder<FormCagnotteBloc, FormCagnotteState>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: state.formKey,
                child: Column(
                  children: [
                    CustomFormField(
                      hintText: 'contribution',
                      onChange: (val) {
                        BlocProvider.of<FormCagnotteBloc>(context).add(
                          ContributionChanged(
                            contribution: BlocFormItem(value: val!),
                          ),
                        );
                      },
                      validator: (val) {
                        return state.contribution.error;
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<FormCagnotteBloc>(context).add(FormSubmitEvent(
                              onSuccess: () {
                                CagnotteScreen.navigateTo(context, eventId: eventId);
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
                            BlocProvider.of<FormCagnotteBloc>(context).add(const FormResetEvent());
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

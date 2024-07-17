import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/home/home_screen.dart';
import 'package:flutter_flash_event/transportation/blocForm/form_transport_bloc.dart';
import 'package:flutter_flash_event/transportation/transportation_screen.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:flutter/services.dart';

class TransportStartEditScreen extends StatelessWidget {
  static const String routeName = '/transport-start-edit';

  static navigateTo(BuildContext context, {required Event event}) {
    Navigator.of(context).pushNamed(routeName, arguments: event);
  }

  final Event event;

  const TransportStartEditScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormTransportBloc()..add(InitEvent(event: event)),
      child: BlocBuilder<FormTransportBloc, FormTransportState>(
        builder: (context, state) {
          final transportStart = state.transportStart.value;
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF9F9F9),
              appBar: AppBar(
                title: const Text('Lieu de départ'),
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
              body: Container(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: state.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFormField(
                        initialValue: transportStart,
                        hintText: 'Lieu de départ',
                        onChange: (val) {
                          BlocProvider.of<FormTransportBloc>(context).add(
                            TransportStartChanged(
                              transportStart: BlocFormItem(value: val!),
                            ),
                          );
                        },
                        validator: (val) {
                          return state.transportStart.error;
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              BlocProvider.of<FormTransportBloc>(context).add(
                                FormUpdateSubmitEvent(
                                  event: event,
                                  onSuccess: () {
                                    TransportationScreen.navigateTo(context, id: event.id);
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
                              BlocProvider.of<FormTransportBloc>(context)
                                  .add(const FormResetEvent());
                            },
                            child: const Text('RESET'),
                          ),
                        ],
                      ),
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
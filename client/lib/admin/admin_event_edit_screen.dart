import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/admin/admin_user_add_oarticipant.dart';
import 'package:flutter_flash_event/admin/blocFormEvent/admin_form_bloc.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flash_event/home/home_screen.dart';

import '../core/models/event.dart';

class AdminEventEditScreen extends StatelessWidget {
  static const String routeName = '/admin-event-edit';

  static navigateTo(BuildContext context, {required Event event}) {
    Navigator.of(context).pushNamed(routeName, arguments: event);
  }

  final Event event;

  const AdminEventEditScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminFormBloc()..add(InitEvent(id: event.id)),
      child: BlocBuilder<AdminFormBloc, AdminFormState>(
        builder: (context, state) {
          final eventName = state.name.value;
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF9F9F9),
              appBar: AppBar(
                title: const Text('Admin Event Detail'),
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
                  ? const Center(child: CircularProgressIndicator())
                  : eventName != ''
                  ? Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: state.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFormField(
                        initialValue: state.name.value,
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
                          if (state.name.value.isNotEmpty) {
                            return null; // Bypass validation if initial value is not empty
                          }
                          return state.name.error;
                        },
                      ),
                      CustomFormField(
                        initialValue: state.description.value,
                        hintText: 'Description',
                        onChange: (val) {
                          BlocProvider.of<AdminFormBloc>(context).add(
                            DescriptionChanged(
                              description: BlocFormItem(value: val!),
                            ),
                          );
                        },
                        validator: (val) {
                          if (state.description.value.isNotEmpty) {
                            return null; // Bypass validation if initial value is not empty
                          }
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
                                FormSubmitEvent(
                                  event: event, // pass the event ID here
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
                      const Text(
                        'Participant List',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            final participant = state.participants?[index];
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(participant!.firstname),
                              subtitle: Text('Email: ${participant.email}'),
                              trailing: TextButton(
                                child: const Text('Remove'),
                                onPressed: () => context
                                    .read<AdminFormBloc>()
                                    .add(RemoveParticipant(
                                  participantId: participant.id,
                                  eventId: event.id,
                                  active: false,
                                )),
                              ),
                            );
                          },
                          itemCount: state.participants?.length ?? 0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          AdminUserAddParticipantScreen.navigateTo(context, event: event);
                        },
                        child: const Text('Add Participant'),
                      ),
                    ],
                  ),
                ),
              )
                  : const Center(child: Text('Event not found')),
            ),
          );
        },
      ),
    );
  }
}
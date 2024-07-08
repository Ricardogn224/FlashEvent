import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/admin/admin_user_add_oarticipant.dart';
import 'package:flutter_flash_event/admin/blocForm/admin_form_bloc.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flash_event/home/home_screen.dart';

class AdminEventEditScreen extends StatelessWidget {
  static const String routeName = '/admin-event-edit';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int eventId;

  const AdminEventEditScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminFormBloc()..add(InitEvent(id: eventId)),
      /*child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Event'),
        ),
        body: BlocBuilder<AdminFormBloc, AdminFormState>(
          builder: (context, state) {
            final eventName = state.name.value;
            if (state.status == FormStatus.inProgress) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == FormStatus.valid && eventName != '') {
              return Container(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: state.formKey,
                  child: Column(
                    children: [
                      CustomFormField(
                        initialValue: eventName,
                        hintText: 'Name',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[a-zA-Z]+|\s"),
                          )
                        ],
                        onChange: (val) {
                          BlocProvider.of<AdminFormBloc>(context).add(
                              NameChanged(name: BlocFormItem(value: val!)));
                        },
                        validator: (val) {
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
                          return state.description.error;
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              BlocProvider.of<AdminFormBloc>(context).add(
                                FormSubmitEvent(
                                  onSuccess: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HomeScreen(),
                                      ),
                                    );
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
                      )
                    ],
                  ),
                ),
              );
            }

            return const Center(child: Text('Failed to load event data'));
          },
        ),
      ),
    );
  }
}*/
      child: BlocBuilder<AdminFormBloc, AdminFormState>(
        builder: (context, state) {
          final eventName = state.name.value;
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF9F9F9),
              appBar: AppBar(
                title: const Text('Admmin Évènement Detail'),
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
              body: state.status ==  FormStatus.inProgress
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : eventName != ''
                  ? Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomFormField(
                      initialValue: eventName,
                      hintText: 'Name',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[a-zA-Z]+|\s"),
                        )
                      ],
                      onChange: (val) {
                        BlocProvider.of<AdminFormBloc>(context).add(
                            NameChanged(name: BlocFormItem(value: val!)));
                      },
                      validator: (val) {
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
                        return state.description.error;
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<AdminFormBloc>(context).add(
                              FormSubmitEvent(
                                onSuccess: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                  );
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
                      'Liste des participants',
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
                              child: const Text('Retirer'),
                              onPressed: () => context.read<AdminFormBloc>().add(RemoveParticipant(participantId: participant.id, eventId: eventId, active: false)),
                            ),
                          );
                        },
                        itemCount: state.participants?.length,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        AdminUserAddParticipantScreen.navigateTo(context, id: eventId);
                      },
                      child: const Text('Ajouter un participant'),
                    ),
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
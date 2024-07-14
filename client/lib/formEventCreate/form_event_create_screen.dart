import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/formEventCreate/bloc/form_event_create_bloc.dart';
import 'package:flutter_flash_event/formEventCreate/bloc/form_event_create_event.dart';
import 'package:flutter_flash_event/formEventCreate/bloc/form_event_create_state.dart';

class FormEventCreateScreen extends StatelessWidget {
  static const String routeName = '/event_create';

  static navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const FormEventCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormEventCreateBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Créer un événement'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocListener<FormEventCreateBloc, FormEventCreateState>(
            listener: (context, state) {
              if (state.status == FormStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Événement créé avec succès')),
                );
                Navigator.pop(context);
              } else if (state.status == FormStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: ${state.errorMessage}')),
                );
              }
            },
            child: Form(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nom de l\'événement'),
                    onChanged: (value) {
                      context.read<FormEventCreateBloc>().add(
                            EventNameChanged(name: value),
                          );
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    onChanged: (value) {
                      context.read<FormEventCreateBloc>().add(
                            EventDescriptionChanged(description: value),
                          );
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Lieu'),
                    onChanged: (value) {
                      context.read<FormEventCreateBloc>().add(
                            EventPlaceChanged(place: value),
                          );
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Date de début'),
                    onChanged: (value) {
                      context.read<FormEventCreateBloc>().add(
                            EventDateStartChanged(dateStart: value),
                          );
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Date de fin'),
                    onChanged: (value) {
                      context.read<FormEventCreateBloc>().add(
                            EventDateEndChanged(dateEnd: value),
                          );
                    },
                  ),
                  SwitchListTile(
                    title: Text('Transport Actif'),
                    value: context.select((FormEventCreateBloc bloc) => bloc.state.transportActive),
                    onChanged: (value) {
                      context.read<FormEventCreateBloc>().add(
                            EventTransportActiveChanged(transportActive: value),
                          );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FormEventCreateBloc>().add(EventFormSubmitted());
                    },
                    child: Text('Créer l\'événement'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/eventParty/bloc/event_party_bloc.dart';
import 'package:flutter_flash_event/formParticipant/form_participant_screen.dart';
import 'package:flutter_flash_event/participant/bloc/participant_bloc.dart';

class ParticipantScreen extends StatelessWidget {
  static const String routeName = '/particpant';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int id;

  const ParticipantScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParticipantBloc()..add(ParticipantDataLoaded(id: id)),
      child: BlocBuilder<ParticipantBloc, ParticipantState>(
        builder: (context, state) {
          final participants = state.participants;
          print(participants);

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text('Part'),
              ),
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  if (state.status == ParticipantStatus.loading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (state.status == ParticipantStatus.success && participants != null)
                    Expanded( // Add Expanded here
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          final participant = state.participants?[index];
                          return ListTile(
                            leading: Icon(Icons.person),
                            title: Text(participant!.firstname),
                            subtitle: Text('Email: ${participant.email}'),
                          );
                        },
                        itemCount: state.participants?.length,
                      ),
                    ),
                  FloatingActionButton(
                    onPressed: () async {
                      final newParticipant = await Navigator.of(context).push<Map<String, String>>(
                        MaterialPageRoute(
                          builder: (context) => FormParticipantScreen(id),
                        ),
                      );

                      // Handle the new participant data if needed
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

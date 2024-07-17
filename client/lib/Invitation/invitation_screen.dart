import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/Invitation/bloc/invitation_bloc.dart';

class InvitationScreen extends StatelessWidget {
  static const String routeName = '/invitation';

  static navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const InvitationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InvitationBloc()..add(InvitationDataLoaded()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invitations'),
        ),
        body: BlocBuilder<InvitationBloc, InvitationState>(
          builder: (context, state) {
            final invitations = state.invitations;

            if (state.status == InvitationStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.status == InvitationStatus.error) {
              return const Center(
                child: Text(
                  'Erreur lors du chargement des invitations',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (state.status == InvitationStatus.success && invitations != null) {
              if (invitations.isEmpty) {
                return const Center(
                  child: Text(
                    'Aucune invitation pour le moment',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.builder(
                itemCount: invitations.length,
                itemBuilder: (context, index) {
                  final invitation = invitations[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.event),
                    ),
                    title: Text(invitation.eventName),
                    subtitle: Text('ID de l\'événement: ${invitation.eventId}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<InvitationBloc>().add(
                              InvitationAnsw(
                                participantId: invitation.participantId,
                                active: true,
                              ),
                            );
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Accepter'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<InvitationBloc>().add(
                              InvitationAnsw(
                                participantId: invitation.participantId,
                                active: false,
                              ),
                            );
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Refuser'),
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

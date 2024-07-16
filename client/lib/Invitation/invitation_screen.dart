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
      child: BlocBuilder<InvitationBloc, InvitationState>(
        builder: (context, state) {
          final invitations = state.invitations;

          return Scaffold(
            appBar: AppBar(
              title: Text('Invitations'),
            ),
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  if (state.status == InvitationStatus.loading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (state.status == InvitationStatus.success && invitations != null)
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          final invitation = state.invitations?[index];
                          return ListTile(
                            leading: Icon(Icons.person),
                            title: Text('${invitation!.eventName}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<InvitationBloc>().add(InvitationAnsw(participantId: invitation.participantId, active: true));
                                  },
                                  icon: Icon(Icons.check),
                                  label: Text('Accept'),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<InvitationBloc>().add(InvitationAnsw(participantId: invitation.participantId, active: false));
                                  },
                                  icon: Icon(Icons.close),
                                  label: Text('Refuse'),
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: state.invitations?.length,
                      ),
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

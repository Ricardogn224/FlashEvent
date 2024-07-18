import 'package:flutter/material.dart';
import 'package:flutter_flash_event/core/models/participant.dart';
import 'package:flutter_flash_event/core/models/transportation.dart';
import 'package:flutter_flash_event/core/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/transportation/bloc/transportation_bloc.dart';

class TransportationListItem extends StatefulWidget {
  final Transportation transportation;
  final List<UserTransport> participants;
  final User? currentUser;

  const TransportationListItem({
    Key? key,
    required this.transportation,
    required this.participants,
    required this.currentUser,
  }) : super(key: key);

  @override
  _TransportationListItemState createState() => _TransportationListItemState();
}

class _TransportationListItemState extends State<TransportationListItem> {
  bool _isExpanded = false;
  String? _loggedInEmail;

  @override
  void initState() {
    super.initState();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _removeParticipant(UserTransport participant) {
    final participantUpdate = Participant(
      id: participant.participantId,
      userId: participant.userId,
      eventId: participant.eventId,
      transportationId: 0,
      present: true,
      contribution: 0, // Setting transportationId to 0 to indicate removal
    );

    context.read<TransportationBloc>().add(UpdateParticipant(participant: participantUpdate));
  }

  void _addParticipant(Transportation transportation) {
    final participantUpdate = Participant(
      id: 0,
      userId: widget.currentUser!.id,
      eventId: transportation.eventId,
      transportationId: transportation.id,
      present: true,
      contribution: 0, // Setting transportationId to 0 to indicate removal
    );

    context.read<TransportationBloc>().add(UpdateParticipant(participant: participantUpdate));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(_isExpanded ? Icons.arrow_drop_down : Icons.arrow_right),
          title: Text(widget.transportation.vehicle),
          subtitle: Text('Seats: ${widget.transportation.seatNumber}'),
          onTap: _toggleExpanded,
        ),
        if (_isExpanded)
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.participants.map((participant) {
                    return ListTile(
                      title: Text(participant.lastname),
                      subtitle: Text(participant.email),
                      trailing: participant.userId == widget.currentUser?.id
                          ? TextButton(
                        child: Text('Se retirer'),
                        onPressed: () => _removeParticipant(participant),
                      )
                          : null, // No trailing button if userId doesn't match
                    );
                  }).toList(),
                  if (!widget.participants.any((participant) => participant.userId == widget.currentUser!.id)
                  && widget.currentUser!.id != widget.transportation.userId && widget.transportation.seatNumber >
                  widget.participants.length)
                    ElevatedButton(
                      onPressed: () => _addParticipant(widget.transportation),
                      child: Text('S\'ajouter'),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

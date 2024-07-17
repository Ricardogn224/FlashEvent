import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/formTransportation/form_transportation_screen.dart';
import 'package:flutter_flash_event/transportation/bloc/transportation_bloc.dart';
import 'package:flutter_flash_event/transportation/transport_start_edit_screen.dart';
import 'package:flutter_flash_event/transportation/transportation_list_item.dart';

class TransportationScreen extends StatelessWidget {
  static const String routeName = '/transportation';

  static void navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int id;

  const TransportationScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransportationBloc()..add(TransportationDataLoaded(id: id)),
      child: BlocBuilder<TransportationBloc, TransportationState>(
        builder: (context, state) {
          final transportations = state.transportations;
          final participants = state.participants;
          final currentUser = state.currentUser;
          final eventParty = state.eventParty;

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text('Transport'),
              ),
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  if (eventParty != null) // Check if eventParty is not null
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lieu de départ : ' + (eventParty.transportStart.isNotEmpty
                                ? eventParty.transportStart
                                : 'Indéfini'),
                            style: TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              TransportStartEditScreen.navigateTo(context, event: eventParty);
                            },
                          ),
                        ],
                      ),
                    ),
                  if (state.status == TransportationStatus.loading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (state.status == TransportationStatus.success && transportations != null)
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          final transportation = transportations[index];
                          final transportParticipants = participants?.where((p) => p.transportationId == transportation.id).toList() ?? [];
                          return TransportationListItem(
                            transportation: transportation,
                            participants: transportParticipants,
                            currentUser: currentUser,
                          );
                        },
                        itemCount: transportations.length,
                      ),
                    ),
                  FloatingActionButton(
                    onPressed: () async {
                      final newParticipant = await Navigator.of(context).push<Map<String, String>>(
                        MaterialPageRoute(
                          builder: (context) => FormTransportationScreen.navigateTo(context, id: id),
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


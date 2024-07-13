import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/Invitation/invitation_screen.dart';
import 'package:flutter_flash_event/transportation/transportation_screen.dart';
import 'package:flutter_flash_event/chatRoom/chat_room_screen.dart';
import 'package:flutter_flash_event/eventParty/bloc/event_party_bloc.dart';
import 'package:flutter_flash_event/itemEvent/item_event_screen.dart';
import 'package:flutter_flash_event/participant/participant_screen.dart';

class EventScreen extends StatelessWidget {
  static const String routeName = '/event';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int id;

  const EventScreen({super.key, required this.id});

  Widget _buildRating(BuildContext context, {required double rating}) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          color: index < rating ? Colors.blue : Colors.grey,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventPartyBloc()..add(EventPartyDataLoaded(id: id)),
      child: BlocBuilder<EventPartyBloc, EventPartyState>(
        builder: (context, state) {
          final eventParty = state.eventParty;
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF9F9F9),
              appBar: AppBar(
                title: const Text('Évènement Detail'),
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
              body: state.status == EventPartyStatus.loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : eventParty != null
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eventParty.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                eventParty.description,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.location_on,
                                            color: Color(0xFF6058E9)),
                                        SizedBox(width: 8),
                                        Text('New York - USA'),
                                      ],
                                    ),
                                    const Divider(), // Ligne de séparation
                                    Row(
                                      children: const [
                                        Icon(Icons.calendar_today,
                                            color: Color(0xFF6058E9)),
                                        SizedBox(width: 8),
                                        Text('28 Sun 2021'),
                                      ],
                                    ),
                                    const Divider(), // Ligne de séparation
                                    Row(
                                      children: const [
                                        Icon(Icons.people,
                                            color: Color(0xFF6058E9)),
                                        SizedBox(width: 8),
                                        Text('128 Attendees'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ListTile(
                                title: Text('Liste des participants'),
                                trailing: Icon(Icons.people),
                                onTap: () => ParticipantScreen.navigateTo(
                                    context,
                                    id: eventParty!.id),
                              ),
                              ListTile(
                                title: Text('Liste des messages'),
                                trailing: Icon(Icons.adb),
                                onTap: () => ChatRoomScreen.navigateTo(context,
                                    id: eventParty!.id),
                              ),
                              ListTile(
                                title: Text('Liste des choses'),
                                trailing: Icon(Icons.adb),
                                onTap: () => ItemEventScreen.navigateTo(context,
                                    id: eventParty!.id),
                              ),
                              ListTile(
                                title: Text('Gestion du transport'),
                                trailing: Icon(Icons.adb),
                                onTap: () => TransportationScreen.navigateTo(
                                    context,
                                    id: eventParty!.id),
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

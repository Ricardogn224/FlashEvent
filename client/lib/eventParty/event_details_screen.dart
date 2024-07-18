import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/cagnotte/cagnotte_screen.dart';
import 'package:flutter_flash_event/chatRoom/chat_room_screen.dart';
import 'package:flutter_flash_event/eventParty/bloc/event_party_bloc.dart';
import 'package:flutter_flash_event/core/services/user_services.dart';
import 'package:flutter_flash_event/core/services/participant_services.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/formParticipant/form_participant_screen.dart';
import 'package:flutter_flash_event/itemEvent/item_event_screen.dart';
import 'package:flutter_flash_event/transportation/transportation_screen.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:intl/intl.dart';
import 'package:flutter_flash_event/core/models/participant.dart';
import 'package:flutter_flash_event/core/models/itemEvent.dart';

class EventScreen extends StatefulWidget {
  static const String routeName = '/event';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int id;

  const EventScreen({Key? key, required this.id}) : super(key: key);

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  bool showParticipants = false;
  bool showParticipantsPresence = false;
  bool showAddParticipantForm = false;
  bool showItems = false;
  bool showAddItemForm = false;
  late TextEditingController emailController;
  late TextEditingController itemController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    itemController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventPartyBloc()..add(EventPartyDataLoaded(id: widget.id)),
      child: BlocBuilder<EventPartyBloc, EventPartyState>(
        builder: (context, state) {
          final eventParty = state.eventParty;

          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color(0xFFF9F9F9),
              appBar: AppBar(
                title: const Text('Évènement Détail'),
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
                child: SingleChildScrollView(
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
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Color(0xFF6058E9)),
                                const SizedBox(width: 8),
                                Text(eventParty.place ?? 'Undefined'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Color(0xFF6058E9)),
                                const SizedBox(width: 8),
                                Text(
                                  eventParty.dateStart != null &&
                                      eventParty.dateStart
                                          .isNotEmpty
                                      ? DateFormat.yMMMd().format(
                                      DateTime.parse(
                                          eventParty.dateStart))
                                      : 'Undefined',
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  eventParty.dateStart != null &&
                                      eventParty.dateStart
                                          .isNotEmpty
                                      ? DateFormat.Hm().format(
                                      DateTime.parse(
                                          eventParty.dateStart))
                                      : '',
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Color(0xFF6058E9)),
                                const SizedBox(width: 8),
                                Text(
                                  eventParty.dateEnd != null &&
                                      eventParty.dateEnd
                                          .isNotEmpty
                                      ? DateFormat.yMMMd().format(
                                      DateTime.parse(
                                          eventParty.dateEnd))
                                      : 'Undefined',
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  eventParty.dateEnd != null &&
                                      eventParty.dateEnd
                                          .isNotEmpty
                                      ? DateFormat.Hm().format(
                                      DateTime.parse(
                                          eventParty.dateEnd))
                                      : '',
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showParticipants =
                                      !showParticipants;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.people,
                                          color: Color(0xFF6058E9)),
                                      const SizedBox(width: 8),
                                      const Text('Participants'),
                                      Icon(
                                        showParticipants
                                            ? Icons.arrow_drop_up
                                            : Icons.arrow_drop_down,
                                        color: Color(0xFF6058E9),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Color(0xFF6058E9),
                                  ),
                                  onPressed: () {
                                    FormParticipantScreen.navigateTo(
                                        context,
                                        id: widget.id);
                                  },
                                ),
                              ],
                            ),
                            if (showParticipants)
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  if (state.participants != null &&
                                      state.participants!.isNotEmpty)
                                    ...state.participants!.map(
                                            (participant) {
                                          return ListTile(
                                            leading:
                                            Icon(Icons.person),
                                            title: Text(
                                                '${participant.firstname} ${participant.lastname}'),
                                          );
                                        }).toList()
                                  else
                                    const Text(
                                        'Aucun participant à afficher'),
                                ],
                              ),
                            SwitchListTile(
                              title: const Text("Ma présence"),
                              value: state.userParticipant?.present ??
                                  false,
                              onChanged: (bool value) {
                                if (state.userParticipant != null) {
                                  context
                                      .read<EventPartyBloc>()
                                      .add(
                                    UpdateParticipant(
                                      participant:
                                      state.userParticipant!,
                                      newVal: value,
                                    ),
                                  );
                                }
                              },
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showParticipantsPresence =
                                      !showParticipantsPresence;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.people,
                                          color: Color(0xFF6058E9)),
                                      const SizedBox(width: 8),
                                      const Text(
                                          'Participants avec présence confirmée'),
                                      Icon(
                                        showParticipantsPresence
                                            ? Icons.arrow_drop_up
                                            : Icons.arrow_drop_down,
                                        color: Color(0xFF6058E9),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (showParticipantsPresence)
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  if (state.participantsPresence !=
                                      null &&
                                      state.participantsPresence!
                                          .isNotEmpty)
                                    ...state.participantsPresence!
                                        .map(
                                            (participantPresence) {
                                          return ListTile(
                                            leading:
                                            Icon(Icons.person),
                                            title: Text(
                                                '${participantPresence.firstname} ${participantPresence.lastname}'),
                                          );
                                        }).toList()
                                  else
                                    const Text(
                                        'Aucun participant à afficher'),
                                ],
                              ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showItems = !showItems;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.list,
                                          color: Color(0xFF6058E9)),
                                      const SizedBox(width: 8),
                                      const Text('Choses à ramener'),
                                      Icon(
                                        showItems
                                            ? Icons.arrow_drop_up
                                            : Icons.arrow_drop_down,
                                        color: Color(0xFF6058E9),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    showAddItemForm
                                        ? Icons.remove
                                        : Icons.add,
                                    color: Color(0xFF6058E9),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showAddItemForm =
                                      !showAddItemForm;
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (showItems)
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  if (state.itemEvents != null &&
                                      state.itemEvents!.isNotEmpty)
                                    ...state.itemEvents!.map(
                                            (itemEvent) {
                                          return ListTile(
                                            leading:
                                            Icon(Icons.person),
                                            title: Text(itemEvent.name),
                                            subtitle: Text(
                                                '${itemEvent.firstname} ${itemEvent.lastname}'),
                                          );
                                        }).toList()
                                  else
                                    const Text(
                                        'Aucun item à afficher'),
                                ],
                              ),
                            if (showAddItemForm)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: itemController,
                                        decoration:
                                        const InputDecoration(
                                          hintText:
                                          'Nom de l\'item',
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.check,
                                          color: Colors.green),
                                      onPressed: () {
                                        if (itemController
                                            .text.isNotEmpty) {
                                          final newItem = ItemEvent(
                                            id: 0,
                                            name: itemController
                                                .text,
                                            userId: state
                                                .userParticipant
                                                ?.userId ??
                                                0,
                                            eventId: widget.id,
                                            firstname: 'John',
                                            lastname: 'Doe',
                                          );

                                          context
                                              .read<EventPartyBloc>()
                                              .add(AddItem(
                                              itemEvent:
                                              newItem));
                                          setState(() {
                                            itemController.clear();
                                            showAddItemForm = false;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            const Divider(),
                            GestureDetector(
                              onTap: () {
                                TransportationScreen.navigateTo(
                                    context, id: widget.id);
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.directions_car,
                                      color: Color(0xFF6058E9)),
                                  SizedBox(width: 8),
                                  Text('Le transport'),
                                ],
                              ),
                            ),
                            const Divider(),
                            GestureDetector(
                              onTap: () {
                                CagnotteScreen.navigateTo(context,
                                    eventId: widget.id);
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.attach_money,
                                      color: Color(0xFF6058E9)),
                                  SizedBox(width: 8),
                                  Text('La cagnotte'),
                                ],
                              ),
                            ),
                            const Divider(),
                            GestureDetector(
                              onTap: () {
                                ChatRoomScreen.navigateTo(context,
                                    id: widget.id);
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.chat,
                                      color: Color(0xFF6058E9)),
                                  SizedBox(width: 8),
                                  Text('Accéder aux salles de discussions'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : const Center(
                child: Text('Événement non trouvé'),
              ),
            ),
          );
        },
      ),
    );
  }
}

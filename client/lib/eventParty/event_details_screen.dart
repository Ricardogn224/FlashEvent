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
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFF6058E9)),
                                const SizedBox(width: 8),
                                Text(eventParty.place ?? 'Undefined'),
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Color(0xFF6058E9)),
                                const SizedBox(width: 8),
                                Text(
                                    eventParty.dateStart != null && eventParty.dateStart.isNotEmpty
                                        ? DateFormat.yMMMd().format(DateTime.parse(eventParty.dateStart))
                                        : 'Undefined'),
                                const SizedBox(width: 8),
                                Text(
                                    eventParty.dateStart != null && eventParty.dateStart.isNotEmpty
                                        ? DateFormat.Hm().format(DateTime.parse(eventParty.dateStart))
                                        : ''),
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Color(0xFF6058E9)),
                                const SizedBox(width: 8),
                                Text(
                                    eventParty.dateEnd != null && eventParty.dateEnd.isNotEmpty
                                        ? DateFormat.yMMMd().format(DateTime.parse(eventParty.dateEnd))
                                        : 'Undefined'),
                                const SizedBox(width: 8),
                                Text(
                                    eventParty.dateEnd != null && eventParty.dateEnd.isNotEmpty
                                        ? DateFormat.Hm().format(DateTime.parse(eventParty.dateEnd))
                                        : ''),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showParticipants = !showParticipants;
                                    });
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(Icons.people, color: Color(0xFF6058E9)),
                                      SizedBox(width: 8),
                                      Text('Participants'),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    /*showAddParticipantForm ? Icons.remove :*/ Icons.add,
                                    color: Color(0xFF6058E9),
                                  ),
                                  onPressed: () {
                                    /*setState(() {
                                      showAddParticipantForm = !showAddParticipantForm;
                                    });*/
                                    FormParticipantScreen.navigateTo(context, id: widget.id);
                                  },
                                ),
                              ],
                            ),
                            if (showParticipants)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  if (state.participants != null && state.participants!.isNotEmpty)
                                    ...state.participants!
                                        .map((participant) => Text('Participant: ${participant.firstname} ${participant.lastname}'))
                                        .toList()
                                  else
                                    const Text('Aucun participant à afficher'),
                                ],
                              ),
                            if (showAddParticipantForm)
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                child: Form(
                                  key: state.formKey,
                                  child: Column(
                                    children: [
                                      Autocomplete<String>(
                                        optionsBuilder: (TextEditingValue textEditingValue) {
                                          if (textEditingValue.text.isEmpty) {
                                            return const Iterable<String>.empty();
                                          }
                                          BlocProvider.of<EventPartyBloc>(context)
                                              .add(FetchEmailSuggestions(query: textEditingValue.text, eventId: state.userParticipant!.eventId));
                                          return state.emailSuggestions.where((String option) {
                                            return option.contains(textEditingValue.text.toLowerCase());
                                          });
                                        },
                                        onSelected: (String selection) {
                                          BlocProvider.of<EventPartyBloc>(context)
                                              .add(EmailChanged(email: BlocFormItem(value: selection)));
                                        },
                                        fieldViewBuilder: (
                                            BuildContext context,
                                            TextEditingController textEditingController,
                                            FocusNode focusNode,
                                            VoidCallback onFieldSubmitted,
                                            ) {
                                          return CustomFormField(
                                            controller: emailController,
                                            focusNode: focusNode,
                                            hintText: 'Email',
                                            onChange: (val) {
                                              BlocProvider.of<EventPartyBloc>(context)
                                                  .add(EmailChanged(email: BlocFormItem(value: val!)));
                                            },
                                            validator: (val) {
                                              return state.email.error;
                                            },
                                          );

                                        },
                                      ),
                                      const SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              context.read<EventPartyBloc>().add(
                                                FormSubmitEvent(
                                                  participant: state.userParticipant!,
                                                  onSuccess: () {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EventScreen(id: state.userParticipant!.eventId)),
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
                                            child: const Text('AJOUTER'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {},
                                            child: const Text('RÉINITIALISER'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            SwitchListTile(
                              title: Text("Ma présence"),
                              value: state.userParticipant?.present ?? false,
                              onChanged: (bool value) {
                                if (state.userParticipant != null) {
                                  // Dispatch the UpdateParticipant event
                                  context.read<EventPartyBloc>().add(
                                    UpdateParticipant(
                                      participant: state.userParticipant!,
                                      newVal: value,
                                    ),
                                  );
                                }
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showParticipantsPresence = !showParticipantsPresence;
                                    });
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(Icons.people, color: Color(0xFF6058E9)),
                                      SizedBox(width: 8),
                                      Text('Participants avec présence confirmé'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (showParticipantsPresence)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  if (state.participantsPresence != null && state.participantsPresence!.isNotEmpty)
                                    ...state.participantsPresence!
                                        .map((participantPresence) => Text('Participant: ${participantPresence.firstname} ${participantPresence.lastname}'))
                                        .toList()
                                  else
                                    const Text('Aucun participant à afficher'),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Navigate to ChatRoomScreen with event ID or relevant data
                          ChatRoomScreen.navigateTo(context, id: widget.id);
                        },
                        child: const Text(
                          'Accéder aux salles de discussions',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to ItemEventScreen with event ID or relevant data
                          ItemEventScreen.navigateTo(context, id: widget.id);
                        },
                        child: const Text(
                          'Les choses à ramener',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),

                      if (state.feature?.active == true || state.feature?.name == '')
                        TextButton(
                          onPressed: () {
                            // Navigate to TransportationScreen with event ID or relevant data
                            TransportationScreen.navigateTo(context, id: widget.id);
                          },
                          child: const Text(
                            'Le transport',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      TextButton(
                        onPressed: () {
                          // Navigate to TransportationScreen with event ID or relevant data
                          CagnotteScreen.navigateTo(context, eventId: widget.id);
                        },
                        child: const Text(
                          'La cagnotte',
                          style: TextStyle(color: Colors.blue),
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
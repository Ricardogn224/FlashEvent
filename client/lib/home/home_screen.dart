import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/Invitation/bloc/invitation_bloc.dart';
import 'package:flutter_flash_event/eventParty/event_details_screen.dart';
import 'package:flutter_flash_event/home/blocs/home_bloc.dart';
import 'package:flutter_flash_event/myAccount/my_account_screen.dart';
import 'package:flutter_flash_event/formEventCreate/form_event_create_screen.dart'; // Import screen
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeBloc()..add(HomeDataLoaded()),
        ),
        BlocProvider(
          create: (context) => InvitationBloc()..add(InvitationDataLoaded()),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, homeState) {
              return BlocBuilder<InvitationBloc, InvitationState>(
                builder: (context, invitationState) {
                  if (homeState is HomeLoading ||
                      invitationState.status == InvitationStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (homeState is HomeDataLoadError) {
                    return Center(
                      child: Text(homeState.errorMessage),
                    );
                  }

                  if (invitationState.status == InvitationStatus.error) {
                    return Center(
                      child: Text(invitationState.errorMessage ??
                          'Erreur lors du chargement des invitations'),
                    );
                  }

                  if (homeState is HomeDataLoadSuccess &&
                      invitationState.status == InvitationStatus.success) {
                    final int eventCount = homeState.events.length;
                    final int invitationCount =
                        invitationState.invitations?.length ?? 0;

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () {
                                  // Action pour le menu
                                },
                              ),
                              Image.asset(
                                'assets/flash-event-logo.png',
                                height: 60, // Ajuster la taille du logo selon vos besoins
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey.shade300,
                                child: IconButton(
                                  icon: const Icon(Icons.person),
                                  onPressed: () =>
                                      MyAccountScreen.navigateTo(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Recherche',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(16.0),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Stack(
                                children: [
                                  const Icon(Icons.person_add, size: 30),
                                  Positioned(
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 14,
                                        minHeight: 14,
                                      ),
                                      child: Text(
                                        '$invitationCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Invitations',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (invitationCount == 0)
                            const Center(
                              child: Text(
                                'Aucune invitation à afficher pour le moment',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: invitationCount,
                                itemBuilder: (context, index) {
                                  final invitation =
                                  invitationState.invitations![index];
                                  return ListTile(
                                    leading: const Icon(Icons.event),
                                    title: Text(invitation.eventName),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            context.read<InvitationBloc>().add(
                                                InvitationAnsw(
                                                    participantId:
                                                    invitation.participantId,
                                                    active: true));
                                          },
                                          icon: const Icon(Icons.check),
                                          label: const Text('Accepter'),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            context.read<InvitationBloc>().add(
                                                InvitationAnsw(
                                                    participantId:
                                                    invitation.participantId,
                                                    active: false));
                                          },
                                          icon: const Icon(Icons.close),
                                          label: const Text('Refuser'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Stack(
                                children: [
                                  const Icon(Icons.event, size: 30),
                                  Positioned(
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 14,
                                        minHeight: 14,
                                      ),
                                      child: Text(
                                        '$eventCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Événements',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (eventCount == 0)
                            const Center(
                              child: Text(
                                'Aucun événement à afficher pour le moment',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: eventCount,
                                itemBuilder: (context, index) {
                                  final event = homeState.events[index];
                                  final eventStart = event.dateStart != null &&
                                      event.dateStart.isNotEmpty
                                      ? DateTime.parse(event.dateStart)
                                      : null;
                                  final eventEnd = event.dateEnd != null &&
                                      event.dateEnd.isNotEmpty
                                      ? DateTime.parse(event.dateEnd)
                                      : null;

                                  final eventStartDate =
                                  eventStart != null
                                      ? DateFormat.yMMMd().format(eventStart)
                                      : 'Undefined'; // Format the start date
                                  final eventStartTime =
                                  eventStart != null
                                      ? DateFormat.Hm().format(eventStart)
                                      : ''; // Format the start time
                                  final eventEndDate =
                                  eventEnd != null
                                      ? DateFormat.yMMMd().format(eventEnd)
                                      : 'Undefined'; // Format the end date
                                  final eventEndTime =
                                  eventEnd != null
                                      ? DateFormat.Hm().format(eventEnd)
                                      : ''; // Format the end time

                                  return GestureDetector(
                                    onTap: () =>
                                        EventScreen.navigateTo(context, id: event.id),
                                    child: Card(
                                      margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Container(
                                        width: 200,
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                vertical: 4,
                                                horizontal: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '$eventStartDate $eventStartTime - $eventEndDate $eventEndTime',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              event.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              event.place ?? 'Undefined',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox();
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FormEventCreateScreen()),
            );
          },
          backgroundColor: const Color(0xFF6058E9),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

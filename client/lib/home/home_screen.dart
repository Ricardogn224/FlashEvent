import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/Invitation/invitation_screen.dart';
import 'package:flutter_flash_event/eventParty/event_details_screen.dart';
import 'package:flutter_flash_event/home/blocs/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(HomeDataLoaded()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is HomeDataLoadError) {
                return Center(
                  child: Text(state.errorMessage),
                );
              }

              if (state is HomeDataLoadSuccess) {
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
                              onPressed: () {
                                // Action pour le profil
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Find Events',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Let's start having fun",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      ListTile(
                        title: Text('Liste des invitations'),
                        trailing: Icon(Icons.adb),
                        onTap: () => InvitationScreen.navigateTo(context),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
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
                      const Text(
                        'Mes évènements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200, // Définir la hauteur maximale de la section des événements
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final event = state.events[index];
                            return GestureDetector(
                              onTap: () => EventScreen.navigateTo(context, id: event.id),
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  width: 200, // Définir une largeur fixe pour les cartes
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          '17 Dec',
                                          style: TextStyle(
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
                                      const Text(
                                        'Saturday',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: state.events.length,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to the add event screen
            Navigator.pushNamed(context, '/event_new');
          },
          child: Icon(Icons.add),
          backgroundColor: const Color(0xFF6058E9),
        ),
      ),
    );
  }
}

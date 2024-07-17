import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SafeArea(
          child: Navigator(
            onGenerateRoute: (RouteSettings settings) {
              WidgetBuilder builder;
              switch (settings.name) {
                case '/':
                  builder = (BuildContext context) => HomeContent();
                  break;
                case EventScreen.routeName:
                  builder = (BuildContext context) => EventScreen(id: settings.arguments as int);
                  break;
                case MyAccountScreen.routeName:
                  builder = (BuildContext context) => const MyAccountScreen();
                  break;
                default:
                  throw Exception('Invalid route: ${settings.name}');
              }
              return MaterialPageRoute(builder: builder, settings: settings);
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

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, homeState) {
        if (homeState is HomeLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (homeState is HomeDataLoadError) {
          return Center(
            child: Text(homeState.errorMessage),
          );
        }

        if (homeState is HomeDataLoadSuccess) {
          final int eventCount = homeState.events.length;

          return SingleChildScrollView(
            child: Padding(
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
                          onPressed: () => MyAccountScreen.navigateTo(context),
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
                    Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: eventCount,
                            onPageChanged: (int page) {
                              setState(() {
                                _currentPage = page;
                              });
                            },
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

                              final eventStartDate = eventStart != null
                                  ? DateFormat.yMMMd().format(eventStart)
                                  : 'Undefined'; // Format the start date
                              final eventStartTime = eventStart != null
                                  ? DateFormat.Hm().format(eventStart)
                                  : ''; // Format the start time
                              final eventEndDate = eventEnd != null
                                  ? DateFormat.yMMMd().format(eventEnd)
                                  : 'Undefined'; // Format the end date
                              final eventEndTime = eventEnd != null
                                  ? DateFormat.Hm().format(eventEnd)
                                  : ''; // Format the end time

                              return GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  EventScreen.routeName,
                                  arguments: event.id,
                                ),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  color: Colors.white, // Set background color to white
                                  elevation: 3.0,
                                  shadowColor: Colors.black.withOpacity(0.25),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$eventStartDate @ $eventStartTime - $eventEndDate @ $eventEndTime',
                                          style: const TextStyle(
                                            color: Color(0xFF6058E9), // Updated color
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          event.name,
                                          style: const TextStyle(
                                            color: Colors.black, // Updated color
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
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
                        const SizedBox(height: 16), // Add this line to create space
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(eventCount, (index) => buildDot(index, context)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 8,
      width: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? const Color(0xFF6058E9) // Active dot color
            : const Color(0xFFC4C4C4), // Inactive dot color
      ),
    );
  }
}

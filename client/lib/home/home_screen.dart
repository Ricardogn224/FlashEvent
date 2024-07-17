import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/eventParty/event_details_screen.dart';
import 'package:flutter_flash_event/home/blocs/home_bloc.dart';
import 'package:flutter_flash_event/myAccount/my_account_screen.dart';
import 'package:flutter_flash_event/formEventCreate/form_event_create_screen.dart';
import 'package:flutter_flash_event/chatRoom/chat_room_screen.dart';
import 'package:flutter_flash_event/core/models/event.dart';
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
                case ChatRoomScreen.routeName:
                  builder = (BuildContext context) => ChatRoomScreen(id: settings.arguments as int);
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
  int _currentMyEventsPage = 0;
  int _currentCreatedEventsPage = 0;
  final PageController _myEventsPageController = PageController();
  final PageController _createdEventsPageController = PageController();

  @override
  void dispose() {
    _myEventsPageController.dispose();
    _createdEventsPageController.dispose();
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
          final int myEventCount = homeState.myEvents.length;
          final int createdEventCount = homeState.createdEvents.length;

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
                  // Mes Événements Section
                  Text(
                    'Mes Événements',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (myEventCount == 0)
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
                          height: 250, // Adjust height to ensure space for dots
                          child: PageView.builder(
                            controller: _myEventsPageController,
                            itemCount: (myEventCount / 3).ceil(),
                            onPageChanged: (int page) {
                              setState(() {
                                _currentMyEventsPage = page;
                              });
                            },
                            itemBuilder: (context, index) {
                              final startIndex = index * 3;
                              final endIndex = startIndex + 3;
                              final eventsToShow = homeState.myEvents.sublist(
                                startIndex,
                                endIndex > myEventCount
                                    ? myEventCount
                                    : endIndex,
                              );
                              return SingleChildScrollView(
                                child: Column(
                                  children: _buildEventList(eventsToShow, context),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            (myEventCount / 3).ceil(),
                            (index) => buildDot(index, _currentMyEventsPage),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // Événements Créés Section
                  Text(
                    'Événements Créés',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (createdEventCount == 0)
                    const Center(
                      child: Text(
                        'Aucun événement créé à afficher pour le moment',
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
                          height: 250, // Adjust height to ensure space for dots
                          child: PageView.builder(
                            controller: _createdEventsPageController,
                            itemCount: (createdEventCount / 3).ceil(),
                            onPageChanged: (int page) {
                              setState(() {
                                _currentCreatedEventsPage = page;
                              });
                            },
                            itemBuilder: (context, index) {
                              final startIndex = index * 3;
                              final endIndex = startIndex + 3;
                              final eventsToShow =
                                  homeState.createdEvents.sublist(
                                startIndex,
                                endIndex > createdEventCount
                                    ? createdEventCount
                                    : endIndex,
                              );
                              return SingleChildScrollView(
                                child: Column(
                                  children: _buildEventList(eventsToShow, context),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            (createdEventCount / 3).ceil(),
                            (index) => buildDot(index, _currentCreatedEventsPage),
                          ),
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

  List<Widget> _buildEventList(List<Event> events, BuildContext context) {
    return events.map((event) {
      final eventStart = event.dateStart.isNotEmpty
          ? DateTime.parse(event.dateStart)
          : null;
      final eventEnd = event.dateEnd.isNotEmpty
          ? DateTime.parse(event.dateEnd)
          : null;

      final eventStartDate = eventStart != null
          ? DateFormat.yMMMd().format(eventStart)
          : 'Undefined';
      final eventStartTime = eventStart != null
          ? DateFormat.Hm().format(eventStart)
          : '';
      final eventEndDate = eventEnd != null
          ? DateFormat.yMMMd().format(eventEnd)
          : 'Undefined';
      final eventEndTime = eventEnd != null
          ? DateFormat.Hm().format(eventEnd)
          : '';

      return GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          EventScreen.routeName,
          arguments: event.id,
        ),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
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
                    color: Color(0xFF6058E9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.place,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget buildDot(int index, int currentPage) {
    return Container(
      height: 8,
      width: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: currentPage == index
            ? const Color(0xFF6058E9)
            : const Color(0xFFC4C4C4),
      ),
    );
  }
}

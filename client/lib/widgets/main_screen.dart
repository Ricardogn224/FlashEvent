import 'package:flutter/material.dart';
import 'package:flutter_flash_event/home/home_screen.dart';
import 'package:flutter_flash_event/Invitation/invitation_screen.dart';
import 'package:flutter_flash_event/explore/explore_screen.dart';
import 'package:flutter_flash_event/notifications/notifications_screen.dart';
import 'package:flutter_flash_event/MessageChat/message_chat_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const InvitationScreen(),
    const ExploreScreen(),
    const NotificationsScreen(),
    const MessageChatScreen(id: 1),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print('Selected index: $index');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages.map((page) {
          return Navigator(
            onGenerateRoute: (routeSettings) {
              return MaterialPageRoute(
                builder: (context) => page,
              );
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF6058E9),
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Invitations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}

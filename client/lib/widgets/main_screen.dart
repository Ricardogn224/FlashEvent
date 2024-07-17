import 'package:flutter/material.dart';
import 'package:flutter_flash_event/home/home_screen.dart';
import 'package:flutter_flash_event/Invitation/invitation_screen.dart';
import 'package:flutter_flash_event/notifications/notifications_screen.dart';
import 'package:flutter_flash_event/MessageChat/message_chat_screen.dart';
import 'package:flutter_flash_event/admin/admin_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_flash_event/login/login_screen.dart';
import 'dart:async';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';

  final String userRole;

  MainScreen({required this.userRole});


  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkTokenValidity();
    _startTokenCheckTimer();
    // Initialize pages based on userRole
    _pages = [
      const HomeScreen(),
      const InvitationScreen(),
      if (widget.userRole == 'AdminPlatform') const AdminHomeDesktop(),
      const NotificationsScreen(),
      const MessageChatScreen(id: 1),
    ];
  }

  Future<void> _checkTokenValidity() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  void _startTokenCheckTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await _checkTokenValidity();
    });
  }

  void _onItemTapped(int index) {
    // If the user is trying to access the admin page without the role, do nothing
    if (index == 2 && widget.userRole != 'AdminPlatform') {
      // Optionally, show a message or alert
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Access denied: Admins only')),
      );
      return;
    }


    setState(() {
      _selectedIndex = index;
    });
    print('Selected index: $index');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Invitations',
          ),
          if (widget.userRole == 'AdminPlatform')
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(

            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}

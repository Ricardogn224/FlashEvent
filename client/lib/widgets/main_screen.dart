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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkTokenValidity();
    _startTokenCheckTimer();
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
    // Si l'utilisateur essaie d'accéder à la page admin sans le rôle approprié, ne rien faire
    if (index == 2 && widget.userRole != 'AdminPlatform') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Accès refusé: réservé aux administrateurs')),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
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
        children: [
          HomeScreen(),
          InvitationScreen(),
          if (widget.userRole == 'AdminPlatform') AdminHomeDesktop(),
          NotificationsScreen(),
          MessageChatScreen(id: 1),
        ],
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

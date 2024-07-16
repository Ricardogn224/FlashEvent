import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({required this.child, Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    print("Item tapped: $index");

    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      // Navigate to different screens based on the selected index
      switch (index) {
        case 0:
          print("Navigating to: /home");
          Navigator.pushNamed(context, '/home');
          break;
        case 1:
          print("Navigating to: /connections");
          Navigator.pushNamed(context, '/connections');
          break;
        case 2:
          print("Navigating to: /explore");
          Navigator.pushNamed(context, '/explore');
          break;
        case 3:
          print("Navigating to: /notifications");
          Navigator.pushNamed(context, '/notifications');
          break;
        case 4:
          print("Navigating to: /messages");
          Navigator.pushNamed(context, '/messages');
          break;
        default:
          print("Unknown index: $index");
      }
    } else {
      print("Selected index is the same as current index: $_selectedIndex");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF6058E9),
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Acceuil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Connections',
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

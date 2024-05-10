// import 'package:flutter/material.dart';
// import 'login_screen.dart';
// import 'events_screen.dart';
// import 'messages_screen.dart';
// import 'event_details_screen.dart';
//
// import 'package:flutter_flash_event/widgets/bottom_navigation_bar.dart'; // Assurez-vous que ce composant est correctement défini
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//
//   // Liste des widgets à afficher dans le body en fonction de l'index
//   final List<Widget> _pageWidgets = [
//     EventsScreen(),
//     MessagesScreen(),
//     LoginScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Event manager'),
//       ),
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _pageWidgets,
//       ),
//       bottomNavigationBar: CustomBottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index; // Met à jour l'index actuel et le widget affiché
//           });
//         },
//       ),
//     );
//   }
// }

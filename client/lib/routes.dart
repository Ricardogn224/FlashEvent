import 'package:flutter/material.dart';
import 'package:flutter_flash_event/Invitation/invitation_screen.dart';
import 'package:flutter_flash_event/MessageChat/message_chat_screen.dart';
import 'package:flutter_flash_event/chatRoom/chat_room_screen.dart';
import 'package:flutter_flash_event/eventParty/event_details_screen.dart';
import 'package:flutter_flash_event/formEventParty/form_event_party_screen.dart';
import 'package:flutter_flash_event/formItemEvent/form_item_event_screen.dart';
import 'package:flutter_flash_event/formParticipant/form_participant_screen.dart';
import 'package:flutter_flash_event/formTransportation/form_transportation_screen.dart';
import 'package:flutter_flash_event/home/home_screen.dart';
import 'package:flutter_flash_event/itemEvent/item_event_screen.dart';
import 'package:flutter_flash_event/participant/participant_screen.dart';
import 'package:flutter_flash_event/screens/my_account_screen.dart';
import 'package:flutter_flash_event/transportation/transportation_screen.dart';
import 'login/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/admin_home_desktop_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {

  final args = settings.arguments;
  switch (settings.name) {
    case '/login':
      return MaterialPageRoute(builder: (_) => LoginScreen());
    case '/register':
      return MaterialPageRoute(builder: (_) => RegisterScreen());
    case '/home':
      return MaterialPageRoute(builder: (_) => HomeScreen());
    case InvitationScreen.routeName:
      return MaterialPageRoute(builder: (_) => InvitationScreen());
    case EventScreen.routeName:
      return MaterialPageRoute(builder: (context) => EventScreen(id: args as int));
    case ParticipantScreen.routeName:
      return MaterialPageRoute(builder: (context) => ParticipantScreen(id: args as int));
    case FormParticipantScreen.routeName:
      return MaterialPageRoute(builder: (context) => FormParticipantScreen(eventId: args as int));
    case ChatRoomScreen.routeName:
      return MaterialPageRoute(builder: (context) => ChatRoomScreen(id: args as int));
    case MessageChatScreen.routeName:
      return MaterialPageRoute(builder: (context) => MessageChatScreen(id: args as int));
    case ItemEventScreen.routeName:
      return MaterialPageRoute(builder: (context) => ItemEventScreen(id: args as int));
    case TransportationScreen.routeName:
      return MaterialPageRoute(builder: (context) => TransportationScreen(id: args as int));
    case FormItemEventScreen.routeName:
      return MaterialPageRoute(builder: (context) => FormItemEventScreen(eventId: args as int));
    case FormTransportationScreen.routeName:
      return MaterialPageRoute(builder: (context) => FormTransportationScreen(eventId: args as int));
    case '/event_new':
      return MaterialPageRoute(builder: (_) => BlocFormEventScreen());
    case '/admin':
      return MaterialPageRoute(builder: (_) => AdminHomeDesktop());
    case '/manage-users':
      return MaterialPageRoute(builder: (_) => ManageUsersScreen());
    case '/manage-events':
      return MaterialPageRoute(builder: (_) => ManageEventsScreen());
    case '/my-account':
      return MaterialPageRoute(builder: (_) => MyAccountScreen());
    default:
      return MaterialPageRoute(builder: (_) => SplashScreen());
  }
}

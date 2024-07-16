import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/admin/admin_event_new_screen.dart';
import 'package:flutter_flash_event/admin/admin_feature_screen.dart';
import 'package:flutter_flash_event/admin/admin_home_screen.dart';
import 'package:flutter_flash_event/Invitation/invitation_screen.dart';
import 'package:flutter_flash_event/MessageChat/message_chat_screen.dart';
import 'package:flutter_flash_event/admin/admin_event_edit_screen.dart';
import 'package:flutter_flash_event/admin/admin_event_screen.dart';
import 'package:flutter_flash_event/admin/admin_user_add_oarticipant.dart';
import 'package:flutter_flash_event/admin/admin_user_new_screen.dart';
import 'package:flutter_flash_event/admin/admin_user_screen.dart';
import 'package:flutter_flash_event/admin/admin_user_edit_screen.dart';
import 'package:flutter_flash_event/chatRoom/chat_room_screen.dart';
import 'package:flutter_flash_event/core/models/chatRoom.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/eventParty/event_details_screen.dart';
import 'package:flutter_flash_event/formChatRoom/chat_room_add_participant.dart';
import 'package:flutter_flash_event/formChatRoom/form_chat_room_screen.dart';
import 'package:flutter_flash_event/formItemEvent/form_item_event_screen.dart';
import 'package:flutter_flash_event/formParticipant/form_participant_screen.dart';
import 'package:flutter_flash_event/formTransportation/form_transportation_screen.dart';
import 'package:flutter_flash_event/home/home_screen.dart';
import 'package:flutter_flash_event/itemEvent/item_event_screen.dart';
import 'package:flutter_flash_event/myAccount/my_account_screen.dart';
import 'package:flutter_flash_event/participant/participant_screen.dart';
import 'package:flutter_flash_event/transportation/transport_start_edit_screen.dart';
import 'package:flutter_flash_event/transportation/transportation_screen.dart';
import 'package:flutter_flash_event/formEventCreate/form_event_create_screen.dart';
import 'package:flutter_flash_event/formEventCreate/bloc/form_event_create_bloc.dart';
import 'login/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case '/login':
      return MaterialPageRoute(builder: (_) => LoginScreen());
    case '/register':
      return MaterialPageRoute(builder: (_) => const RegisterScreen());
    case '/home':
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case AdminHomeDesktop.routeName:
      return MaterialPageRoute(builder: (_) => const AdminHomeDesktop());
    case AdminUserScreen.routeName:
      return MaterialPageRoute(builder: (_) => const AdminUserScreen());
    case AdminEventScreen.routeName:
      return MaterialPageRoute(builder: (_) => const AdminEventScreen());
    case AdminEventNewScreen.routeName:
      return MaterialPageRoute(builder: (_) => const AdminEventNewScreen());
    case AdminUserNewScreen.routeName:
      return MaterialPageRoute(builder: (_) => const AdminUserNewScreen());
    case InvitationScreen.routeName:
      return MaterialPageRoute(builder: (_) => const InvitationScreen());
    case EventScreen.routeName:
      return MaterialPageRoute(builder: (context) => EventScreen(id: args as int));
    case ParticipantScreen.routeName:
      return MaterialPageRoute(builder: (context) => ParticipantScreen(id: args as int));
    case AdminUserEditScreen.routeName:
      return MaterialPageRoute(builder: (context) => AdminUserEditScreen(id: args as int));
    case AdminEventEditScreen.routeName:
      return MaterialPageRoute(builder: (context) => AdminEventEditScreen(eventId: args as int));
    case AdminFeatureScreen.routeName:
      return MaterialPageRoute(builder: (context) => AdminFeatureScreen());
    case FormParticipantScreen.routeName:
      return MaterialPageRoute(builder: (context) => FormParticipantScreen(eventId: args as int));
    case AdminUserAddParticipantScreen.routeName:
      return MaterialPageRoute(builder: (context) => AdminUserAddParticipantScreen(eventId: args as int));
    case ChatRoomScreen.routeName:
      return MaterialPageRoute(builder: (context) => ChatRoomScreen(id: args as int));
    case FormChatRoomScreen.routeName:
      return MaterialPageRoute(builder: (context) => FormChatRoomScreen(eventId: args as int));
    case ChatRoomAddParticipantScreen.routeName:
      return MaterialPageRoute(builder: (context) => ChatRoomAddParticipantScreen(chatRoom: args as ChatRoom));
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
    case TransportStartEditScreen.routeName:
      return MaterialPageRoute(builder: (context) => TransportStartEditScreen(event: args as Event));
    case FormEventCreateScreen.routeName:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => FormEventCreateBloc(),
          child: const FormEventCreateScreen(),
        ),
      );
    case '/my-account':
      return MaterialPageRoute(builder: (_) => const MyAccountScreen());
    default:
      return MaterialPageRoute(builder: (_) => SplashScreen());
  }
}

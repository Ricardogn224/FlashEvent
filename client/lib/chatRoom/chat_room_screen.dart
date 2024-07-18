import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/chatRoom/bloc/chat_room_bloc.dart';
import 'package:flutter_flash_event/MessageChat/message_chat_screen.dart';
import 'package:flutter_flash_event/chatRoom/chat_room_participant_screen.dart';
import 'package:flutter_flash_event/formChatRoom/chat_room_add_participant.dart';
import 'package:flutter_flash_event/formChatRoom/form_chat_room_screen.dart';

class ChatRoomScreen extends StatelessWidget {
  static const String routeName = '/chat-room';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int id;

  const ChatRoomScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatRoomBloc()..add(ChatRoomDataLoaded(id: id)),
      child: BlocBuilder<ChatRoomBloc, ChatRoomState>(
        builder: (context, state) {
          final chatRooms = state.chatRooms;
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text('Discussions'),
              ),
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  if (state.status == ChatRoomStatus.loading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (state.status == ChatRoomStatus.success && chatRooms != null)
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          final chatRoom = state.chatRooms?[index];
                          return ListTile(
                            leading: Icon(Icons.person),
                            title: Text(chatRoom!.name),
                            subtitle: Text('Nom: ${chatRoom.name}'),
                            onTap: () => MessageChatScreen.navigateTo(context, id: chatRoom.id),
                            trailing: IconButton(
                              icon: Icon(Icons.person_add),
                              onPressed: () => ChatRoomParticipantScreen.navigateTo(
                                context,
                                id: chatRoom.id,
                              ),
                            ),
                          );
                        },
                        itemCount: state.chatRooms?.length,
                      ),
                    ),
                  FloatingActionButton(
                    onPressed: () {
                      FormChatRoomScreen.navigateTo(context, id: id);
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/MessageChat/bloc/message_chat_bloc.dart';

class MessageChatScreen extends StatelessWidget {
  static const String routeName = '/message';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int id;

  const MessageChatScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessageChatBloc()..add(MessageChatDataLoaded(id: id)),
      child: BlocBuilder<MessageChatBloc, MessageChatState>(
        builder: (context, state) {
          final messageChats = state.messagesChats;
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text('Part'),
              ),
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  if (state.status == MessageChatStatus.loading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (state.status == MessageChatStatus.success && messageChats != null)
                    Expanded( // Add Expanded here
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          final messageChat = state.messagesChats?[index];
                          return ListTile(
                            leading: Icon(Icons.person),
                            title: Text(messageChat!.content),
                            subtitle: Text('Nom: ${messageChat.username}'),
                          );
                        },
                        itemCount: state.messagesChats?.length,
                      ),
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

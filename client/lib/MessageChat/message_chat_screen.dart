import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/MessageChat/bloc/message_chat_bloc.dart';
import 'package:intl/intl.dart';

class MessageChatScreen extends StatelessWidget {
  static const String routeName = '/message';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int id;

  const MessageChatScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return BlocProvider(
      create: (context) => MessageChatBloc()..add(MessageChatDataLoaded(id: id)),
      child: BlocBuilder<MessageChatBloc, MessageChatState>(
        builder: (context, state) {
          final messageChats = state.messagesChats;
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text('HIHOU'),
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
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          final messageChat = state.messagesChats?[index];
                          return ListTile(
                            leading: Icon(Icons.person),
                            title: Text(messageChat!.content),
                            subtitle: Text(
                              '${messageChat.username}\n${DateFormat.yMMMd().add_jm().format(messageChat.timestamp)}',
                            ),
                            isThreeLine: true, // Ensure there is space for the timestamp
                          );
                        },
                        itemCount: state.messagesChats?.length,
                      ),
                    ),
                  if (state.status == MessageChatStatus.success)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Enter your message...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              if (_controller.text.isNotEmpty) {
                                context.read<MessageChatBloc>().add(
                                  MessageChatAdded(
                                    content: _controller.text,
                                    chatRoomId: id,
                                    email: '',
                                  ),
                                );
                                _controller.clear();
                              }
                            },
                          ),
                        ],
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
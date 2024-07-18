import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/chatRoom/bloc/chat_room_bloc.dart';

class ChatRoomParticipantScreen extends StatelessWidget {
  static const String routeName = '/chat-room-participant';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int id;

  const ChatRoomParticipantScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatRoomBloc()..add(ChatRoomParticipantDataLoaded(id: id)),
      child: BlocBuilder<ChatRoomBloc, ChatRoomState>(
        builder: (context, state) {
          final emails = state.emails;
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text('Ajouter participant à la discussion'),
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
                  if (state.status == ChatRoomStatus.success && emails != null)
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          final email = state.emails?[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person),
                                    SizedBox(width: 16.0),
                                    Text(email ?? ''),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    BlocProvider.of<ChatRoomBloc>(context).add(
                                      ParticipantSubmitEvent(
                                        chatRoomId: id,
                                        email: email!,
                                        onSuccess: () {
                                          BlocProvider.of<ChatRoomBloc>(context)
                                              .add(ChatRoomParticipantDataLoaded(id: id));
                                        },
                                        onError: (errorMessage) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(errorMessage)),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: state.emails?.length,
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

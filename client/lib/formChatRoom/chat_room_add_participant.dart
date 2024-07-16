import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/core/models/chatRoom.dart';
import 'package:flutter_flash_event/formChatRoom/bloc/form_chat_room_bloc.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/participant/participant_screen.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flash_event/home/home_screen.dart';

class ChatRoomAddParticipantScreen extends StatelessWidget {
  static const String routeName = '/chat-room-add-participant';

  static navigateTo(BuildContext context, {required ChatRoom chatRoom}) {
    Navigator.of(context).pushNamed(routeName, arguments: chatRoom);
  }

  final ChatRoom chatRoom;

  const ChatRoomAddParticipantScreen({super.key, required this.chatRoom});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormChatRoomBloc()..add(InitEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Form Validation'),
        ),
        body: BlocBuilder<FormChatRoomBloc, FormChatRoomState>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: state.formKey,
                child: Column(
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        BlocProvider.of<FormChatRoomBloc>(context)
                            .add(FetchEmailSuggestions(query: textEditingValue.text, chatRoomId: chatRoom.id));
                        return state.emailSuggestions.where((String option) {
                          return option.contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        BlocProvider.of<FormChatRoomBloc>(context)
                            .add(EmailChanged(email: BlocFormItem(value: selection)));
                      },
                      fieldViewBuilder: (
                          BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted,
                          ) {
                        return CustomFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          hintText: 'Email',
                          onChange: (val) {
                            BlocProvider.of<FormChatRoomBloc>(context)
                                .add(EmailChanged(email: BlocFormItem(value: val!)));
                          },
                          validator: (val) {
                            return state.email.error;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<FormChatRoomBloc>(context).add(FormParticipantSubmitEvent(
                              chatRoomId: chatRoom.id,
                              onSuccess: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => ParticipantScreen(id: chatRoom.eventId)),
                                );
                              },
                              onError: (errorMessage) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMessage)),
                                );
                              },
                            ));
                          },
                          child: const Text('SUBMIT'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<FormChatRoomBloc>(context).add(const FormResetEvent());
                          },
                          child: const Text('RESET'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

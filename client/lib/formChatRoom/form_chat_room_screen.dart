import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/chatRoom/chat_room_screen.dart';
import 'package:flutter_flash_event/formChatRoom/bloc/form_chat_room_bloc.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flash_event/home/home_screen.dart';

class FormChatRoomScreen extends StatelessWidget {
  static const String routeName = '/new-chat-room';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int eventId;

  const FormChatRoomScreen({super.key, required this.eventId});

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
                    CustomFormField(
                      hintText: 'Nombre de places',
                      onChange: (val) {
                        BlocProvider.of<FormChatRoomBloc>(context).add(
                            NameChanged(
                                name: BlocFormItem(value: val!)));
                      },
                      validator: (val) {
                        return state.name.error;
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<FormChatRoomBloc>(context).add(FormSubmitEvent(
                              eventId: eventId,
                              onSuccess: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => ChatRoomScreen(id: eventId)),
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

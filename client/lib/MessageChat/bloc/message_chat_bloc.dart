import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/core/services/message_services.dart';

part 'message_chat_event.dart';
part 'message_chat_state.dart';

class MessageChatBloc extends Bloc<MessageChatEvent, MessageChatState> {
  MessageChatBloc() : super(MessageChatState()) {
    on<MessageChatDataLoaded>((event, emit) async {
      emit(state.copyWith(status: MessageChatStatus.loading));

      try {
        final messageChats = await MessageServices.getMessagesByChat(id: event.id);
        print(messageChats);
        emit(state.copyWith(status: MessageChatStatus.success, messagesChats: messageChats));
      } on ApiException catch (error) {
        emit(state.copyWith(status: MessageChatStatus.error, errorMessage: 'An error occurred'));
      }
    });

    on<MessageChatAdded>((event, emit) async {
      try {
        final message = Message(
          content: event.content,
          email: '',
          chatRoomId: event.chatRoomId,
          id: 0,
          userId: 0,
          username: '',
          timestamp: DateTime.now(),
        );
        await MessageServices.sendMessage(message);

        // Assuming you want to fetch the messages again after adding a new one
        final messageChats = await MessageServices.getMessagesByChat(id: event.chatRoomId);
        emit(state.copyWith(status: MessageChatStatus.success, messagesChats: messageChats));
      } catch (error) {
        emit(state.copyWith(status: MessageChatStatus.error, errorMessage: 'Failed to send message'));
      }
    });
  }
}
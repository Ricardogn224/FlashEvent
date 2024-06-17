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
        emit(state.copyWith(status: MessageChatStatus.success, messagesChats: messageChats));
      } on ApiException catch (error) {
        emit(state.copyWith(status: MessageChatStatus.error, errorMessage: 'An error occurred'));
      }
    });
  }
}
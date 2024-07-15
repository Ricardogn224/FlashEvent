import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/chatRoom.dart';
import 'package:flutter_flash_event/core/services/chat_room_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_room_event.dart';
part 'chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  ChatRoomBloc() : super(ChatRoomState()) {
    on<ChatRoomDataLoaded>((event, emit) async {
      emit(state.copyWith(status: ChatRoomStatus.loading));

      try {
        final chatRooms = await ChatRoomServices.getUserChatRooms(event.id);
        emit(state.copyWith(status: ChatRoomStatus.success, chatRooms: chatRooms));
      } on ApiException catch (error) {
        emit(state.copyWith(status: ChatRoomStatus.error, errorMessage: 'An error occurred'));
      }
    });
  }
}
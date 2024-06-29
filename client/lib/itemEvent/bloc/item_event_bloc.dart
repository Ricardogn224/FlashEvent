import 'package:flutter/cupertino.dart';
import 'package:flutter_flash_event/core/exceptions/api_exception.dart';
import 'package:flutter_flash_event/core/models/itemEvent.dart';
import 'package:flutter_flash_event/core/services/item_services.dart';
import 'package:flutter_flash_event/core/services/user_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event_item_event.dart';
part 'item_event_state.dart';

class ItemEventBloc extends Bloc<EventItemEvent, ItemEventState> {
  ItemEventBloc() : super(ItemEventState()) {
    on<ItemEventDataLoaded>((event, emit) async {
      emit(state.copyWith(status: ItemEventStatus.loading));

      try {
        final itemEvents = await ItemServices.getItemsByEvent(id: event.id);
        emit(state.copyWith(status: ItemEventStatus.success, itemEvents: itemEvents));
      } on ApiException catch (error) {
        emit(state.copyWith(status: ItemEventStatus.error, errorMessage: 'An error occurred'));
      }
    });
  }
}
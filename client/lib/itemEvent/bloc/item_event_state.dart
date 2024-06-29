part of 'item_event_bloc.dart';


enum ItemEventStatus { initial, loading, success, error }

class ItemEventState {
  final ItemEventStatus status;
  final List<ItemEvent>? itemEvents;
  final String? errorMessage;

  ItemEventState({
    this.status = ItemEventStatus.initial,
    this.itemEvents,
    this.errorMessage,
  });

  ItemEventState copyWith({
    ItemEventStatus? status,
    List<ItemEvent>? itemEvents,
    String? errorMessage,
  }) {
    return ItemEventState(
      status: status ?? this.status,
      itemEvents: itemEvents ?? this.itemEvents,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

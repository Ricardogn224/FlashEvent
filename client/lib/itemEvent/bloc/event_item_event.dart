part of 'item_event_bloc.dart';

@immutable
sealed class EventItemEvent {}

class ItemEventDataLoaded extends EventItemEvent {
  final int id;

  ItemEventDataLoaded({required this.id});
}

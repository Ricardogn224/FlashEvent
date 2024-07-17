part of 'event_party_bloc.dart';

@immutable
sealed class EventPartyEvent {}

class EventPartyDataLoaded extends EventPartyEvent {
  final int id;

  EventPartyDataLoaded({required this.id});
}

class UpdateParticipant extends EventPartyEvent {
  final Participant participant;
  final bool newVal;

  UpdateParticipant({required this.participant, required this.newVal});
}

class FetchEmailSuggestions extends EventPartyEvent {
  final String query;
  final int eventId;

  FetchEmailSuggestions({required this.query, required this.eventId});

  @override
  List<Object> get props => [query];
}

class EmailChanged extends EventPartyEvent {
  EmailChanged({required this.email});
  final BlocFormItem email;
  @override
  List<Object> get props => [email];
}

class FormSubmitEvent extends EventPartyEvent {
  final VoidCallback onSuccess;
  final Function(String) onError;
  final Participant participant;

  FormSubmitEvent({required this.onSuccess, required this.onError, required this.participant});

  @override
  List<Object> get props => [onSuccess, onError];
}
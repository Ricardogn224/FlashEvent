class ItemEvent {
  final int id;
  final String name;
  final int userId;
  final int eventId;
  final String firstname;
  final String lastname;

  ItemEvent({
    required this.id,
    required this.name,
    required this.userId,
    required this.eventId,
    required this.firstname,
    required this.lastname,
  });

  factory ItemEvent.fromJson(Map<String, dynamic> json) {
    return ItemEvent(
      id: json['id'],
      name: json['name'],
      userId: json['user_id'],
      eventId: json['event_id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
    );
  }
}


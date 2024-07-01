class ChatRoom {
  final int id;
  final String name;
  final int eventId;

  ChatRoom({
    required this.id,
    required this.name,
    required this.eventId,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      eventId: json['event_id'],
    );
  }
}
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'event_id': eventId,
    };
  }
}


class ChatRoomParticipant {
  final int id;
  final int userId;
  final int chatRoomId;
  final String roomType;

  ChatRoomParticipant({
    required this.id,
    required this.userId,
    required this.chatRoomId,
    required this.roomType,
  });

  factory ChatRoomParticipant.fromJson(Map<String, dynamic> json) {
    return ChatRoomParticipant(
      id: json['id'],
      userId: json['user_id'],
      chatRoomId: json['chat_room_id'],
      roomType: json['room_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'chat_room_id': chatRoomId,
      'room_type': roomType,
    };
  }
}

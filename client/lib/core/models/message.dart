class Message {
  final int id;
  final String content;
  final int chatRoomId;
  final int userId;
  final String username;
  final String email;

  Message({
    required this.id,
    required this.content,
    required this.chatRoomId,
    required this.userId,
    required this.username,
    required this.email,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      chatRoomId: json['chat_room_id'],
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
    );
  }
}
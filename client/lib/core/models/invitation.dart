class Invitation {
  final int participantId;
  final String eventName;
  final int userId;
  final int eventId;

  Invitation({
    required this.participantId,
    required this.eventName,
    required this.userId,
    required this.eventId,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      participantId: json['participant_id'],
      eventName: json['event_name'],
      userId: json['user_id'],
      eventId: json['event_id'],
    );
  }
}

class InvitationAnswer {
  final int participantId;
  final bool active;

  InvitationAnswer({
    required this.participantId,
    required this.active,
  });

  factory InvitationAnswer.fromJson(Map<String, dynamic> json) {
    return InvitationAnswer(
      participantId: json['participant_id'],
      active: json['active'],
    );
  }
}

class Participant {
  final int id;
  final int userId;
  final int eventId;
  final int transportationId;
  final bool present;


  Participant({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.transportationId,
    required this.present,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      userId: json['user_id'],
      eventId: json['event_id'],
      transportationId: json['transportation_id'],
      present: json['present'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'transportationId': transportationId,
      'present': present,
    };
  }
}

class ParticipantAdd {
  final int id;
  final String email;
  final int eventId;

  ParticipantAdd({
    required this.id,
    required this.email,
    required this.eventId,
  });

  factory ParticipantAdd.fromJson(Map<String, dynamic> json) {
    return ParticipantAdd(
      id: json['id'],
      email: json['email'],
      eventId: json['event_id'],
    );
  }
}


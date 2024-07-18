class Transportation {
  final int id;
  final int seatNumber;
  final int eventId;
  final String vehicle;
  final int userId;
  final String email;

  Transportation({
    required this.id,
    required this.seatNumber,
    required this.eventId,
    required this.vehicle,
    required this.userId,
    required this.email,
  });

  factory Transportation.fromJson(Map<String, dynamic> json) {
    return Transportation(
      id: json['id'],
      seatNumber: json['seat_number'],
      eventId: json['event_id'],
      vehicle: json['vehicle'],
      userId: json['user_id'],
      email: json['email']  as String? ?? '',
    );
  }
}

class UserTransport {
  final int userId;
  final String firstname;
  final String lastname;
  final int participantId;
  final int eventId;
  final String email;
  final int transportationId;

  UserTransport({
    required this.userId,
    required this.firstname,
    required this.lastname,
    required this.participantId,
    required this.eventId,
    required this.email,
    required this.transportationId,
  });

  factory UserTransport.fromJson(Map<String, dynamic> json) {
    return UserTransport(
      userId: json['user_id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      participantId: json['participant_id'],
      eventId: json['event_id'],
      email: json['email'],
      transportationId: json['transportation_id'],
    );
  }
}
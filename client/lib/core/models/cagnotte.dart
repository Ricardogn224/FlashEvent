class Cagnotte {
  final int id;
  final int eventId;
  final double total;

  Cagnotte({
    required this.id,
    required this.eventId,
    required this.total,
  });

  factory Cagnotte.fromJson(Map<String, dynamic> json) {
    return Cagnotte(
      id: json['id'],
      eventId: json['event_id'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'total': total,
    };
  }
}

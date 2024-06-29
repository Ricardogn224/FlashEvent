class Event {
  final int id;
  final String name;
  final String description;
  final String place;
  final String date;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.place,
    required this.date,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      place: json['place'] ?? '',
      date: json['date'] ?? '',
    );
  }
}

class Event {
  final int id;
  final String name;
  final String description;

  Event({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

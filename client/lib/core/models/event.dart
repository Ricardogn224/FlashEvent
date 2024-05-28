class Event {
  final String name;
  final String description;


  Event({
    required this.name,
    required this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      description: json['description'],
    );
  }
}
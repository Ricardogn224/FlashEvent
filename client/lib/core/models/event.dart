class Event {
  final String title;
  final String description;


  Event({
    required this.title,
    required this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      description: json['description'],
    );
  }
}
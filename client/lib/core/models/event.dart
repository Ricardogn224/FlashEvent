class Event {
  final int id;
  final String title;


  Event({
    required this.id,
    required this.title,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
    );
  }
}
class Event {
  final int id;
  final String name;
  final String description;
  final bool transportActive;
  final String transportStart;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.transportActive,
    required this.transportStart,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      transportActive: json['transport_active'] ?? false,
      transportStart: json['transport_start'] ?? 'Indefini',
    );
  }
}

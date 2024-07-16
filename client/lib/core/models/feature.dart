class Feature {
  final int id;
  final String name;
  final bool active;

  Feature({
    required this.id,
    required this.name,
    required this.active,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'],
      name: json['name'],
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'active': active ?? false,
    };
  }
}

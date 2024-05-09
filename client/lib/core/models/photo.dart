class Photo {
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;
  final int albumId;

  Photo({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.albumId,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      albumId: json['albumId'],
    );
  }
}

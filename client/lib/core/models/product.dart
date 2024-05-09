class Product {
  final String title;
  final String description;
  final String thumbnail;

  Product({
    required this.title,
    required this.description,
    required this.thumbnail,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
    );
  }
}

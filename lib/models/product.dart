class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final int categoryId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      imageUrl: (json['image_url'] ?? json['imageUrl']) as String,
      categoryId: (json['category_id'] ?? json['categoryId'] ?? 0) as int,
    );
  }
}

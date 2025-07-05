class Product {
  final int id;
  final String name;
  final double price;
  final double mrp;
  final String description;
  final String imageUrl;
  final int categoryId;
  final String brand;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.mrp,
    required this.description,
    required this.imageUrl,
    required this.categoryId,
    required this.brand,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      mrp: (json['mrp'] as num?)?.toDouble() ??
          (json['price'] as num).toDouble(),
      description: json['description'] as String,
      imageUrl: (json['image_url'] ?? json['imageUrl']) as String,
      categoryId: (json['category_id'] ?? json['categoryId'] ?? 0) as int,
      brand: (json['brand'] ?? '') as String,
      stock: json['stock'] as int? ?? 0,
    );
  }
}

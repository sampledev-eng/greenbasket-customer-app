import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _client = ApiClient();

  Future<List<Product>> fetchProducts() async {
    final data = await _client.products();
    return _parseList(data);
  }

  Future<List<Product>> searchProducts(String query) async {
    final data = await _client.get('/products/search?q=$query');
    return _parseList(data);
  }

  Future<Product> createProduct(
      {required String name,
      required String description,
      required double price,
      required int stock,
      required int categoryId,
      required String imageUrl}) async {
    final data = await _client.addProduct(
        name, description, price, stock, categoryId, imageUrl);
    return Product.fromJson(data as Map<String, dynamic>);
  }

  List<Product> _parseList(dynamic data) {
    return (data as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Removed local product loading now that backend API is available
}

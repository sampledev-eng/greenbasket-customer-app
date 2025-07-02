import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _client = ApiClient();

  Future<List<Product>> fetchProducts() async {
    final data = await _client.loadProducts();
    return data
        .map((e) => Product(
              id: e['id'],
              name: e['name'],
              price: (e['price'] as num).toDouble(),
              description: e['description'],
              imageUrl: e['imageUrl'],
            ))
        .toList();
  }
}

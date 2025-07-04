import '../models/category.dart';
import 'api_client.dart';

class CategoryService {
  final ApiClient _client = ApiClient();

  Future<List<Category>> fetchCategories() async {
    final data = await _client.categories();
    return (data as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Category> createCategory(String name) async {
    final data = await _client.post('/categories', {'name': name});
    return Category.fromJson(data as Map<String, dynamic>);
  }
}

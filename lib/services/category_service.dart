import '../models/category.dart';
import 'api_client.dart';

class CategoryService {
  final ApiClient _client = ApiClient();

  Future<List<Category>> fetchCategories() async {
    try {
      final data = await _client.get('/categories/');
      return (data as List)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [
        Category(id: 1, name: 'Fruits'),
        Category(id: 2, name: 'Vegetables'),
        Category(id: 3, name: 'Dairy'),
      ];
    }
  }

  Future<Category> createCategory(String name) async {
    final data = await _client.post('/categories/', {'name': name});
    return Category.fromJson(data as Map<String, dynamic>);
  }
}

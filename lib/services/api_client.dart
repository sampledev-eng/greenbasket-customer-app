import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  Future<List<dynamic>> loadProducts() async {
    final response = await http.get(
      Uri.parse('https://opulent-space-palm-tree-g4p7xwpj7p9j2g4w-8000.app.github.dev/products'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }
}

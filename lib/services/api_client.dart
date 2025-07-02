// Simple mock API client
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class ApiClient {
  Future<List<dynamic>> loadProducts() async {
    final data = await rootBundle.loadString('assets/products.json');
    return json.decode(data) as List<dynamic>;
  }
}

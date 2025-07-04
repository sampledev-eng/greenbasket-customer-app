import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _client = ApiClient();

  Future<List<Product>> fetchProducts() async {
    try {
      final data = await _client.get('/products/');
      return _parseList(data);
    } catch (_) {
      return _loadLocalProducts();
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final data = await _client.get('/products?search=$query');
      return _parseList(data);
    } catch (_) {
      final all = await _loadLocalProducts();
      return all
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
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

  Future<List<Product>> _loadLocalProducts() async {
    final jsonStr = await rootBundle.loadString('assets/products.json');
    final data = json.decode(jsonStr) as List;
    return data
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

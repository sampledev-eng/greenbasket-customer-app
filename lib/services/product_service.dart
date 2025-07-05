import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/product.dart';
import '../models/review.dart';
import 'api_client.dart';
import 'auth_service.dart';

class ProductService {
  final ApiClient _client = ApiClient();
  final AuthService _auth;
  List<Product>? _cache;

  ProductService(this._auth);

  Future<List<Product>> fetchProducts() async {
    return fetchFiltered();
  }

  Future<List<Product>> fetchFiltered({
    String? brand,
    int? category,
    double? minPrice,
    double? maxPrice,
    String? search,
    String? sort,
  }) async {
    if (_auth.currentUser == null) {
      final list = await _loadLocal();
      return list.where((p) {
        if (brand != null && p.brand != brand) return false;
        if (category != null && p.categoryId != category) return false;
        if (minPrice != null && p.price < minPrice) return false;
        if (maxPrice != null && p.price > maxPrice) return false;
        if (search != null &&
            !p.name.toLowerCase().contains(search.toLowerCase())) {
          return false;
        }
        return true;
      }).toList();
    }
    final params = <String, String>{};
    if (brand != null) params['brand'] = brand;
    if (category != null) params['category'] = '$category';
    if (minPrice != null) params['min_price'] = '$minPrice';
    if (maxPrice != null) params['max_price'] = '$maxPrice';
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (sort != null) params['sort'] = sort;
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final path = query.isEmpty ? '/products' : '/products?$query';
    final data = await _client.get(path);
    return _parseList(data);
  }

  Future<List<Product>> searchProducts(String query) async {
    return fetchFiltered(search: query);
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

  Future<List<Product>> _loadLocal() async {
    if (_cache != null) return _cache!;
    final localJson = await rootBundle.loadString('assets/dummy_products.json');
    final data = json.decode(localJson) as List;
    _cache = _parseList(data);
    return _cache!;
  }

  List<Product> _parseList(dynamic data) {
    return (data as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Review>> fetchReviews(int productId) async {
    final data = await _client.productReviews(productId);
    if (data is List) {
      return data
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<bool> submitReview(int productId, int rating, String comment) async {
    try {
      await _client.addReview(productId, rating, comment);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Local JSON fallback when not authenticated
}

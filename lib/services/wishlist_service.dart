import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'api_client.dart';
import 'auth_service.dart';

class WishlistService extends ChangeNotifier {
  final ApiClient _client = ApiClient();
  AuthService _auth;
  final List<Product> _items = [];

  WishlistService(this._auth);

  void updateAuth(AuthService auth) {
    _auth = auth;
    if (_auth.currentUser != null) {
      load();
    } else {
      _items.clear();
      notifyListeners();
    }
  }

  List<Product> get items => List.unmodifiable(_items);

  bool contains(Product product) => _items.any((p) => p.id == product.id);

  Future<void> toggle(Product product) async {
    if (contains(product)) {
      _items.removeWhere((p) => p.id == product.id);
      if (_auth.currentUser != null) {
        try {
          await _client.removeWishlist(product.id);
        } catch (_) {}
      }
    } else {
      _items.add(product);
      if (_auth.currentUser != null) {
        try {
          await _client.addWishlist(product.id);
        } catch (_) {}
      }
    }
    notifyListeners();
  }

  Future<void> load() async {
    if (_auth.currentUser == null) return;
    try {
      final data = await _client.wishlist();
      if (data is List) {
        _items
          ..clear()
          ..addAll(data.map((e) => Product.fromJson(e as Map<String, dynamic>)));
        notifyListeners();
      }
    } catch (_) {}
  }
}

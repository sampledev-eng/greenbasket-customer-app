import 'package:flutter/foundation.dart';
import '../models/product.dart';

class WishlistService extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);

  bool contains(Product product) =>
      _items.any((p) => p.id == product.id);

  void toggle(Product product) {
    if (contains(product)) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }
}

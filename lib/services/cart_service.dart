import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'api_client.dart';

class CartService extends ChangeNotifier {
  final ApiClient _client = ApiClient();
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final data = await _client.fetchCart();
    if (data is List) {
      _items..clear();
      for (var e in data) {
        final map = e as Map<String, dynamic>;
        final product = Product(
        id: map['id'] as int,
        name: map['name'] as String,
        description: map['description'] as String? ?? '',
        brand: map['brand'] as String? ?? '',
        mrp: (map['mrp'] as num?)?.toDouble() ??    // <-- add this
        (map['price'] as num).toDouble(),
        price: (map['price'] as num).toDouble(),
        imageUrl: map['image_url'] as String? ?? '',
        stock: map['stock'] as int? ?? 0,
        categoryId: map['category_id'] as int? ?? 0,
        );

        final qty = map['quantity'] as int? ?? 1;
        _items.add(CartItem(product: product, quantity: qty));
      }
      
      notifyListeners();
    }
  }

  Future<void> add(Product product) async {
    try {
      await _client.addCart(product.id, 1);
    } catch (_) {}
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  Future<void> updateQuantity(CartItem item, int qty) async {
    try {
      await _client.updateCart(item.product.id, qty);
    } catch (_) {}
    if (qty <= 0) {
      _items.remove(item);
    } else {
      final index = _items.indexOf(item);
      if (index >= 0) {
        _items[index].quantity = qty;
      }
    }
    notifyListeners();
  }

  Future<void> remove(CartItem item) async {
    try {
      await _client.removeCart(item.product.id);
    } catch (_) {}
    _items.remove(item);
    notifyListeners();
  }

  double get total =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems =>
      _items.fold(0, (sum, item) => sum + item.quantity);
}

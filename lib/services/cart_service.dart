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
          id: map['product_id'] as int,
          name: map['name'] as String,
          price: (map['price'] as num).toDouble(),
          description: '',
          imageUrl: '',
        );
        final qty = map['quantity'] as int? ?? 1;
        _items.add(CartItem(product: product, quantity: qty));
      }
      
      notifyListeners();
    }
  }

  Future<void> add(Product product) async {
    await _client.post('/cart/add',
        {'product_id': product.id, 'quantity': 1});
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  double get total =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);
}

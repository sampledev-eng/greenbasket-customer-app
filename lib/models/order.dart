import 'cart_item.dart';

class Order {
  final List<CartItem> items;
  final DateTime date;

  Order({required this.items, required this.date});

  double get total =>
      items.fold(0, (sum, item) => sum + item.totalPrice);
}

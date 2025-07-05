import '../models/order.dart';
import '../models/backend_order.dart';
import '../models/cart_item.dart';
import 'api_client.dart';
import 'notification_service.dart';

class OrderService {
  final ApiClient _client = ApiClient();
  final List<BackendOrder> _orders = [];
  final Map<int, String> _statuses = {};

  List<BackendOrder> get orders => List.unmodifiable(_orders);

  Future<BackendOrder?> createOrder(int addressId, String paymentMode) async {
    final data = await _client.createOrder(addressId, paymentMode);
    if (data is Map<String, dynamic>) {
      final order = BackendOrder.fromJson(data);
      _orders.add(order);
      return order;
    }
    return null;
  }

  Future<String?> checkout(int addressId, List<CartItem> items) async {
    final list = items
        .map((e) => {'product_id': e.product.id, 'quantity': e.quantity})
        .toList();
    final data = await _client.checkout(addressId, list);
    if (data is Map<String, dynamic>) {
      if (data['payment_url'] != null) return data['payment_url'] as String;
      if (data['transaction_id'] != null) {
        return data['transaction_id'].toString();
      }
    }
    return null;
  }

  Future<void> fetchOrders() async {
    final data = await _client.orders();
    if (data is List) {
      final newOrders = data
          .map((e) => BackendOrder.fromJson(e as Map<String, dynamic>))
          .toList();
      for (var order in newOrders) {
        final prev = _statuses[order.orderId];
        if (prev != null && prev != order.status) {
          NotificationService.show(order.orderId, 'Order Update',
              'Order #${order.orderId} is now ${order.status}');
        }
        _statuses[order.orderId] = order.status;
      }
      _orders
        ..clear()
        ..addAll(newOrders);
    }
  }

  Future<dynamic> trackDelivery(int orderId) async {
    return _client.trackDelivery(orderId);
  }
}

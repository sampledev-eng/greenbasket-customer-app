import '../models/order.dart';
import '../models/backend_order.dart';
import 'api_client.dart';

class OrderService {
  final ApiClient _client = ApiClient();
  final List<BackendOrder> _orders = [];

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

  Future<void> fetchOrders() async {
    final data = await _client.orders();
    if (data is List) {
      _orders
        ..clear()
        ..addAll(data
            .map((e) => BackendOrder.fromJson(e as Map<String, dynamic>)));
    }
  }

  Future<dynamic> trackDelivery(int orderId) async {
    return _client.trackDelivery(orderId);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../services/api_client.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late final OrderService _service;
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    final client = Provider.of<ApiClient>(context, listen: false);
    _service = OrderService(client);
    _future = _service.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = _service.orders;
          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text('Order #${order.orderId}'),
                subtitle: Text(order.status),
                onTap: () async {
                  final tracking = await _service.trackDelivery(order.orderId);
                  if (!mounted) return;
                  showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            title: const Text('Delivery Status'),
                            content: Text(tracking.toString()),
                          ));
                },
              );
            },
          );
        },
      ),
    );
  }
}

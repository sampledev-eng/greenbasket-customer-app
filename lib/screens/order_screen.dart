import 'package:flutter/material.dart';
import 'dart:async';
import '../services/order_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderService _service = OrderService();
  late Future<void> _future;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchOrders();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _service.fetchOrders();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

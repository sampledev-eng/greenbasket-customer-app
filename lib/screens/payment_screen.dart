import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/cart_item.dart';
import '../services/order_service.dart';

class PaymentScreen extends StatefulWidget {
  final int addressId;
  final double total;
  final List<CartItem> items;
  const PaymentScreen({
    super.key,
    required this.addressId,
    required this.total,
    required this.items,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = false;

  Future<void> _pay() async {
    setState(() => _loading = true);
    final url = await OrderService()
        .checkout(widget.addressId, widget.items);
    setState(() => _loading = false);
    if (url != null) {
      await launchUrl(Uri.parse(url));
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Payment failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Total: \${widget.total.toStringAsFixed(2)}"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _pay,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Pay with Razorpay'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/order_service.dart';
import 'thank_you_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int addressId;
  final double total;
  const PaymentScreen({super.key, required this.addressId, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = false;

  Future<void> _pay() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    final order = await OrderService().createOrder(widget.addressId, 'cod');
    setState(() => _loading = false);
    if (order != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ThankYouScreen(orderId: order.orderId, eta: '30 mins'),
        ),
      );
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

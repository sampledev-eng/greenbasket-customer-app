import 'package:flutter/material.dart';

class ThankYouScreen extends StatelessWidget {
  final int orderId;
  final String eta;

  const ThankYouScreen({Key? key, required this.orderId, required this.eta})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thank You')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Order #$orderId placed!'),
            Text('ETA: $eta'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Track Order'),
            )
          ],
        ),
      ),
    );
  }
}

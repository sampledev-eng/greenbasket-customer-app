import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/api_client.dart';
import 'thank_you_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final CartItem item = cart.items[index];
                return ListTile(
                  title: Text(item.product.name),
                  subtitle: Text('\$${item.totalPrice.toStringAsFixed(2)} (x${item.quantity})'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => cart.remove(item),
                  ),
                );
              },
            ),
          ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Total: \$${cart.total.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: cart.items.isEmpty
                        ? null
                        : () async {
                            final client = Provider.of<ApiClient>(context, listen: false);
                            final service = OrderService(client);
                            final order = await service.createOrder('123 Street', 'COD');
                            if (order != null && context.mounted) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ThankYouScreen(orderId: order.orderId, eta: '30 mins')));
                            }
                          },
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}

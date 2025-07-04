import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/address_service.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _loading = false;

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
                Text('Items: ${cart.totalItems}'),
                Text('Total: \$${cart.total.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: cart.items.isEmpty || _loading
                      ? null
                      : () async {
                          final controller = TextEditingController();
                          final address = await showDialog<String>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delivery Address'),
                              content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(hintText: 'Address'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, controller.text),
                                  child: const Text('OK'),
                                )
                              ],
                            ),
                          );
                          if (address == null || address.isEmpty) return;
                          setState(() => _loading = true);
                          final addressService = AddressService();
                          final created = await addressService.createAddress(address);
                          if (created == null) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to save address')),
                              );
                            }
                            setState(() => _loading = false);
                            return;
                          }
                          setState(() => _loading = false);
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(
                                  addressId: created.id, total: cart.total),
                            ),
                          );
                        },
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Checkout'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

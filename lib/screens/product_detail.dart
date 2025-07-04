import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class ProductDetail extends StatefulWidget {
  final Product product;
  const ProductDetail({super.key, required this.product});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int _rating = 0;
  final List<Map<String, dynamic>> _comments = [];
  final TextEditingController _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.product.imageUrl, height: 200),
            const SizedBox(height: 16),
            Text(widget.product.name,
                style: Theme.of(context).textTheme.titleLarge),
            Text('\$${widget.product.price.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            Text(widget.product.description),
            const SizedBox(height: 16),
            Row(
              children: List.generate(5, (i) {
                return IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                  ),
                  onPressed: () => setState(() => _rating = i + 1),
                );
              }),
            ),
            TextField(
              controller: _commentCtrl,
              decoration: const InputDecoration(labelText: 'Comment'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_rating == 0 || _commentCtrl.text.isEmpty) return;
                setState(() {
                  _comments.add({
                    'rating': _rating,
                    'text': _commentCtrl.text,
                  });
                  _rating = 0;
                  _commentCtrl.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review added')));
              },
              child: const Text('Submit Review'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final c = _comments[index];
                  return ListTile(
                    title: Row(
                      children: List.generate(
                          5,
                          (i) => Icon(i < c['rating'] ? Icons.star : Icons.star_border,
                              color: Colors.orange, size: 16)),
                    ),
                    subtitle: Text(c['text']),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await cart.add(widget.product);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart')));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}

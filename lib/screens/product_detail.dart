import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';
import '../models/review.dart';

class ProductDetail extends StatefulWidget {
  final Product product;
  const ProductDetail({super.key, required this.product});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late final ProductService _service;
  int _rating = 0;
  final TextEditingController _commentCtrl = TextEditingController();
  Future<List<Review>>? _reviewsFuture;
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    _service = ProductService(auth);
    _reviewsFuture = _load();
  }

  Future<List<Review>> _load() async {
    final data = await _service.fetchReviews(widget.product.id);
    _reviews = data;
    return _reviews;
  }

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
            if (widget.product.mrp > widget.product.price)
              Text('MRP: \$${widget.product.mrp.toStringAsFixed(2)}',
                  style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey)),
            Text('\$${widget.product.price.toStringAsFixed(2)}'),
            Text('Stock: ${widget.product.stock}'),
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
              onPressed: () async {
                if (_rating == 0 || _commentCtrl.text.isEmpty) return;
                final ok = await _service.submitReview(
                    widget.product.id, _rating, _commentCtrl.text);
                if (ok) {
                  _commentCtrl.clear();
                  setState(() {
                    _rating = 0;
                    _reviewsFuture = _load();
                  });
                }
              },
              child: const Text('Submit Review'),
            ),
            Expanded(
              child: FutureBuilder<List<Review>>(
                future: _reviewsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final reviews = snapshot.data ?? [];
                  if (reviews.isEmpty) {
                    return const Center(child: Text('No reviews yet'));
                  }
                  return ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final c = reviews[index];
                      final rating = c.rating;
                      final text = c.comment;
                      return ListTile(
                        title: Row(
                          children: List.generate(
                              5,
                              (i) => Icon(i < rating ? Icons.star : Icons.star_border,
                                  color: Colors.orange, size: 16)),
                        ),
                        subtitle: Text(text),
                      );
                    },
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

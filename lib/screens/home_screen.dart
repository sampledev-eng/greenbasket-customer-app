import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../services/api_client.dart';
import '../models/category.dart';
import 'cart_screen.dart';
import 'product_detail.dart';
import 'order_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProductService _productService;
  late final CategoryService _categoryService;
  final TextEditingController _search = TextEditingController();
  late Future<List<Product>> _productsFuture;
  List<Category> _categories = [];
  List<Product> _allProducts = [];

  @override
  void initState() {
    super.initState();
    final client = Provider.of<ApiClient>(context, listen: false);
    _productService = ProductService(client);
    _categoryService = CategoryService(client);
    _productsFuture = _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = Provider.of<CartService>(context, listen: false);
      cart.load();
    });
  }

  Future<List<Product>> _load() async {
    final products = await _productService.fetchProducts();
    _allProducts = products;
    _categories = await _categoryService.fetchCategories();
    return products;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('GreenBasket'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cart.items.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        cart.items.length.toString(),
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const OrderScreen())),
          )
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No products'));
          }
          final products = snapshot.data!;
          final filtered = products
              .where((p) => p.name
                  .toLowerCase()
                  .contains(_search.text.toLowerCase()))
              .toList();
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                      hintText: 'Search products', prefixIcon: Icon(Icons.search)),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categories
                      .map((c) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Chip(label: Text(c.name)),
                          ))
                      .toList(),
                ),
              ),
              ...filtered.map((product) => ListTile(
                    leading: Image.network(
                      product.imageUrl,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50),
                    ),
                    title: Text(product.name),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProductDetail(product: product)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () async => cart.add(product),
                    ),
                  ))
            ],
          );
        },
      ),
    );
  }
}

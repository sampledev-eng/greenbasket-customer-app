import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
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
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  late Future<List<Product>> _productsFuture;
  List<Category> _categories = [];
  List<Product> _allProducts = [];
  int? _selectedCategory;

  @override
  void initState() {
    super.initState();
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
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final future = value.isEmpty
          ? _productService.fetchProducts()
          : _productService.searchProducts(value);
      final results = await future;
      if (!mounted) return;
      setState(() {
        _allProducts = results;
      });
    });
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
                        cart.totalItems.toString(),
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
          if (snapshot.connectionState == ConnectionState.waiting &&
              _allProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = _allProducts;
          if (products.isEmpty) {
            return const Center(child: Text('No products'));
          }
          final filtered = products
              .where((p) => p.name
                  .toLowerCase()
                  .contains(_search.text.toLowerCase()))
              .where((p) => _selectedCategory == null ||
                  p.categoryId == _selectedCategory)
              .toList();
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                      hintText: 'Search products', prefixIcon: Icon(Icons.search)),
                  onChanged: _onSearchChanged,
                ),
              ),
              Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: SizedBox(
    height: 150,
    child: PageView(
      children: [
        'https://via.placeholder.com/400x150.png?text=Offer+1',
        'https://via.placeholder.com/400x150.png?text=Offer+2',
        'https://via.placeholder.com/400x150.png?text=Offer+3',
      ].map((url) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(url, fit: BoxFit.cover),
          ))
        .toList(),
    ),
  ),
),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categories
                      .map((c) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ChoiceChip(
                              label: Text(c.name),
                              selected: _selectedCategory == c.id,
                              onSelected: (_) {
                                setState(() => _selectedCategory =
                                    _selectedCategory == c.id ? null : c.id);
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.7),
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProductDetail(product: product)),
                      ),
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Image.network(
                                product.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                semanticLabel: product.name,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: Colors.grey),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(product.name,
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () async => cart.add(product),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

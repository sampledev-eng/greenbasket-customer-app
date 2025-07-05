// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../services/wishlist_service.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import 'product_detail.dart';
import 'package:go_router/go_router.dart';
import 'cart_screen.dart';
import 'order_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ─────────────────────────────────────── services
  late ProductService _productService;
  final _categoryService = CategoryService();

  // ─────────────────────────────────────── state
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  late Future<List<Product>> _future;
  List<Product>   _all   = [];
  List<Category>  _cats  = [];
  List<String>    _brands = [];

  int?    _selectedCat;
  String? _selectedBrand;
  String  _priceFilter = 'All';
  String  _sort = 'None';

  // ─────────────────────────────────────── lifecycle
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    _productService = ProductService(auth);
    _future = _loadEverything();
    // pre-load cart data once
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.read<CartService>().load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────── data helpers
  Future<List<Product>> _loadEverything() async {
    try {
      final prods = await _productService.fetchFiltered();
      _all   = prods;
      _cats  = await _categoryService.fetchCategories();
      _brands = prods.map((p) => p.brand).toSet().toList();
      return prods;
    } catch (_) {
      // graceful fallback: 10 local demo products
      _all = _localDummies;
      _cats = [
        Category(id: 1, name: 'Demo'),
      ];
      _brands = _all.map((e) => e.brand).toSet().toList();
      return _all;
    }
  }

  static final _localDummies = List<Product>.generate(
    10,
    (i) => Product(
      id: i + 1,
      name: 'Demo Fruit ${i + 1}',
      description: 'Juicy & delicious demo item number ${i + 1}',
      brand: 'FruitCo',
      imageUrl:
          'https://picsum.photos/seed/fruit_${i + 1}/400/400', // free random pics
      price: 2.5 + i,
      mrp: 3.0 + i,
      stock: 20,
      categoryId: 1,
    ),
  );

  Future<void> _applyFilters() async {
    double? min;
    double? max;
    switch (_priceFilter) {
      case 'Below 50':
        max = 50;
        break;
      case '50-100':
        min = 50;
        max = 100;
        break;
      case 'Above 100':
        min = 100;
        break;
    }
    final sortKey = _sort == 'Price \u2191'
        ? 'price_asc'
        : _sort == 'Price \u2193'
            ? 'price_desc'
            : null;
    final results = await _productService.fetchFiltered(
      brand: _selectedBrand,
      category: _selectedCat,
      minPrice: min,
      maxPrice: max,
      search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
      sort: sortKey,
    );
    if (!mounted) return;
    setState(() {
      _all = results;
      _brands = results.map((p) => p.brand).toSet().toList();
    });
  }

  // ─────────────────────────────────────── search
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      await _applyFilters();
    });
  }

  // ─────────────────────────────────────── build
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GreenBasket'),
        actions: [
          _CartButton(cart),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderScreen())),
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return ErrorView(
              message: 'Failed to load products',
              onRetry: () => setState(() => _future = _loadEverything()),
            );
          }

          if (snap.connectionState == ConnectionState.waiting && _all.isEmpty) {
            return _shimmerGrid();
          }

          if (_all.isEmpty) return const EmptyView(message: 'No products');

          // filtering
          final list = _all
              .where((p) => p.name.toLowerCase().contains(_searchCtrl.text.toLowerCase()))
              .where((p) => _selectedCat == null || p.categoryId == _selectedCat)
              .where((p) => _selectedBrand == null || p.brand == _selectedBrand)
              .where((p) {
                switch (_priceFilter) {
                  case 'Below 50':  return p.price < 50;
                  case '50-100':    return p.price >= 50 && p.price <= 100;
                  case 'Above 100': return p.price > 100;
                  default:          return true;
                }
              }).toList();

          return ListView(
            children: [
              _searchBar(),
              _filterRow(),
              _promoBanner(),
              _categoryScroll(),
              _productsGrid(list, cart),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────── widgets
  Widget _searchBar() => Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          controller: _searchCtrl,
          onChanged: _onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Search products',
            prefixIcon: Icon(Icons.search),
          ),
        ),
      );

  Widget _filterRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          Expanded(child: _brandDrop()),
          const SizedBox(width: 8),
          Expanded(child: _priceDrop()),
          const SizedBox(width: 8),
          Expanded(child: _sortDrop()),
        ]),
      );

  DropdownButton<String> _brandDrop() => DropdownButton<String>(
        isExpanded: true,
        value: _selectedBrand,
        hint: const Text('Brand'),
        items: _brands
            .map((b) => DropdownMenuItem(value: b, child: Text(b)))
            .toList(),
        onChanged: (v) {
          setState(() => _selectedBrand = v);
          _applyFilters();
        },
      );

  DropdownButton<String> _priceDrop() => DropdownButton<String>(
        isExpanded: true,
        value: _priceFilter,
        items: const ['All', 'Below 50', '50-100', 'Above 100']
            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
            .toList(),
        onChanged: (v) {
          setState(() => _priceFilter = v ?? 'All');
          _applyFilters();
        },
      );

  DropdownButton<String> _sortDrop() => DropdownButton<String>(
        isExpanded: true,
        value: _sort,
        items: const ['None', 'Price \u2191', 'Price \u2193']
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: (v) {
          setState(() => _sort = v ?? 'None');
          _applyFilters();
        },
      );

  Widget _promoBanner() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 150,
          child: PageView(
            children: List.generate(
              3,
              (i) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://picsum.photos/seed/banner$i/800/300',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _categoryScroll() => SizedBox(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _cats
              .map((c) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text(c.name),
                    selected: _selectedCat == c.id,
                    onSelected: (_) {
                      setState(() =>
                          _selectedCat = _selectedCat == c.id ? null : c.id);
                      _applyFilters();
                    },
                  ),
                  ))
              .toList(),
        ),
      );

  Widget _productsGrid(List<Product> items, CartService cart) =>
      Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(builder: (context, c) {
          final crossAxis = c.maxWidth > 600 ? 4 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxis,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, i) {
              final p = items[i];
              return _productCard(p, cart);
            },
          );
        }),
      );

  Card _productCard(Product p, CartService cart) => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/product/${p.id}'),
                child: Image.network(
                  p.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p.mrp > p.price)
                    Text('MRP: \$${p.mrp.toStringAsFixed(2)}',
                        style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                            color: Colors.grey)),
                  Text('\$${p.price.toStringAsFixed(2)}'),
                  Text('Stock: ${p.stock}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<WishlistService>(builder: (_, wish, __) {
                  final fav = wish.contains(p);
                  return IconButton(
                    icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
                        color: fav ? Colors.red : null),
                    onPressed: () => wish.toggle(p),
                  );
                }),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () async {
                    await cart.add(p);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')));
                    }
                  },
                )
              ],
            )
          ],
        ),
      );

  Widget _shimmerGrid() => Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.white),
          ),
        ),
      );
}

// ───────────────────────────────────────── helpers
class _CartButton extends StatelessWidget {
  const _CartButton(this.cart);

  final CartService cart;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Stack(children: [
          const Icon(Icons.shopping_cart),
          if (cart.totalItems > 0)
            Positioned(
              right: 0,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.red,
                child: Text('${cart.totalItems}',
                    style: const TextStyle(fontSize: 11, color: Colors.white)),
              ),
            ),
        ]),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
      );
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://greenbasket-backend.onrender.com';
  final http.Client _client;
  String? _token;

  ApiClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  String? get token => _token;

  void updateToken(String? token) {
    _token = token;
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String path) async {
    final response = await _client.get(_uri(path), headers: _headers());
    _check(response);
    return json.decode(response.body);
  }

  Future<dynamic> post(String path, Map<String, dynamic> data) async {
    final response =
        await _client.post(_uri(path), headers: _headers(), body: json.encode(data));
    _check(response);
    return json.decode(response.body);
  }

  void _check(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Request failed: ${res.statusCode}');
    }
  }

  // High level helpers for backend endpoints
  Future<dynamic> register(String username, String email, String password) async {
    return post('/auth/register',
        {'username': username, 'email': email, 'password': password});
  }

  Future<dynamic> login(String username, String password) async {
    final data =
        await post('/auth/login', {'username': username, 'password': password});
    if (data is Map && data.containsKey('access_token')) {
      updateToken(data['access_token']);
    }
    return data;
  }

  Future<List<dynamic>> products() async => await get('/products/');

  Future<dynamic> addProduct(String name, String description, double price,
      int stock, int categoryId, String imageUrl) async {
    return post('/products/', {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'image_url': imageUrl,
    });
  }

  Future<dynamic> addCart(int productId, int quantity) async =>
      await post('/cart/add', {'product_id': productId, 'quantity': quantity});

  Future<List<dynamic>> fetchCart() async => await get('/cart/');

  Future<dynamic> createOrder(String address, String paymentMode) async =>
      await post('/orders/create',
          {'address': address, 'payment_mode': paymentMode});

  Future<List<dynamic>> orders() async => await get('/orders/');

  Future<dynamic> trackDelivery(int orderId) async =>
      await get('/delivery/track/$orderId');

  Future<dynamic> initiatePayment(int orderId, double amount) async =>
      await post('/payments/initiate',
          {'order_id': orderId, 'amount': amount});

  Future<dynamic> getCurrentUser() async => await get('/users/me');

  Future<List<dynamic>> categories() async => await get('/categories/');

  Future<dynamic> createCategory(String name) async =>
      await post('/categories/', {'name': name});

  Future<dynamic> seed() async => await post('/seed', {});
}

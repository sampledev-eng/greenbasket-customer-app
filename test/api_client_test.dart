import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:greenbasket/services/api_client.dart';
import 'package:greenbasket/services/auth_service.dart';
import 'package:greenbasket/services/cart_service.dart';
import 'package:greenbasket/services/order_service.dart';
import 'package:greenbasket/models/product.dart';

void main() {
  test('Cart and order requests include Authorization header after login', () async {
    final requests = <http.Request>[];
    var handler = (http.Request req) async {
      requests.add(req);
      if (req.url.path == '/auth/login') {
        return http.Response(json.encode({'access_token': 'token'}), 200);
      }
      if (req.url.path == '/users/me') {
        return http.Response(json.encode({'id': 1, 'username': 'u', 'email': 'e'}), 200);
      }
      return http.Response('{}', 200);
    };
    final mockClient = MockClient((req) => handler(req));

    final api = ApiClient(httpClient: mockClient);
    final auth = AuthService(api);
    final cart = CartService(api);
    final orders = OrderService(api);

    expect(await auth.login('u', 'p'), isTrue);

    handler = (http.Request req) async {
      requests.add(req);
      return http.Response('{}', 200);
    };

    final product = Product(id: 1, name: 'n', price: 1.0, description: '', imageUrl: '');
    await cart.add(product);
    await orders.createOrder('addr', 'COD');

    final authed = requests.where((r) => r.url.path != '/auth/login' && r.url.path != '/users/me');
    for (final r in authed) {
      expect(r.headers['Authorization'], 'Bearer token');
    }
  });
}

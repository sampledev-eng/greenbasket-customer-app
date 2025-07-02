import 'api_client.dart';

class PaymentService {
  final ApiClient _client;
  PaymentService(this._client);

  Future<dynamic> initiate(int orderId, double amount) async {
    return _client.initiatePayment(orderId, amount);
  }
}

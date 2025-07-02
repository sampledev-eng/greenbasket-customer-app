import 'api_client.dart';

class PaymentService {
  final ApiClient _client = ApiClient();

  Future<dynamic> initiate(int orderId, double amount) async {
    return _client.initiatePayment(orderId, amount);
  }
}

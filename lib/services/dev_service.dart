import 'api_client.dart';

class DevService {
  final ApiClient _client = ApiClient();

  Future<dynamic> seedDemoData() async => _client.seed();
}

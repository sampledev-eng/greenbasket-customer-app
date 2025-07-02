import 'api_client.dart';

class DevService {
  final ApiClient _client;
  DevService(this._client);

  Future<dynamic> seedDemoData() async => _client.seed();
}

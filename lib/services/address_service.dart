import '../models/address.dart';
import 'api_client.dart';

class AddressService {
  final ApiClient _client = ApiClient();

  Future<List<Address>> fetchAddresses() async {
    final data = await _client.get('/addresses');
    return (data as List)
        .map((e) => Address.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Address?> createAddress(String address) async {
    final data = await _client.post('/addresses', {'address': address});
    if (data is Map<String, dynamic>) {
      return Address.fromJson(data);
    }
    return null;
  }
}

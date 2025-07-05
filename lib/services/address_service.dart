import '../models/address.dart';
import 'api_client.dart';

class AddressService {
  final ApiClient _client = ApiClient();

  Future<List<Address>> fetchAddresses() async {
    try {
      final data = await _client.get('/addresses');
      return (data as List)
          .map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Address?> createAddress(String address) async {
    try {
      final data = await _client.post('/addresses', {'address': address});
      if (data is Map<String, dynamic>) {
        return Address.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<Address?> updateAddress(int id, String address) async {
    try {
      final data = await _client.updateAddress(id, address);
      if (data is Map<String, dynamic>) {
        return Address.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> deleteAddress(int id) async {
    try {
      await _client.deleteAddress(id);
      return true;
    } catch (_) {
      return false;
    }
  }
}

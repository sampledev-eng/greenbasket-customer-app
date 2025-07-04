import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/address_service.dart';
import '../models/address.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AddressService _addressService = AddressService();
  List<Address> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final addresses = await _addressService.fetchAddresses();
    setState(() {
      _addresses = addresses;
      _loading = false;
    });
  }

  Future<void> _addAddress() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Address'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Address'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    final created = await _addressService.createAddress(text);
    if (created != null) {
      setState(() => _addresses.add(created));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to add address')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(auth.currentUser?.username ?? 'Guest',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Addresses',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addAddress,
                      ),
                    ],
                  ),
                  Expanded(
                    child: _addresses.isEmpty
                        ? const Center(child: Text('No addresses'))
                        : ListView.builder(
                            itemCount: _addresses.length,
                            itemBuilder: (context, index) {
                              final addr = _addresses[index];
                              return ListTile(
                                title: Text(addr.address),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        auth.logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

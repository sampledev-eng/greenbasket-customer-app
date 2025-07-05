import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/address_service.dart';
import '../models/address.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthService _auth;
  final AddressService _addressService = AddressService();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  List<Address> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthService>();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _auth.fetchCurrentUser();
    _name.text = _auth.currentUser?.username ?? '';
    _email.text = _auth.currentUser?.email ?? '';
    final addresses = await _addressService.fetchAddresses();
    if (!mounted) return;
    setState(() {
      _addresses = addresses;
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    final success = await _auth.updateProfile(_name.text, _email.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(success ? 'Profile updated' : 'Failed to update profile')));
  }

  Future<void> _addOrEditAddress([Address? address]) async {
    final controller = TextEditingController(text: address?.address);
    final text = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(address == null ? 'New Address' : 'Edit Address'),
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
    Address? result;
    if (address == null) {
      result = await _addressService.createAddress(text);
      if (result != null) {
        setState(() => _addresses.add(result!));
      }
    } else {
      result = await _addressService.updateAddress(address.id, text);
      if (result != null) {
        setState(() {
          final idx = _addresses.indexWhere((a) => a.id == address.id);
          if (idx >= 0) _addresses[idx] = result!;
        });
      }
    }
    if (result == null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to save address')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _name,
                              decoration:
                                  const InputDecoration(labelText: 'Name'),
                            ),
                            TextField(
                              controller: _email,
                              decoration:
                                  const InputDecoration(labelText: 'Email'),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Addresses',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => _addOrEditAddress(),
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
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () =>
                                                    _addOrEditAddress(addr),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () async {
                                                  final ok = await _addressService
                                                      .deleteAddress(addr.id);
                                                  if (ok) {
                                                    setState(() =>
                                                        _addresses.removeAt(index));
                                                  } else {
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('Failed to delete')));
                                                    }
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _saveProfile,
                                    child: const Text('Save Profile'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                  onPressed: () {
                                    _auth.logout();
                                    context.go('/');
                                  },
                                    child: const Text('Logout'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _address = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AuthService _auth;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthService>();
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    setState(() => _loading = true);
    final ok = await _auth.register(
        _username.text, _email.text, _password.text);
    setState(() => _loading = false);
    if (ok && mounted) {
      context.go('/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Enter valid email',
              ),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) =>
                    v != null && v.length >= 6 ? null : 'Minimum 6 characters',
              ),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                ),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

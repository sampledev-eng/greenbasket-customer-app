import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  bool _requested = false;
  bool _loading = false;

  Future<void> _request() async {
    setState(() => _loading = true);
    final auth = context.read<AuthService>();
    await auth.requestOtp(_phone.text);
    setState(() {
      _loading = false;
      _requested = true;
    });
  }

  Future<void> _verify() async {
    setState(() => _loading = true);
    final auth = context.read<AuthService>();
    final result = await auth.verifyOtp(_phone.text, _code.text);
    setState(() => _loading = false);
    if (result == AuthResult.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP verified. Please login.')));
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('OTP verification failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            if (_requested)
              TextField(
                controller: _code,
                decoration: const InputDecoration(labelText: 'OTP Code'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : _requested
                      ? _verify
                      : _request,
              child: _loading
                  ? const CircularProgressIndicator()
                  : Text(_requested ? 'Verify OTP' : 'Request OTP'),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import 'forgot_password_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  late AuthService _auth;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthService>();
  }

  Future<void> _login() async {
    if (_email.text.isEmpty || !_email.text.contains('@')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid email')));
      return;
    }
    if (_password.text.length < 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password too short')));
      return;
    }
    setState(() => _loading = true);
    final result = await _auth.login(_email.text, _password.text);
    setState(() => _loading = false);
    if (result == AuthResult.success) {
      final cart = context.read<CartService>();
      await cart.load();
      if (mounted) context.go('/home');
    } else if (result == AuthResult.unauthorized) {
      if (mounted) context.go('/register');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6AA84F), Color(0xFF2F7E34)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_basket,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 8),
                    Text('Welcome to GreenBasket',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: _password,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                      ),
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen()));
                      },
                      child: const Text('Forgot password?'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const OtpScreen()));
                      },
                      child: const Text('Login with OTP'),
                    ),
                    ElevatedButton(
                      onPressed: () => context.push('/register'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                      ),
                      child: const Text('Register'),
                    ),
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Continue as Guest'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

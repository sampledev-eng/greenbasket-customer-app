import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'services/cart_service.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';

void main() {
  final client = ApiClient();
  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final ApiClient client;
  const MyApp({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: client),
        Provider<AuthService>(create: (_) => AuthService(client)),
        ChangeNotifierProvider(create: (_) => CartService(client)),
      ],
      child: MaterialApp(
        title: 'GreenBasket',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const LoginScreen(),
      ),
    );
  }
}

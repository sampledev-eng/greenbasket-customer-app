import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/offline_screen.dart';
import 'screens/product_detail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'services/cart_service.dart';
import 'services/auth_service.dart';
import 'services/wishlist_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, WishlistService>(
          create: (context) => WishlistService(context.read<AuthService>()),
          update: (context, auth, wish) {
            wish ??= WishlistService(auth);
            wish.updateAuth(auth);
            return wish;
          },
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (!auth.initialized) {
            return const MaterialApp(
                home: Scaffold(body: Center(child: CircularProgressIndicator())));
          }
          return StreamBuilder<ConnectivityResult>(
            stream: Connectivity().onConnectivityChanged,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == ConnectivityResult.none) {
                return const MaterialApp(home: OfflineScreen());
              }
              final _router = GoRouter(
                routes: [
                  GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
                  GoRoute(path: '/home', builder: (_, __) => const MainScreen()),
                  GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
                  GoRoute(
                    path: '/product/:id',
                    builder: (c, s) => ProductDetail(id: int.parse(s.params['id']!)),
                  ),
                ],
              );
              return MaterialApp.router(
                title: 'GreenBasket',
                theme: ThemeData(
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: const Color(0xFF6AA84F)),
                  textTheme: GoogleFonts.poppinsTextTheme(),
                ),
                routeInformationParser: _router.routeInformationParser,
                routerDelegate: _router.routerDelegate,
              );
            },
          );
        },
      ),
    );
  }
}

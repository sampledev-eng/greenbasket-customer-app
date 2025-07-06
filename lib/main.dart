import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/offline_screen.dart';
import 'screens/product_detail.dart';

import 'services/cart_service.dart';
import 'services/auth_service.dart';
import 'services/wishlist_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, WishlistService>(
          create: (ctx) => WishlistService(ctx.read<AuthService>()),
          update: (ctx, auth, previous) {
            previous ??= WishlistService(auth);
            previous.updateAuth(auth);
            return previous;
          },
        ),
      ],
      child: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (!auth.initialized) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          return StreamBuilder<ConnectivityResult>(
            initialData: ConnectivityResult.mobile,        // <-- never null
            stream: Connectivity().onConnectivityChanged,
            builder: (context, snapshot) {
              if (snapshot.data == ConnectivityResult.none) {
                return const MaterialApp(home: OfflineScreen());
              }

              // ---------------- ROUTES ----------------
              final router = GoRouter(
                routes: [
                  GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
                  GoRoute(path: '/home', builder: (_, __) => const MainScreen()),
                  GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
                  GoRoute(
                    path: '/product/:id',
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '');
                      if (id == null) {
                        return const Scaffold(
                          body: Center(child: Text('Invalid product ID')),
                        );
                      }
                      return ProductDetail(id: id);
                    },
                  ),
                ],
                errorBuilder: (_, __) =>
                    const Scaffold(body: Center(child: Text('Page not found'))),
              );
              // ----------------------------------------

              return MaterialApp.router(
                title: 'GreenBasket',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6AA84F)),
                  textTheme: GoogleFonts.poppinsTextTheme(),
                ),
                routerConfig: router,
              );
            },
          );
        },
      ),
    );
  }
}

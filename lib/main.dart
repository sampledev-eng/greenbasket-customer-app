import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.green),
    home: LoginPage(),
  ));
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

  Future<void> login(BuildContext context) async {
    setState(() => loading = true);
    final loginUrl = Uri.parse('https://super-fiesta-r4xp7vxqvp9pfr74-8000.app.github.dev/login');

    final response = await http.post(
      loginUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': emailController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final token = json.decode(response.body)['access_token'];

      final productsUrl = Uri.parse('https://super-fiesta-r4xp7vxqvp9pfr74-8000.app.github.dev/products');
      final productsResponse = await http.get(
        productsUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (productsResponse.statusCode == 200) {
        final products = json.decode(productsResponse.body);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductsPage(products: products)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to load products"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Login failed: ${response.body}"),
      ));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : () => login(context),
              child: loading ? CircularProgressIndicator(color: Colors.white) : Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductsPage extends StatelessWidget {
  final List<dynamic> products;
  ProductsPage({required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product["name"]),
            subtitle: Text("\$${product["price"]}"),
          );
        },
      ),
    );
  }
}

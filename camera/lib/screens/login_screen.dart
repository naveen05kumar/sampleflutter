// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                final response = await _apiService.login(
                  _emailController.text,
                  _passwordController.text,
                );
                if (response.statusCode == 200) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  // Display error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed: ${response.body}')),
                  );
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

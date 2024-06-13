import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const _baseUrl = 'http://10.0.2.2:8000';
  final storage = FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'token');
  }

  Future<http.Response> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['tokens']['access'];
      await storage.write(key: 'token', value: accessToken);
      debugPrint('Login successful: $accessToken');
    } else {
      debugPrint('Login failed: ${response.statusCode} ${response.body}');
    }
    return response;
  }

  Future<http.Response> addStaticCamera(Map<String, String> cameraData) async {
    final token = await _getToken();
    return await http.post(
      Uri.parse('$_baseUrl/camera/static-camera/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(cameraData),
    );
  }

  Future<http.Response> addDDNSCamera(Map<String, String> cameraData) async {
    final token = await _getToken();
    return await http.post(
      Uri.parse('$_baseUrl/camera/ddns-camera/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(cameraData),
    );
  }

  Future<String?> getStreamUrl(String cameraType) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/camera/get-stream-url/$cameraType/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['stream_url'];
    }
    return null;
  }
}

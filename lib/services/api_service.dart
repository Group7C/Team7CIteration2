import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace this URL with your API Gateway Invoke URL
  // Replace with your actual API Gateway URL from AWS
  static const String baseUrl = 'https://e6j6nc6ioh.execute-api.eu-north-1.amazonaws.com/prod';
  
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      print('Login response status code: ${response.statusCode}');
      print('Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        return null; // Invalid credentials
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Failed to connect to the server: $e');
    }
  }
  
  static Future<bool> register(String username, String password, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
          'email': email,
        }),
      );
      
      print('Register response status code: ${response.statusCode}');
      print('Register response body: ${response.body}');
      
      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('Failed to connect to the server: $e');
    }
  }
}

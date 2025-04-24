import 'dart:async';

// Mock database service for web compatibility
class MockDatabaseService {
  // In-memory "database" with test users
  static final List<Map<String, dynamic>> _users = [
    {
      'id': 1,
      'username': 'testuser1',
      'password_hash': 'password123',
      'email': 'test1@example.com',
    },
    {
      'id': 2,
      'username': 'testuser2',
      'password_hash': 'password123',
      'email': 'test2@example.com',
    },
  ];
  
  // Login method
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // Find user with matching username and password
      final user = _users.firstWhere(
        (user) => 
          user['username'] == username && 
          user['password_hash'] == password,
        orElse: () => {},
      );
      
      if (user.isNotEmpty) {
        return {
          'id': user['id'],
          'username': user['username'],
          'email': user['email'],
        };
      }
      
      return null;
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Register method
  static Future<bool> register(String username, String password, String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      // Check if username already exists
      final existingUser = _users.any((user) => user['username'] == username);
      
      if (existingUser) {
        return false;
      }
      
      // Add new user
      _users.add({
        'id': _users.length + 1,
        'username': username,
        'password_hash': password,
        'email': email,
      });
      
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }
  
  // For testing: print all users
  static void printAllUsers() {
    print('Current users in mock database:');
    for (var user in _users) {
      print('ID: ${user['id']}, Username: ${user['username']}, Email: ${user['email']}');
    }
  }
}

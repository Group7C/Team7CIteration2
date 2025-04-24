import 'dart:async';
import 'package:postgres/postgres.dart';

class DatabaseService {
  // Database connection details
  static const String _host = 'flutter-login-test.cdiqcq280rvy.eu-north-1.rds.amazonaws.com';
  static const int _port = 5432;
  static const String _database = 'postgres'; // Default database name
  static const String _username = 'postgres'; // Replace with your username
  static const String _password = '!!Team7cTeam7c'; // Your database password

  // Connection instance
  static PostgreSQLConnection? _connection;

  // Get or create connection
  static Future<PostgreSQLConnection> get connection async {
    if (_connection == null || _connection!.isClosed) {
      _connection = PostgreSQLConnection(
        _host,
        _port,
        _database,
        username: _username,
        password: _password,
        useSSL: true,
      );
      
      try {
        await _connection!.open();
        print('Database connection established');
      } catch (e) {
        print('Error connecting to database: $e');
        throw Exception('Failed to connect to the database: $e');
      }
    }
    
    return _connection!;
  }

  // Close connection
  static Future<void> closeConnection() async {
    if (_connection != null && !_connection!.isClosed) {
      await _connection!.close();
      print('Database connection closed');
    }
  }

  // Login method
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final conn = await connection;
      
      // Note: In a real app, you should hash the passwords and not store them as plain text
      final results = await conn.query(
        'SELECT id, username, email FROM users WHERE username = @username AND password_hash = @password',
        substitutionValues: {
          'username': username,
          'password': password, // In a real app, you'd compare hashed passwords
        },
      );
      
      if (results.isNotEmpty) {
        return {
          'id': results.first[0],
          'username': results.first[1],
          'email': results.first[2],
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
    try {
      final conn = await connection;
      
      await conn.query(
        'INSERT INTO users (username, password_hash, email) VALUES (@username, @password, @email)',
        substitutionValues: {
          'username': username,
          'password': password, // In a real app, this should be hashed
          'email': email,
        },
      );
      
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }
}

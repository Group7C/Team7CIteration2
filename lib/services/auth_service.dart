import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  // Initialize auth state - check for saved user
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final username = prefs.getString('username');
      final email = prefs.getString('email');

      if (userId != null && username != null) {
        _currentUser = User(
          id: userId,
          username: username,
          email: email ?? '',
        );
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
    
    notifyListeners();
  }

  // Login method
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await ApiService.login(username, password);
      
      if (userData != null) {
        _currentUser = User.fromMap(userData);
        
        // Save user data to shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('user_id', _currentUser!.id);
        prefs.setString('username', _currentUser!.username);
        prefs.setString('email', _currentUser!.email);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid username or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register method
  Future<bool> register(String username, String password, String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await ApiService.register(
        username, 
        password,
        email,
      );
      
      _isLoading = false;
      
      if (!success) {
        _error = 'Registration failed. Username may be taken.';
        notifyListeners();
        return false;
      }
      
      // If registration successful, login automatically
      return await login(username, password);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _currentUser = null;
    
    // Clear saved user data
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user_id');
    prefs.remove('username');
    prefs.remove('email');
    
    notifyListeners();
  }
}

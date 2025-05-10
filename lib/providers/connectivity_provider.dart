import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOfflineMode = false;

  // Getter
  bool get isOfflineMode => _isOfflineMode;

  // Set offline mode
  void setOfflineMode(bool value) {
    if (_isOfflineMode != value) {
      _isOfflineMode = value;
      notifyListeners();
    }
  }
}

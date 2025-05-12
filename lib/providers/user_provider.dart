import 'package:flutter/cupertino.dart';
import 'package:sevenc_iteration_two/usser/usserObject.dart';

class UserProvider with ChangeNotifier {
  List<Usser> users = [];

  void loadMockUsers(List<Usser> mockUsers) {
    users = mockUsers;
    notifyListeners();
  }

  void logout() {
    users = [];
    notifyListeners();
  }

  List<Usser> get allUsers => users;
}
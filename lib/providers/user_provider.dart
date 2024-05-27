import 'package:calcount/model/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User? currentUser;

  UserProvider();

  void setCurrentUser(User user) {
    currentUser = user;
    notifyListeners();
  }
}

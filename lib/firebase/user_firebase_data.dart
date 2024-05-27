import 'dart:convert';

import 'package:calcount/model/user.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

class UserFirebaseData {
  final String _baseUrl = 'https://calcount-f6f51-default-rtdb.firebaseio.com/';

  Future<bool> register(User user) async {
    final response = await http.post(Uri.parse('$_baseUrl/users.json'),
        body: jsonEncode({'email': user.email, 'password': user.password}));

    return response.statusCode == 200;
  }

  Future<bool> changePassword(User user, String newPassword) async {
    if (user.id != null) {
      DatabaseReference ref = FirebaseDatabase.instance.ref("users/${user.id}");

      await ref.update({
        "password": newPassword,
      });

      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteAccount(User user) async {
    if (user.id != null) {
      DatabaseReference ref = FirebaseDatabase.instance.ref("users/${user.id}");

      await ref.remove();

      return true;
    } else {
      return false;
    }
  }

  Future<User> findUserByAttribute(String attributeName, dynamic value) async {
    DatabaseReference dbReference =
        FirebaseDatabase.instance.ref().child('users');
    User userResponse = User(id: null, email: '', password: '');

    final response =
        await dbReference.orderByChild(attributeName).equalTo(value).once();

    if (response.snapshot.value != null) {
      final userSnapshotValue =
          response.snapshot.value as Map<dynamic, dynamic>;

      final userData = userSnapshotValue.values.first;

      userResponse = User(
          id: userSnapshotValue.keys.first,
          email: userData['email'],
          password: userData['password']);
    }

    return userResponse;
  }
}

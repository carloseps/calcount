import 'dart:convert';

import 'package:calcount/model/user.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class UserFirebaseData with ChangeNotifier {
  final String _baseUrl = 'https://calcount-f6f51-default-rtdb.firebaseio.com/';
  final DatabaseReference dbReference =
      FirebaseDatabase.instance.ref().child('users');

  Future<bool> register(User user) async {
    final response = await http.post(Uri.parse('$_baseUrl/users.json'),
        body: jsonEncode({
          'id': const Uuid().v4(),
          'email': user.email,
          'password': user.password
        }));

    return response.statusCode == 200;
  }

  Future<User> findUserByEmail(String email) async {
    User userResponse = User(id: null, email: '', password: '');

    final response =
        await dbReference.orderByChild('email').equalTo(email).once();

    if (response.snapshot.value != null) {
      final userSnapshotValue =
          response.snapshot.value as Map<dynamic, dynamic>;

      final userData = userSnapshotValue.values.first;

      userResponse = User(
          id: userData['id'],
          email: userData['email'],
          password: userData['password']);
    }

    return userResponse;
  }
}

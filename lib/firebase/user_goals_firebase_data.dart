import 'dart:convert';

import 'package:calcount/model/user_goals.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

class UserGoalsFirebaseData {
  final String _baseUrl = 'https://calcount-f6f51-default-rtdb.firebaseio.com/';

  Future<bool> register(UserGoals userGoals) async {
    final response = await http.post(Uri.parse('$_baseUrl/users_goals.json'),
        body: jsonEncode({
          'userId': userGoals.userId, 
          'totalCalories': userGoals.totalCalories,
          'totalCarbohydrates': userGoals.totalCarbohydrates,
          'totalProteins': userGoals.totalProteins,
          'totalFats': userGoals.totalFats,
        }));

    return response.statusCode == 200;
  }

  Future<UserGoals> findGoalsByUser(String userId) async {
    DatabaseReference dbReference = FirebaseDatabase.instance.ref().child('users_goals');
    UserGoals userGoalsResponse = UserGoals(userId: '');

    final response =
        await dbReference.orderByChild('userId').equalTo(userId).once();

    if (response.snapshot.value != null) {
      final userSnapshotValue =
          response.snapshot.value as Map<dynamic, dynamic>;

      final userGoalsData = userSnapshotValue.values.first;

      userGoalsResponse = UserGoals(
          userId: userGoalsData['userId'],
          totalCalories: userGoalsData['totalCalories'],
          totalCarbohydrates: userGoalsData['totalCarbohydrates'],
          totalProteins: userGoalsData['totalProteins'],
          totalFats: userGoalsData['totalFats']);
    }

    return userGoalsResponse;
  }
}

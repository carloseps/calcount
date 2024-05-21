import 'dart:convert';
import 'package:calcount/model/meal.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MealFoodFirebaseData with ChangeNotifier {
  final String _baseUrl = 'https://calcount-f6f51-default-rtdb.firebaseio.com/';
  final DatabaseReference mealReference = FirebaseDatabase.instance.reference().child('meals');

  final List<Meal> _meals = [];

  List<Meal> get meals {
    return [..._meals];
  }

  Future<void> fetchData() async {
    final snapshot = await mealReference.once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
    _meals.clear();
    data.forEach((key, value) {
      final List<Food> foods = [];
      if (value['foods'] != null && (value['foods'] as List).isNotEmpty) {
        foods.addAll((value['foods'] as List<dynamic>).map((food) => Food(
          name: food['name'] as String,
          carbohydrates: (food['carbohydrates'] as num?)?.toDouble(),
          protein: (food['protein'] as num?)?.toDouble(),
          fats: (food['fats'] as num?)?.toDouble(),
          calories: food['calories'] as int?,
          quantity: food['quantity'] as int?,
          quantityUnit: unit.values.firstWhere((e) => e.toString() == 'unit.${food['quantityUnit']}'),
        )));
      }
      final meal = Meal(
        name: value['name'] as String,
        foods: foods,
        totalCalories: value['totalCalories'] as int?,
        datetime: value['datetime'] != null ? TimeOfDay(
          hour: (value['datetime']['hour'] as num).toInt(),
          minute: (value['datetime']['minute'] as num).toInt(),
        ) : null,
      );
      _meals.add(meal);
    });
    notifyListeners();
  }


  Future<void> addMeal(Meal meal) async {
    final response = await http.post(Uri.parse('$_baseUrl/meals.json'),
        body: jsonEncode({
          'name': meal.name,
          'foods': [],  //cria lista vazia de foods pois n tem como adicionar foods quando cadastra uma meal
          'totalCalories': meal.totalCalories,
          'datetime': meal.datetime != null ? {
            'hour': meal.datetime!.hour,
            'minute': meal.datetime!.minute,
          } : null,
        }));
    final id = meal.name;
    _meals.add(meal);
    notifyListeners();
  }


  Future<void> updateMeal(Meal meal) async {
    final mealRef = mealReference.child(meal.name);
    await mealRef.update({
      'name': meal.name,
      'foods': meal.foods.map((food) => {
        'name': food.name,
        'carbohydrates': food.carbohydrates,
        'protein': food.protein,
        'fats': food.fats,
        'calories': food.calories,
        'quantity': food.quantity,
        'quantityUnit': food.quantityUnit.toString().split('.').last,
      }).toList(),
      'totalCalories': meal.totalCalories,
      'datetime': meal.datetime != null ? {
        'hour': meal.datetime!.hour,
        'minute': meal.datetime!.minute,
      } : null,
    });
    notifyListeners();
  }

  Future<void> removeMeal(Meal meal) async {
    final mealRef = mealReference.child(meal.name);
    await mealRef.remove();
    _meals.removeWhere((m) => m.name == meal.name);
    notifyListeners();
  }

  Future<void> saveMeal(Meal meal) {
    final existingMealIndex = _meals.indexWhere((m) => m.name == meal.name);
    if (existingMealIndex >= 0) {
      return updateMeal(meal);
    } else {
      return addMeal(meal);
    }
  }

  Future<void> addFoodToMeal(String mealName, Food food) async {
    final mealIndex = _meals.indexWhere((meal) => meal.name == mealName);
    if (mealIndex >= 0) {
      _meals[mealIndex].foods.add(food);

      final mealRef = mealReference.child(mealName).child('foods').push();
      await mealRef.set({
        'name': food.name,
        'carbohydrates': food.carbohydrates,
        'protein': food.protein,
        'fats': food.fats,
        'calories': food.calories,
        'quantity': food.quantity,
        'quantityUnit': food.quantityUnit.toString().split('.').last,
      });

      notifyListeners();
    }
  }

}

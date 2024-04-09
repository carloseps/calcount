import 'package:flutter/material.dart';

class Meal {
  String name;
  List<Food> foods;
  int? totalCalories;
  TimeOfDay? datetime;

  Meal(
      {required this.name,
      required this.foods,
      this.totalCalories,
      this.datetime});

  @override
  String toString() {
    String foodListString = '';
    for (Food food in foods) {
      foodListString +=
          '- ${food.name} (${food.quantity} ${food.quantityUnit.toString().split('.').last}) \n';
    }
    return foodListString;
  }
}

class Food {
  String name;
  double? carbohydrates;
  double? fats; //gordura
  int? calories;
  int? quantity;
  unit? quantityUnit;

  Food(
      {required this.name,
      this.carbohydrates,
      this.fats,
      this.calories,
      this.quantity,
      this.quantityUnit});
}

//unidade
enum unit { ml, un, g }

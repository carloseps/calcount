import 'package:flutter/material.dart';

class Meal {
  String name;
  List<Food> foods;
  String? user_id;
  TimeOfDay? datetime;
  String? imageUrl;

  int get totalCalories {
    return foods.fold(0, (prev, food) => prev + food.calories!);
  }

  Meal(
      {
      required this.name,
      required this.foods,
      this.datetime,
      this.imageUrl,
      required this.user_id
      });

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
  double? protein;
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
      this.protein,
      this.quantityUnit});
}

//unidade
enum unit { ml, un, g }

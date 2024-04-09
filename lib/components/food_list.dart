import 'package:calcount/model/meal.dart';
import 'package:flutter/material.dart';

class FoodList extends StatelessWidget {
  List<Food> foodList;

  FoodList({required this.foodList, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: foodList.length,
      itemBuilder: (context, index) {
        final Food food = foodList[index];
        return Container(
          child: Text(food.name),
        );
      },
    );
  }
}

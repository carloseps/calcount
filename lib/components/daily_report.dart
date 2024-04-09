import 'dart:ffi';

import 'package:calcount/model/meal.dart';
import 'package:flutter/material.dart';

class DailyReport extends StatefulWidget {
  const DailyReport({required this.meals, super.key});

  final List<Meal> meals;

  @override
  State<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  @override
  Widget build(BuildContext context) {
    final int totalCalories = widget.meals
        .fold(0, (value, element) => element.totalCalories! + value);

    final int consumedCalories = widget.meals.fold(
        0,
        (value, element) =>
            value +
            element.foods
                .fold(0, (value, element) => element.calories! + value));

    final double totalCarbohydrates = widget.meals.fold(
        0,
        (value, element) =>
            value +
            element.foods
                .fold(0, (value, element) => element.carbohydrates! + value));

    final double totalProteins = widget.meals.fold(
        0,
        (value, element) =>
            value +
            element.foods
                .fold(0, (value, element) => element.protein! + value));

    final double totalFats = widget.meals.fold(
        0,
        (value, element) =>
            value +
            element.foods.fold(0, (value, element) => element.fats! + value));

    final double totalMacros = totalCarbohydrates + totalFats + totalProteins;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "Relatório Diário",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Meta de Calorias:",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.start,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "${totalCalories.toString()} kcal",
                        style: const TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Calorias Consumidas:",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "${consumedCalories.toString()} kcal",
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Carboidratos:",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "${totalCarbohydrates.toString()}g (${((totalCarbohydrates * 100) / totalMacros).toStringAsFixed(2)}%)",
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Proteínas:",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "${totalProteins.toString()}g (${((totalProteins * 100) / totalMacros).toStringAsFixed(2)}%)",
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Gorduras:",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        "${totalFats.toString()}g (${((totalFats * 100) / totalMacros).toStringAsFixed(2)}%)",
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

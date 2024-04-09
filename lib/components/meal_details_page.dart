import 'package:flutter/material.dart';

import '../model/meal.dart';

class MealDetailsPage extends StatelessWidget {
  final Meal meal;

  const MealDetailsPage({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.name),
      ),
      body: ListView.builder(
        itemCount: meal.foods.length,
        itemBuilder: (context, index) {
          final food = meal.foods[index];
          return ListTile(
            title: Text(food.name),
            subtitle: Text(
              '${food.quantity} ${food.quantityUnit.toString().split('.').last}',
            ),
          );
        },
      ),
    );
  }
}

class MealList extends StatelessWidget {
  final List<Meal> dailyMealList;

  const MealList({super.key,
    required this.dailyMealList,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyMealList.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text("Vamos adicionar refeições!"),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: dailyMealList.length,
        itemBuilder: (context, index) {
          final meal = dailyMealList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealDetailsPage(meal: meal),
                ),
              );
            },
            child: Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              margin: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                    child: Text(
                      "${meal.name}:",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 0),
                    child: Text(
                      meal.toString(),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ClipOval(
                          child: Material(
                            color: Theme.of(context).primaryColor,
                            child: InkWell(
                              onTap: () {
                                // TODO - Ação ao pressionar o ícone de adição
                              },
                              child: const Icon(
                                Icons.add,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

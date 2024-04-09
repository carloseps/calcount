import 'package:calcount/model/meal.dart';
import 'package:flutter/material.dart';
import 'package:calcount/components/meal_details_page.dart'; // Importando a nova tela de detalhes da refeição

class MealList extends StatelessWidget {
  final List<Meal> dailyMealList;

  const MealList({super.key,
    required this.dailyMealList,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyMealList.isEmpty) {
      return SizedBox(
        height: 300,
        child: const Center(
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
              // Navegar para a tela de detalhes da refeição quando clicar em uma refeição
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
              margin: const EdgeInsets.only(bottom: 15),
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
                                // Ação ao pressionar o ícone de adição
                              },
                              child: const Icon(
                                Icons.add,
                                size: 30, // Tamanho do ícone
                                color: Colors.white, // Cor do ícone
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

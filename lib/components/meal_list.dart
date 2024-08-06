import 'package:calcount/components/new_food_form.dart';
import 'package:calcount/firebase/meal_food_firebase_data.dart';
import 'package:calcount/model/meal.dart';
import 'package:flutter/material.dart';
import 'package:calcount/components/meal_details_page.dart';
import 'package:provider/provider.dart'; // Importando a nova tela de detalhes da refeição

class MealList extends StatefulWidget {
  final List<Meal> dailyMealList;

  const MealList({
    super.key,
    required this.dailyMealList,
  });

  @override
  State<MealList> createState() => _MealListState();
}

class _MealListState extends State<MealList> {
  @override
  Widget build(BuildContext context) {
    if (widget.dailyMealList.isEmpty) {
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
        itemCount: widget.dailyMealList.length,
        itemBuilder: (context, index) {
          final meal = widget.dailyMealList[index];
          newFood(String _name, double? _carbohydrates, double? _fats,
              int? _calories, int? _quantity, unit? _quantityUnit) {
            Food _newFood = Food(
                name: _name,
                carbohydrates: _carbohydrates,
                fats: _fats,
                calories: _calories,
                quantity: _quantity,
                quantityUnit: _quantityUnit);

            setState(() {
              meal.foods.add(_newFood);
            });

            Navigator.of(context).pop();
          }

          Future<void> deleteMeal(Meal meal) async {
            Provider.of<MealFoodFirebaseData>(context, listen: false)
                .removeMeal(meal);
          }

          Future<void> deleteFood(String mealName, String foodName) async {
            Provider.of<MealFoodFirebaseData>(context, listen: false)
                .removeFoodFromMeal(mealName, foodName);
          }

          Future<Food> editFood(String mealName, Food food) async {
            return Provider.of<MealFoodFirebaseData>(context, listen: false)
                .editFoodFromMeal(mealName, food);
          }
          
          Future<void> updateMeal(Meal meal) async {
            Provider.of<MealFoodFirebaseData>(context, listen: false)
                .updateMeal(meal);
          }

          return GestureDetector(
            onTap: () {
              // Navegar para a tela de detalhes da refeição quando clicar em uma refeição
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealDetailsPage(
                    meal: meal,
                    onSubmit: newFood,
                    onDelete: deleteMeal,
                    onDeleteFood: deleteFood,
                    onEditFood: editFood,
                    selectedMealName: meal.name,
                    updateMeal: updateMeal,
                  ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
                    child: Text(
                      meal.toString(),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                          child: Text(
                            "Total calories: ${meal.totalCalories} Kcal",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor, fontSize: 16),
                          ),
                        ),
                        ClipOval(
                          child: Material(
                            color: Theme.of(context).primaryColor,
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) {
                                    // Passe o nome da refeição selecionada para o FoodForm
                                    return FoodForm(newFood, meal.name);
                                  },
                                );
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

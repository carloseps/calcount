import 'package:calcount/components/meal_list.dart';
import 'package:calcount/components/nav_drawer.dart';
import 'package:calcount/components/new_meal_form.dart';
import 'package:calcount/firebase/meal_food_firebase_data.dart';
import 'package:calcount/model/meal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key, required this.title});

  final String title;

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  late Future<void> _fetchMealsFuture;

  @override
  void initState() {
    super.initState();
    _fetchMealsFuture =
        Provider.of<MealFoodFirebaseData>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScale = mediaQuery.textScaler;
    final iconSize = mediaQuery.size.width > 600 ? 46.0 : 34.0;

    newMeal(String name, int? totalCalories, TimeOfDay? date) {
      Meal meal = Meal(
        name: name,
        foods: <Food>[],
        totalCalories: totalCalories,
        datetime: date,
      );

      Provider.of<MealFoodFirebaseData>(context, listen: false).addMeal(meal);
      Navigator.of(context).pop();
      setState(() {});
    }

    return Scaffold(
      drawer: const NavDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          textScaler: textScale,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) {
                  return MealForm(newMeal);
                },
              );
            },
            iconSize: iconSize,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _fetchMealsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados.'));
          } else {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Consumer<MealFoodFirebaseData>(
                builder: (context, mealData, child) {
                  if (mealData.meals.isEmpty) {
                    return const Center(
                      child: Text(
                        'Adicione uma refeição apertando em \'+\'.',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        Expanded(
                            child: MealList(dailyMealList: mealData.meals)),
                      ],
                    );
                  }
                },
              ),
            );
          }
        },
      ),
    );
  }
}

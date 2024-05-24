import 'package:calcount/components/nav_drawer.dart';
import 'package:calcount/components/new_meal_form.dart';
import 'package:calcount/firebase_options.dart';
import 'package:calcount/firebase/meal_food_firebase_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/meal_list.dart';
import 'firebase/meal_food_firebase_data.dart';
import 'model/meal.dart';
import 'package:get/get.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MealFoodFirebaseData()),
      ],
      child: GetMaterialApp(
        title: 'CalCount',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'CalCount'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
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
    }

    return Scaffold(
      drawer: const NavDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          textScaler: textScale,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      body: Container(
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
                  Expanded(child: MealList(dailyMealList: mealData.meals)),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

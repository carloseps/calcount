import 'package:calcount/components/mocked_data.dart';
import 'package:calcount/model/meal.dart';
import 'package:flutter/material.dart';

import 'components/meal_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalCount',
      theme: ThemeData(
        //
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CalCount'),
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
  Widget build(BuildContext context) {
    
    // Obtendo as informações de MediaQuery
    final mediaQuery = MediaQuery.of(context);
    // Obtendo o fator de escala de texto da MediaQuery
    final textScale = mediaQuery.textScaler;
    // Definindo o tamanho do ícone com base na largura da tela
    final iconSize = mediaQuery.size.width > 600 ? 46.0 : 34.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          iconSize: iconSize,
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            //abrir o drawer
          },
        ),
        title: Text(
          widget.title,
          textScaler: textScale,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              iconSize: iconSize,
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ))
        ],
        centerTitle: true,
      ),
      body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              //meals está vindo de mocked_data
              Expanded(child: MealList(dailyMealList: meals)),
            ],
          )),
    );
  }
}

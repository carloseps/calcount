import 'package:flutter/material.dart';

import '../model/meal.dart';

class MealDetailsPage extends StatelessWidget {
  final Meal meal;

  const MealDetailsPage({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          iconSize: 30.0,
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          meal.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            iconSize: 34.0,
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // TODO: Adicionar funcionalidade para adicionar alimentos à refeição
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ListView.builder(
          itemCount: meal.foods.length,
          itemBuilder: (context, index) {
            final food = meal.foods[index];
            return FoodTile(food: food);
          },
        ),
      ),
    );
  }
}

class FoodTile extends StatefulWidget {
  final Food food;

  const FoodTile({super.key, required this.food});

  @override
  _FoodTileState createState() => _FoodTileState();
}

class _FoodTileState extends State<FoodTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ExpansionTile(
        title: Text(
          '${widget.food.name} (${widget.food.quantity} ${widget.food.quantityUnit.toString().split('.').last})',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        trailing: RotationTransition(
          turns: AlwaysStoppedAnimation(_isExpanded ? 0.5 : 0), // faz o icone rodar quando clica
          child: const Icon(Icons.arrow_drop_down),
        ),
        onExpansionChanged: (isExpanded) {
          setState(() {
            _isExpanded = isExpanded;
          });
        },
        children: [
          _buildExpandedContent(),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // por enquanto valores fixos mas depois irão ser recebidos por parametro
            // vindo de cada food
            _buildExpandedField('Carb.', 25.7),
            _buildExpandedField('Prot.', 30.5),
            _buildExpandedField('Gord.', 12.4),
            _buildExpandedField('Total', 547.9),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedField(String label, double value) {
    String unit = label == 'Total' ? 'cals' : 'g';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Adiciona um espaçamento vertical
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$label ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '${value.toStringAsFixed(2)} $unit',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 17,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MealList extends StatelessWidget {
  final List<Meal> dailyMealList;

  const MealList({
    super.key,
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
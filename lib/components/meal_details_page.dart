import 'package:calcount/components/edit_food_form.dart';
import 'package:calcount/components/new_food_form.dart';
import 'package:flutter/material.dart';

import '../model/meal.dart';

class MealDetailsPage extends StatefulWidget {
  final Meal meal;
  final String selectedMealName; // Adicione esta linha
  final Function(String, double?, double?, int?, int?, unit?) onSubmit;
  final Function(Meal meal) onDelete;
  final Function(String mealName, String foodName) onDeleteFood;
  final Function(String mealName, Food food) onEditFood;

  MealDetailsPage(
      {super.key,
      required this.meal,
      required this.selectedMealName,
      required this.onSubmit,
      required this.onDelete,
      required this.onEditFood,
      required this.onDeleteFood});

  @override
  State<StatefulWidget> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage> {
  @override
  Widget build(BuildContext context) {
    _onSubmit(String name, double? carbohydrates, double? fats, int? calories,
        int? quantity, unit? quantityUnit) {
      // Adiciona a nova comida à lista local
      final newFood = Food(
        name: name,
        carbohydrates: carbohydrates,
        fats: fats,
        calories: calories,
        quantity: quantity,
        quantityUnit: quantityUnit,
      );
      setState(() {
        widget.meal.foods.add(newFood);

        // Notifica os ouvintes sobre a mudança na lista de comidas
        widget.onSubmit(
            name, carbohydrates, fats, calories, quantity, quantityUnit);
      });
    }

    _onDeleteFood(String mealName, String foodName) {
      setState(() {
        widget.onDeleteFood(mealName, foodName);
        widget.meal.foods.removeWhere((food) => food.name == foodName);
      });
    }

    _onEditFood(String mealName, Food food) async {
      widget.onEditFood(mealName, food);
      setState(() {
        final index = widget.meal.foods.indexWhere((f) => f.name == food.name);
        widget.meal.foods[index] = food;
      });
    }

    _onDelete() {
      setState(() {
        widget.onDelete(widget.meal);
      });
    }

    //Form modal
    openFoodFormModal(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (_) {
          return FoodForm(_onSubmit, widget.selectedMealName);
        },
      );
    }

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
          widget.meal.name,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            iconSize: 34.0,
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => openFoodFormModal(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: widget.meal.foods.isEmpty
                  ? Center(
                      child: Text("Adicione um alimento clicando no botão '+'"))
                  : ListView.builder(
                      itemCount: widget.meal.foods.length,
                      itemBuilder: (context, index) {
                        final food = widget.meal.foods[index];
                        return FoodTile(
                          food: food,
                          onDeleteFood: _onDeleteFood,
                          onEditFood: _onEditFood,
                          mealName: widget.meal.name,
                          foodIndex: index,
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onDelete(widget.meal);
                Navigator.pop(context);
              },
              child: const Text('Deletar refeição'),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodTile extends StatefulWidget {
  final Food food;
  final String mealName;
  final int foodIndex;
  final Function(String mealName, String foodName) onDeleteFood;
  final Function(String mealName, Food food) onEditFood;

  const FoodTile(
      {super.key,
      required this.food,
      required this.onDeleteFood,
      required this.mealName,
      required this.onEditFood,
      required this.foodIndex});

  @override
  _FoodTileState createState() => _FoodTileState();
}

class _FoodTileState extends State<FoodTile> {
  bool _isExpanded = false;

  openFoodEditModal(BuildContext context, String mealName, Food food) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return FoodEditForm(mealName, food, widget.onEditFood);
      },
    );
  }

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
          turns: AlwaysStoppedAnimation(
              _isExpanded ? 0.5 : 0), // faz o icone rodar quando clica
          child: const Icon(Icons.arrow_drop_down),
        ),
        onExpansionChanged: (isExpanded) {
          setState(() {
            _isExpanded = isExpanded;
          });
        },
        children: [
          _buildExpandedContent(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  widget.onDeleteFood(widget.mealName, widget.food.name);
                },
                child: const Text('Deletar comida'),
              ),
              ElevatedButton(
                onPressed: () {
                  openFoodEditModal(context, widget.mealName, widget.food);
                },
                child: const Text('Editar comida'),
              )
            ],
          )
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
            _buildExpandedField('Carb.', widget.food.carbohydrates!),
            _buildExpandedField('Prot.', widget.food.protein!),
            _buildExpandedField('Gord.', widget.food.fats!),
            _buildExpandedField(
                'Kcal', double.parse(widget.food.calories!.toString())),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedField(String label, double value) {
    String unit = label == 'Total' ? 'cals' : 'g';

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4), // Adiciona um espaçamento vertical
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

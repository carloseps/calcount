import 'package:calcount/components/food_list.dart';
import 'package:calcount/model/meal.dart';
import 'package:calcount/model/meal_type.dart';
import 'package:flutter/material.dart';

class MealForm extends StatefulWidget {
  Function(String, String) onSubmit;
  MealForm({required this.onSubmit, super.key});

  @override
  State<MealForm> createState() => _MealFormState();
}

class _MealFormState extends State<MealForm> {
  final _foodNameController = TextEditingController();
  final _foodQuantityController = TextEditingController();

  MealType _selectedMealType = MealType.cafe_manha;
  unit _selectedUnit = unit.g;

  final List<Food> _foods = [];

  @override
  Widget build(BuildContext context) {
    _submitForm() {}

    _addFood() {
      Food food = Food(
          name: _foodNameController.text,
          calories: 0,
          carbohydrates: 0,
          fats: 0,
          quantity: int.parse(_foodQuantityController.text),
          quantityUnit: _selectedUnit);

      setState(() {
        _foods.add(food);
      });
    }

    _changeDropdownMealTypeValue(MealType? newMealType) {
      setState(() {
        _selectedMealType = newMealType!;
      });
    }

    _changeDropdownUnitValue(unit? newUnit) {
      setState(() {
        _selectedUnit = newUnit!;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Refeição'),
      ),
      body: Flexible(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField(
                  value: _selectedMealType,
                  items: MealType.values
                      .map<DropdownMenuItem<MealType>>((MealType value) {
                    return DropdownMenuItem<MealType>(
                        value: value, child: Text(value.description));
                  }).toList(),
                  onChanged: _changeDropdownMealTypeValue,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _foodNameController,
                  decoration: const InputDecoration(labelText: 'Alimento'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _foodQuantityController,
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  keyboardType: TextInputType.number,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField(
                  value: _selectedUnit,
                  items: unit.values.map<DropdownMenuItem<unit>>((unit value) {
                    return DropdownMenuItem<unit>(
                        value: value, child: Text(value.name));
                  }).toList(),
                  onChanged: _changeDropdownUnitValue,
                ),
              ),
              _foods.isEmpty
                  ? const Center(
                      child: Text(
                      "Nenhum alimento adicionado",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w500),
                    ))
                  : FoodList(
                      foodList: _foods,
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: _addFood, child: Text('Adicionar Alimento')),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: _submitForm, child: Text('Cadastrar Refeição')),
              )
            ],
          ),
        ),
      ),
    );
  }
}

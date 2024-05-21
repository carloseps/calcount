import 'package:calcount/model/meal.dart';
import 'package:calcount/firebase/meal_food_firebase_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class FoodForm extends StatefulWidget {
  final String selectedMealName;

  Function(String, double?, double?, int?, int?, unit?) onSubmit;
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FoodForm(this.onSubmit, this.selectedMealName, {Key? key}) : super(key: key);

  @override
  State<FoodForm> createState() => _FoodFormState();
}

class _FoodFormState extends State<FoodForm> {
  final _nameController = TextEditingController();
  final _carbohydratesController = TextEditingController();
  final _fatsController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _quantityController = TextEditingController();
  unit _quantityUnit = unit.un;

  void _submitForm(MealFoodFirebaseData mealData) {
    final name = _nameController.text;
    final carbohydrates = double.tryParse(_carbohydratesController.text) ?? 0.0;
    final fats = double.tryParse(_fatsController.text) ?? 0.0;
    final proteins = double.tryParse(_proteinsController.text) ?? 0.0;
    final calories = int.tryParse(_caloriesController.text) ?? 0;
    final quantity = int.tryParse(_quantityController.text) ?? 1;

    if (name.isNotEmpty) {
      final newFood = Food(
        name: name,
        carbohydrates: carbohydrates,
        fats: fats,
        protein: proteins,
        calories: calories,
        quantity: quantity,
        quantityUnit: _quantityUnit,
      );

      mealData.addFoodToMeal(widget.selectedMealName, newFood);
      _resetForm();
    }
  }

  void _resetForm() {
    _nameController.clear();
    _carbohydratesController.clear();
    _fatsController.clear();
    _proteinsController.clear();
    _caloriesController.clear();
    _quantityController.clear();
    _quantityUnit = unit.un;
  }

  Widget _dropdown() {
    return DropdownButton(
      style: TextStyle(color: Theme.of(context).colorScheme.primary),
      items: unit.values
          .map((p) =>
          DropdownMenuItem(value: p, child: Text(p.name.toUpperCase())))
          .toList(),
      onChanged: (unit? p) {
        setState(() {
          _quantityUnit = p!;
        });
      },
      value: _quantityUnit,
    );
  }

  String? _formValidation(String? content) {
    if (content == null || content.isEmpty) {
      return null;
    }

    return double.tryParse(content) == null
        ? "Insira um valor válido (Ex: 12.3)"
        : null;
  }

  TextFormField _numberFormField(
      String label, TextEditingController controller) {
    return TextFormField(
      validator: _formValidation,
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MealFoodFirebaseData>(
      builder: (context, mealData, child) {
        return SingleChildScrollView( // Adicionando SingleChildScrollView
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Form(
              key: FoodForm._formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Preencha este campo";
                      }
                      return null;
                    },
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  _numberFormField("Carboidratos", _carbohydratesController),
                  _numberFormField("Calorias", _caloriesController),
                  TextFormField(
                    controller: _fatsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Gorduras'),
                  ),
                  TextFormField(
                    controller: _proteinsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Proteínas'),
                  ),
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                              'Unidade de medida selecionada: ${_quantityUnit.name}'),
                        ),
                        _dropdown(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (FoodForm._formKey.currentState!.validate()) {
                          _submitForm(mealData);
                        }
                      },
                      child: const Text('Cadastrar alimento'),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:calcount/model/meal.dart';
import 'package:calcount/firebase/meal_food_firebase_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class FoodEditForm extends StatefulWidget {
  final String selectedMealName;

  Food food;
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Function(String mealName, Food food) onSubmit;
  FoodEditForm(this.selectedMealName, this.food, this.onSubmit, {Key? key})
      : super(key: key);

  @override
  State<FoodEditForm> createState() => _FoodEditFormState();
}

class _FoodEditFormState extends State<FoodEditForm> {
  final _carbohydratesController = TextEditingController();
  final _fatsController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _quantityController = TextEditingController();
  late unit _quantityUnit;

  void _submitForm() {
    final carbohydrates = double.tryParse(_carbohydratesController.text) ?? 0.0;
    final fats = double.tryParse(_fatsController.text) ?? 0.0;
    final proteins = double.tryParse(_proteinsController.text) ?? 0.0;
    final calories = int.tryParse(_caloriesController.text) ?? 0;
    final quantity = int.tryParse(_quantityController.text) ?? 1;

    final newFood = Food(
      name: widget.food.name,
      carbohydrates: carbohydrates,
      fats: fats,
      protein: proteins,
      calories: calories,
      quantity: quantity,
      quantityUnit: _quantityUnit,
    );

    widget.onSubmit(widget.selectedMealName, newFood);

    _resetForm();
  }

  void _resetForm() {
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
  void initState() {
    super.initState();
    _quantityUnit = widget.food.quantityUnit!;
    _carbohydratesController.text = widget.food.carbohydrates.toString();
    _fatsController.text = widget.food.fats.toString();
    _proteinsController.text = widget.food.protein.toString();
    _caloriesController.text = widget.food.calories.toString();
    _quantityController.text = widget.food.quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Adicionando SingleChildScrollView
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: FoodEditForm._formKey,
          child: Column(
            children: [
              _numberFormField("Carboidratos", _carbohydratesController),
              _numberFormField("Calorias", _caloriesController),
              _numberFormField("Gorduras", _fatsController),
              _numberFormField("Proteínas", _proteinsController),
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
                    if (FoodEditForm._formKey.currentState!.validate()) {
                      _submitForm();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Editar alimento'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

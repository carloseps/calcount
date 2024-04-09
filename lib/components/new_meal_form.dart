import 'package:calcount/model/meal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class MealForm extends StatefulWidget {
  Function(String, int?, TimeOfDay?) onSubmit;
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  MealForm(this.onSubmit, {super.key});

  @override
  State<MealForm> createState() => _MealFormState();
}

class _MealFormState extends State<MealForm> {
  final _nameController = TextEditingController();
  final _totalCaloriesController = TextEditingController();
  TimeOfDay? _timeController;

  /// Retorna os dados para o widget pai por callback
  _submitForm() {
    final name = _nameController.text;
    final calories = int.tryParse(_totalCaloriesController.text);

    if (name.isEmpty) {
      return;
    }

    widget.onSubmit(name, calories, _timeController);
  }

  /// Possivelmente trocar por showTimePicker
  /// Abre o widget de seleção de data
  _showDatePicker() {
    showTimePicker(context: context, initialTime: TimeOfDay.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _timeController = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: MealForm._formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Preencha este campo";
                  }
                },
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextFormField(
                controller: _totalCaloriesController,
                decoration:
                    const InputDecoration(labelText: 'Total de calorias'),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                        'Data selecionada ${_timeController == null ? "Nenhuma" : _timeController!.format(context)}'),
                  ),
                  TextButton(
                      onPressed: _showDatePicker,
                      child: const Text('Selecionar data'))
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      if (MealForm._formKey.currentState!.validate()) {
                        _submitForm();
                      }
                    },
                    child: const Text('Cadastrar refeição')),
              )
            ],
          ),
        ));
  }
}

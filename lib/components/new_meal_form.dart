import 'dart:io';
import 'package:calcount/model/meal.dart';
import 'package:calcount/model/meal_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class MealForm extends StatefulWidget {
  Function(String, int?, TimeOfDay?, File?) onSubmit;
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  MealForm(this.onSubmit, {super.key});

  @override
  State<MealForm> createState() => _MealFormState();
}

class _MealFormState extends State<MealForm> {
  final _totalCaloriesController = TextEditingController();
  TimeOfDay? _timeController;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  MealType _selectedMealType = MealType.cafe_manha;

  /// Retorna os dados para o widget pai por callback
  _submitForm() {
    final name = _selectedMealType.description;
    final calories = int.tryParse(_totalCaloriesController.text);

    if (name.isEmpty) {
      return;
    }

    widget.onSubmit(name, calories, _timeController, _imageFile);
  }

  _changeDropdownMealTypeValue(MealType? newMealType) {
    setState(() {
      _selectedMealType = newMealType!;
    });
  }

  /// Abre o widget de seleção de data
  _showTimePicker() {
    showTimePicker(context: context, initialTime: TimeOfDay.now())
        .then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        _timeController = pickedTime;
      });
    });
  }

  /// Abre o seletor de imagem
  _showImagePicker() async {
    final pickedFile = await showDialog<XFile>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Escolha uma opção'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final pickedFile = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                Navigator.of(context).pop(pickedFile);
              },
              child: const Text('Tirar Foto'),
            ),
            TextButton(
              onPressed: () async {
                final pickedFile = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                Navigator.of(context).pop(pickedFile);
              },
              child: const Text('Selecionar da Galeria'),
            ),
          ],
        );
      },
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Form(
        key: MealForm._formKey,
        child: Column(
          children: [
            DropdownButtonFormField(
              value: _selectedMealType,
              items: MealType.values
                  .map<DropdownMenuItem<MealType>>((MealType value) {
                return DropdownMenuItem<MealType>(
                    value: value, child: Text(value.description));
              }).toList(),
              onChanged: _changeDropdownMealTypeValue,
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
                    onPressed: _showTimePicker,
                    child: const Text('Selecionar hora'))
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_imageFile == null
                          ? 'Nenhuma imagem selecionada'
                          : 'Imagem selecionada:'),
                      if (_imageFile != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Image.file(
                            _imageFile!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton(
                    onPressed: _showImagePicker,
                    child: const Text('Selecionar Imagem'))
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
      ),
    );
  }
}

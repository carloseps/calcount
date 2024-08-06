import 'package:calcount/components/edit_food_form.dart';
import 'package:calcount/components/new_food_form.dart';
import 'package:calcount/firebase/firebase_image_data.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../model/meal.dart';

class MealDetailsPage extends StatefulWidget {
  final Meal meal;
  final String selectedMealName;
  final Function(String, double?, double?, int?, int?, unit?) onSubmit;
  final Function(Meal meal) onDelete;
  final Function(String mealName, String foodName) onDeleteFood;
  final Function(String mealName, Food food) onEditFood;
  final Function(Meal meal) updateMeal;

  MealDetailsPage({
    super.key,
    required this.meal,
    required this.selectedMealName,
    required this.onSubmit,
    required this.onDelete,
    required this.onEditFood,
    required this.onDeleteFood,
    required this.updateMeal
  });

  @override
  State<StatefulWidget> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _editImage() async {
    await _onDeleteImage();
    _showImagePicker();
  }

  Future<void> _showImagePicker() async {
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
      // Implementar a lógica para fazer upload da imagem para o Firebase e atualizar a URL da imagem na refeição.
      String? newImageUrl = await _uploadImageToFirebase(_imageFile!);
      if (newImageUrl != null) {
        setState(() {
          widget.meal.imageUrl = newImageUrl;
          widget.updateMeal(widget.meal);
        });
      }
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    String imageUrl = await ImageFirebaseData().uploadImage(image);
    return imageUrl;
  }

  Future<void> _onDeleteImage() async {
    bool deleteSuccessful = await _deleteImageFromFirebase(widget.meal.imageUrl!);
    if (deleteSuccessful) {
      setState(() {
        widget.meal.imageUrl = null;
        widget.updateMeal(widget.meal);
      });
    }
  }

  Future<bool> _deleteImageFromFirebase(String imageUrl) async {
    return await ImageFirebaseData().deleteImage(imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    _onSubmit(String name, double? carbohydrates, double? fats, int? calories,
        int? quantity, unit? quantityUnit) {
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
            if (widget.meal.imageUrl != null || _imageFile != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Imagem selecionada:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (_imageFile != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Image.file(
                        _imageFile!,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    )
                  else if (widget.meal.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Image.network(
                        widget.meal.imageUrl!,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: _editImage,
                        child: const Text('Editar Imagem'),
                      ),
                      ElevatedButton(
                        onPressed: _onDeleteImage,
                        child: const Text('Deletar Imagem'),
                      ),
                    ],
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                            onPressed: _showImagePicker,
                            child: const Text('Adicionar Imagem'),
                          ),
                ],
              ),
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

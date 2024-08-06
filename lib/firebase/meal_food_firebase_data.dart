import 'dart:convert';
import 'package:calcount/firebase/firebase_image_data.dart';
import 'package:calcount/model/meal.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MealFoodFirebaseData with ChangeNotifier {
  final String _baseUrl = 'https://calcount-f6f51-default-rtdb.firebaseio.com/';
  final DatabaseReference mealReference =
      FirebaseDatabase.instance.reference().child('meals');

  final List<Meal> _meals = [];

  List<Meal> get meals {
    return [..._meals];
  }

  Future<void> fetchData(String user_id) async {
    try {
      _meals.clear();
      final snapshot =
          await mealReference.orderByChild("user_id").equalTo(user_id).once();

      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          final List<Food> foods = [];
          print("Value $value");
          print("Refeição user_id: ${value["user_id"]}");
          print("user_id: $user_id");
          if (value != null && value is Map && value['user_id'] == user_id) {
            print("Refeição válida");
            if (value['foods'] != null && value['foods'] is Map) {
              final foodData = value['foods'] as Map<dynamic, dynamic>;
              foodData.forEach((foodKey, foodValue) {
                if (foodValue != null && foodValue is Map) {
                  foods.add(Food(
                    name: foodValue['name'] as String? ?? '',
                    carbohydrates:
                        (foodValue['carbohydrates'] as num?)?.toDouble(),
                    protein: (foodValue['protein'] as num?)?.toDouble(),
                    fats: (foodValue['fats'] as num?)?.toDouble(),
                    calories: foodValue['calories'] as int?,
                    quantity: foodValue['quantity'] as int?,
                    quantityUnit: foodValue['quantityUnit'] != null
                        ? unit.values.firstWhere(
                            (e) =>
                                e.toString() ==
                                'unit.${foodValue['quantityUnit']}',
                            orElse: () => unit.g,
                          )
                        : null,
                  ));
                }
              });
            }
            final meal = Meal(
                name: value['name'] as String? ?? '', // Corrigido aqui
                foods: foods,
                datetime: value['datetime'] != null
                    ? TimeOfDay(
                        hour: (value['datetime']['hour'] as num).toInt(),
                        minute: (value['datetime']['minute'] as num).toInt(),
                      )
                    : null,
                imageUrl: value['imageUrl'],
                user_id: value["user_id"]);
            _meals.add(meal);
          }
        });
      } else {
        print('Nenhum dado encontrado no snapshot.');
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
    notifyListeners();
  }

  Future<void> addMeal(Meal meal) async {
    final response = await http.post(Uri.parse('$_baseUrl/meals.json'),
        body: jsonEncode({
          'name': meal.name,
          'foods':
              [], //cria lista vazia de foods pois n tem como adicionar foods quando cadastra uma meal
          'datetime': meal.datetime != null
              ? {
                  'hour': meal.datetime!.hour,
                  'minute': meal.datetime!.minute,
                }
              : null,
          'imageUrl': meal.imageUrl,
          'user_id': meal.user_id
        }));
    final id = meal.name;
    _meals.add(meal);
    notifyListeners();
  }

  Future<void> updateMeal(Meal meal) async {
    // Buscar o registro pelo nome
    final snapshot =
        await mealReference.orderByChild('name').equalTo(meal.name).once();

    // Extrair a chave do registro
    if (snapshot.snapshot.value != null) {
      final Map<dynamic, dynamic> mealsMap =
          snapshot.snapshot.value as Map<dynamic, dynamic>;
      final String mealKey = mealsMap.keys.first;

      // Atualizar outros campos da refeição
      await mealReference.child(mealKey).update({
        'name': meal.name,
        'datetime': meal.datetime != null
            ? {
                'hour': meal.datetime!.hour,
                'minute': meal.datetime!.minute,
              }
            : null,
        'imageUrl': meal.imageUrl,
        'user_id': meal.user_id,
      });

      // Atualizar a lista de foods
      // Primeiro, remover todas as foods existentes
      await mealReference.child(mealKey).child('foods').remove();

      // Depois, adicionar as foods atualizadas
      for (var food in meal.foods) {
        final foodRef = mealReference.child(mealKey).child('foods').push();
        final foodData = {
          'name': food.name,
          'carbohydrates': food.carbohydrates,
          'protein': food.protein,
          'fats': food.fats,
          'calories': food.calories,
          'quantity': food.quantity,
          'quantityUnit': food.quantityUnit.toString().split('.').last,
        };
        await foodRef.set(foodData);
      }
    }
    notifyListeners();
  }

  Future<void> removeMeal(Meal meal) async {
    try {
      final snapshot =
          await mealReference.orderByChild('name').equalTo(meal.name).once();

      if (snapshot.snapshot.value != null) {
        final mealData = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final mealId = mealData.keys.first;

        final mealRef = mealReference.child(mealId);

        // Verificar se a URL da imagem não é nula
        if (meal.imageUrl != null) {
          ImageFirebaseData().deleteImage(meal.imageUrl!);
        }

        await mealRef.remove();

        _meals.removeWhere((m) => m.name == meal.name);

        notifyListeners();
      } else {
        print("Refeição não encontrada: ${meal.name}");
      }
    } catch (e) {
      print("Erro ao remover refeição: $e");
    }
  }

  Future<void> saveMeal(Meal meal) {
    final existingMealIndex = _meals.indexWhere((m) => m.name == meal.name);
    if (existingMealIndex >= 0) {
      return updateMeal(meal);
    } else {
      return addMeal(meal);
    }
  }

  Future<void> addFoodToMeal(String mealName, Food food) async {
    try {
      // Obtenha a refeição existente do Firebase
      final snapshot =
          await mealReference.orderByChild('name').equalTo(mealName).once();

      if (snapshot.snapshot.value != null) {
        final mealData = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final mealId = mealData.keys.first;

        // Adiciona a comida à lista local de comidas da refeição
        final mealIndex = _meals.indexWhere((meal) => meal.name == mealName);
        if (mealIndex >= 0) {
          _meals[mealIndex].foods.add(food);
        }

        // Referência à comida no Firebase dentro da refeição existente
        final foodRef = mealReference.child(mealId).child('foods').push();

        // Estrutura de dados da comida a ser adicionada
        final foodData = {
          'name': food.name,
          'carbohydrates': food.carbohydrates,
          'protein': food.protein,
          'fats': food.fats,
          'calories': food.calories,
          'quantity': food.quantity,
          'quantityUnit': food.quantityUnit.toString().split('.').last,
        };

        // Adiciona a comida no Firebase
        await foodRef.set(foodData);

        notifyListeners();
      } else {
        print("Refeição não encontrada: $mealName");
      }
    } catch (e) {
      print("Erro ao adicionar comida à refeição: $e");
    }
  }

  Future<void> removeFoodFromMeal(String mealName, String foodName) async {
    try {
      // Obtenha a refeição existente do Firebase
      final snapshot =
          await mealReference.orderByChild('name').equalTo(mealName).once();

      if (snapshot.snapshot.value != null) {
        final mealData = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final mealId = mealData.keys.first;

        // Referência à lista de comidas dentro da refeição existente
        final foodsRef = mealReference.child(mealId).child('foods');
        final foodsSnapshot = await foodsRef.once();

        if (foodsSnapshot.snapshot.value != null) {
          final foodsData =
              foodsSnapshot.snapshot.value as Map<dynamic, dynamic>;

          // Encontrar o identificador da comida a ser removida
          String? foodKeyToRemove;
          foodsData.forEach((key, value) {
            if (value['name'] == foodName) {
              foodKeyToRemove = key;
            }
          });

          if (foodKeyToRemove != null) {
            // Remove a comida do Firebase
            await foodsRef.child(foodKeyToRemove!).remove();

            // Atualiza a lista local de comidas
            final mealIndex =
                _meals.indexWhere((meal) => meal.name == mealName);
            if (mealIndex >= 0) {
              _meals[mealIndex]
                  .foods
                  .removeWhere((food) => food.name == foodName);

              // Se a lista de foods estiver vazia, atualiza a refeição com uma lista vazia de foods
              if (_meals[mealIndex].foods.isEmpty) {
                await mealReference.child(mealId).update({
                  'foods': {},
                  'name': _meals[mealIndex].name,
                  'datetime': _meals[mealIndex].datetime != null
                      ? {
                          'hour': _meals[mealIndex].datetime!.hour,
                          'minute': _meals[mealIndex].datetime!.minute,
                        }
                      : null,
                });
              }
            }

            notifyListeners();
          } else {
            print("Comida não encontrada: $foodName");
          }
        } else {
          print("Nenhuma comida encontrada para a refeição: $mealName");
        }
      } else {
        print("Refeição não encontrada: $mealName");
      }
    } catch (e) {
      print("Erro ao remover comida da refeição: $e");
    }
  }

  Future<Food> editFoodFromMeal(String mealName, Food food) async {
    final meal =
        await mealReference.orderByChild('name').equalTo(mealName).once();

    if (meal.snapshot.value != null) {
      final mealData = meal.snapshot.value as Map<dynamic, dynamic>;
      final mealId = mealData.keys.first;

      // Referência à lista de comidas dentro da refeição existente
      final foodsRef = mealReference.child(mealId).child('foods');
      final foodsSnapshot =
          await foodsRef.orderByChild('name').equalTo(food.name).once();
      final foodData = foodsSnapshot.snapshot.value as Map<dynamic, dynamic>;
      final foodId = foodData.keys.first;

      final foodToUpdate = foodsRef.child(foodId);

      await foodToUpdate.update({
        "calories": food.calories ?? 0,
        "carbohydrates": food.carbohydrates ?? 0,
        "fats": food.fats ?? 0,
        "name": food.name.isEmpty ? "Sem nome" : food.name,
        "protein": food.protein ?? 0,
        "quantity": food.quantity ?? 0,
        "quantityUnit": food.quantityUnit.toString().split('.').last,
      });
    }
    notifyListeners();
    return Future.value(food);
  }
}

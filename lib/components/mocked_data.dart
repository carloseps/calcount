import '../model/meal.dart';

List<Meal> meals = [
      Meal(name: "Café da Manhã", foods: [
        Food(name: "Ovo", quantity: 3, quantityUnit: unit.un),
        Food(name: "Fatia de pão de forma", quantity: 4, quantityUnit: unit.un),
        Food(name: "Xícara de café", quantity: 150, quantityUnit: unit.ml),
        Food(name: "Fatia de queijo", quantity: 2, quantityUnit: unit.un)
      ]),
      Meal(name: "Almoço", foods: [
        Food(
            name: "Peito de frango assado", quantity: 200, quantityUnit: unit.g),
        Food(name: "Macarrão espaguete", quantity: 200, quantityUnit: unit.g),
        Food(name: "Feijão preto", quantity: 50, quantityUnit: unit.g),
        Food(name: "Coca cola", quantity: 200, quantityUnit: unit.ml)
      ]),
      Meal(name: "Lanche da tarde", foods: [
        Food(
          name: "Manteiga", quantity: 20, quantityUnit: unit.g
        ),
        Food(name: "Bolacha Jucurutu", quantity: 60, quantityUnit: unit.g),
        Food(name: "Xícara de café", quantity: 100, quantityUnit: unit.ml),
        Food(name: "Banana", quantity: 1, quantityUnit: unit.un)
      ]),
    ];
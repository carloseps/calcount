enum MealType {
  cafe_manha(description: 'Café da Manhã'),
  lanche_manha(description: 'Lanche da Manhã'),
  almoco(description: 'Almoço'),
  lanche_tarde(description: 'Lanche da Tarde'),
  jantar(description: 'Jantar'),
  ceia(description: 'Ceia');

  const MealType({required this.description});

  final String description;
}

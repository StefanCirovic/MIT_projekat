enum MealType {
  main,
  salad,
  dessert,
  drink,
}

extension MealTypeX on MealType {
  String get label {
    switch (this) {
      case MealType.main:
        return "Glavno jelo";
      case MealType.dessert:
        return "Dezert";
      case MealType.salad:
        return "Salata";
      case MealType.drink:
        return "Piće";
    }
  }
}

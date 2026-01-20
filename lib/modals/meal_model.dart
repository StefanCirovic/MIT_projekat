import 'package:e_menza/modals/meal_enum.dart';

class MealModel {
  final String id;
  final String name;
  final double price;
  final MealType? type; // main / dessert / drink
  final String mealTime; // breakfast / lunch / dinner
  final String image;
  final int calories;
  final bool isAvailable;

  MealModel({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.mealTime,
    required this.image,
    required this.calories,
    required this.isAvailable,
  });
}

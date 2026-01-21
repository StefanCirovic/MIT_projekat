import 'package:e_menza/modals/meal_model.dart';
import 'package:flutter/material.dart';
import 'package:e_menza/consts/app_constants.dart';
import 'package:e_menza/services/assets_manager.dart';
import 'package:e_menza/widgets/title_text.dart';

class MealDetailsScreen extends StatelessWidget {
  final MealModel meal;

  const MealDetailsScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(meal.name)),
      body: Center(
        child: Text(
          'Detalji za ${meal.name}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

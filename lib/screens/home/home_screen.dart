import 'package:flutter/material.dart';
import 'package:e_menza/consts/app_constants.dart';
import 'package:e_menza/services/assets_manager.dart';
import 'package:e_menza/widgets/title_text.dart';
import 'package:e_menza/screens/home/mealDetails_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("${AssetsManager.imagePath}/logo.png"),
        ),
        title: const Text("E-Menza"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const TitelesTextWidget(label: "Tip obroka"),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.3,
              children: List.generate(
                AppConstants.mealTimeCategories.length,
                (index) {
                  final meal = AppConstants.mealTimeCategories[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MealDetailsScreen(meal: meal),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              meal.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          meal.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

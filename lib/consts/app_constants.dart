import 'package:e_menza/modals/meal_model.dart';
import 'package:e_menza/services/assets_manager.dart';

class AppConstants {
  static const String imageUrl =
      'https://m.media-amazon.com/images/I/71nj3JM-igL._AC_UF894,1000_QL80_.jpg';

  static List<String> bannersImages = [
    "${AssetsManager.imagePath}/banners/mensa1.jpg",
    "${AssetsManager.imagePath}/banners/mensa2.jpg",
  ];

  static List<MealModel> mealTimeCategories = [
    MealModel(
      id: "breakfast",
      name: "Doručak",
      image: "${AssetsManager.imagePath}/categories/breakfast.jpg",
      type: null,
      mealTime: "breakfast",
      price: 0.0,
      calories: 0,
      isAvailable: true,
    ),
    MealModel(
      id: "lunch",
      name: "Ručak",
      image: "${AssetsManager.imagePath}/categories/lunch.jpg",
      type: null,
      mealTime: "lunch",
      price: 0.0,
      calories: 0,
      isAvailable: true,
    ),
    MealModel(
      id: "dinner",
      name: "Večera",
      image: "${AssetsManager.imagePath}/categories/dinner.jpg",
      type: null,
      mealTime: "dinner",
      price: 0.0,
      calories: 0,
      isAvailable: true,
    ),
  ];
}

import 'package:e_menza/modals/meal/meal_model.dart';
import 'package:flutter/material.dart';
import 'package:e_menza/modals/meal/meal_enum.dart';
import 'package:provider/provider.dart';
import 'package:e_menza/providers/student_providers.dart';
import 'package:e_menza/modals/student_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealDetailsScreen extends StatefulWidget {
  final MealModel meal;

  const MealDetailsScreen({super.key, required this.meal});

  @override
  State<MealDetailsScreen> createState() => MealDetailsScreenState();
}

class MealDetailsScreenState extends State<MealDetailsScreen> {
  MealModel? selectedMain;
  MealModel? selectedDessert;
  MealModel? selectedSalad;
  MealModel? selectedDrink;

  double _basePrice(String? mealTime) {
    switch (mealTime) {
      case 'breakfast':
        return 120;
      case 'lunch':
        return 250;
      case 'dinner':
        return 220;
      default:
        return 0;
    }
  }

  double _mealPrice(String? mealTime) {
    final StudentStatus status = context.read<StudentProvider>().status;
    final p = _basePrice(mealTime);
    return p * status.priceMultiplier;
  }

  MealModel _docToMealModel(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealModel(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      type: _stringToMealType(data['type']),
      mealTime: data['mealTime'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      calories: data['calories'] ?? 0,
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  MealType _stringToMealType(String? type) {
    switch (type) {
      case 'main':
        return MealType.main;
      case 'drink':
        return MealType.drink;
      case 'dessert':
        return MealType.dessert;
      case 'salad':
        return MealType.salad;
      default:
        return MealType.main;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalji: ${widget.meal.name}")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('meals')
            .where('mealTime', isEqualTo: widget.meal.mealTime)
            .where('isAvailable', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Greška: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nema dostupnih obroka za ovo vreme'),
            );
          }

          final meals =
              snapshot.data!.docs.map((doc) => _docToMealModel(doc)).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.meal.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                        ),
                        Text(
                          "Ponuda dana",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Glavno jelo
                if (_getMealsByType(meals, MealType.main).isNotEmpty) ...[
                  _buildMealSection(
                    "Glavno jelo",
                    _getMealsByType(meals, MealType.main),
                    (meal) => selectedMain = meal,
                    selectedMain,
                  ),
                  const SizedBox(height: 16),
                ],

                if (widget.meal.mealTime != 'breakfast' &&
                    _getMealsByType(meals, MealType.salad).isNotEmpty) ...[
                  _buildMealSection(
                    "Salate",
                    _getMealsByType(meals, MealType.salad),
                    (meal) => selectedSalad = meal,
                    selectedSalad,
                  ),
                  const SizedBox(height: 16),
                ],

                if (widget.meal.mealTime != 'breakfast' &&
                    _getMealsByType(meals, MealType.dessert).isNotEmpty) ...[
                  _buildMealSection(
                    "Dezerti",
                    _getMealsByType(meals, MealType.dessert),
                    (meal) => selectedDessert = meal,
                    selectedDessert,
                  ),
                  const SizedBox(height: 16),
                ],

                if (_getMealsByType(meals, MealType.drink).isNotEmpty) ...[
                  _buildMealSection(
                    "Pića",
                    _getMealsByType(meals, MealType.drink),
                    (meal) => selectedDrink = meal,
                    selectedDrink,
                  ),
                  const SizedBox(height: 16),
                ],

                // Ukupno i dugme za rezervaciju
                _buildSummarySection(),
              ],
            ),
          );
        },
      ),
    );
  }

  List<MealModel> _getMealsByType(List<MealModel> meals, MealType type) {
    return meals.where((meal) => meal.type == type).toList();
  }

  Widget _buildMealSection(
    String title,
    List<MealModel> meals,
    Function(MealModel) onSelect,
    MealModel? selected,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...meals.map((meal) => _buildMealItem(meal, onSelect, selected)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(
    MealModel meal,
    Function(MealModel) onSelect,
    MealModel? selected,
  ) {
    final isSelected = selected?.id == meal.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          onSelect(meal);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  Text(
                    '${meal.calories} kcal',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (meal.type == MealType.main)
              Text(
                '${meal.price.toStringAsFixed(0)} RSD',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Ukupno:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  "${_calculateTotalPrice().toStringAsFixed(0)} RSD",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Ukupno kalorija:", style: TextStyle(fontSize: 14)),
                Text(
                  "$_totalCalories kcal",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canReserve ? _reserve : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Rezerviši",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalPrice() {
    double total = 0;

    if (selectedMain != null) {
      total += _mealPrice(selectedMain!.mealTime);
    }
    return total;
  }

  int get _totalCalories {
    return (selectedMain?.calories ?? 0) +
        (selectedDessert?.calories ?? 0) +
        (selectedSalad?.calories ?? 0) +
        (selectedDrink?.calories ?? 0);
  }

  Set<MealType> _requiredTypesFor(String? mealTime) {
    if (mealTime == "breakfast") {
      return {MealType.main, MealType.drink};
    }
    return {MealType.main, MealType.dessert, MealType.salad, MealType.drink};
  }

  bool get _canReserve {
    final req = _requiredTypesFor(widget.meal.mealTime);
    final hasMain = !req.contains(MealType.main) || selectedMain != null;
    final hasDessert =
        !req.contains(MealType.dessert) || selectedDessert != null;
    final hasSalad = !req.contains(MealType.salad) || selectedSalad != null;
    final hasDrink = !req.contains(MealType.drink) || selectedDrink != null;
    return hasMain && hasDessert && hasSalad && hasDrink;
  }

  void _reserve() {
    if (!_canReserve) return;
    final req = _requiredTypesFor(widget.meal.mealTime);
    final List<String> lines = [];
    if (req.contains(MealType.main) && selectedMain != null) {
      lines.add("- ${selectedMain!.name}");
    }
    if (req.contains(MealType.dessert) && selectedDessert != null) {
      lines.add("- ${selectedDessert!.name}");
    }
    if (req.contains(MealType.salad) && selectedSalad != null) {
      lines.add("- ${selectedSalad!.name}");
    }
    if (req.contains(MealType.drink) && selectedDrink != null) {
      lines.add("- ${selectedDrink!.name}");
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rezervacija uspešna"),
        content: Text(
          "Rezervisao si:\n" +
              lines.join("\n") +
              "\n\nUkupno: ${_calculateTotalPrice().toStringAsFixed(0)} RSD • $_totalCalories kcal",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

import 'package:e_menza/modals/meal_model.dart';
import 'package:flutter/material.dart';
import 'package:e_menza/modals/meal_enum.dart';
import 'package:e_menza/consts/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:e_menza/providers/student_providers.dart';
import 'package:e_menza/modals/student_status.dart';

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

  late final List<MealModel> _todayOffer;
  void initState() {
    super.initState();

    _todayOffer = _buildMockOfferFor(widget.meal.mealTime);
  }

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

  List<MealModel> _buildMockOfferFor(String? mealTime) {
    if (mealTime == "breakfast") {
      return [
        MealModel(
          id: "${mealTime}_main_1",
          name: "Omlet sa sirom",
          image: "",
          type: MealType.main,
          mealTime: mealTime,
          price: _mealPrice(mealTime),
          calories: 420,
          isAvailable: true,
        ),
        MealModel(
          id: "${mealTime}_main_2",
          name: "Kifla sa šunkom",
          image: "",
          type: MealType.main,
          mealTime: mealTime,
          price: _mealPrice(mealTime),
          calories: 390,
          isAvailable: true,
        ),
        MealModel(
          id: "${mealTime}_drink_1",
          name: "Jogurt",
          image: "",
          type: MealType.drink,
          mealTime: mealTime,
          price: 0,
          calories: 120,
          isAvailable: true,
        ),
        MealModel(
          id: "${mealTime}_drink_2",
          name: "Sok",
          image: "",
          type: MealType.drink,
          mealTime: mealTime,
          price: 0,
          calories: 150,
          isAvailable: true,
        ),
      ];
    }
    return [
      MealModel(
        id: "${mealTime} main_1",
        name: "Piletina sa pirinčem",
        image: "",
        type: MealType.main,
        mealTime: mealTime,
        price: _mealPrice(mealTime),
        calories: 650,
        isAvailable: true,
      ),
      MealModel(
        id: "${mealTime} main_2",
        name: "Piletina ",
        image: "",
        type: MealType.main,
        mealTime: mealTime,
        price: _mealPrice(mealTime),
        calories: 650,
        isAvailable: true,
      ),
      MealModel(
        id: "${mealTime}_dessert_1",
        name: "Palačinke",
        image: "",
        type: MealType.dessert,
        mealTime: mealTime,
        price: 0,
        calories: 330,
        isAvailable: true,
      ),
      MealModel(
        id: "${mealTime}_dessert_2",
        name: "Kolač",
        image: "",
        type: MealType.dessert,
        mealTime: mealTime,
        price: 0,
        calories: 290,
        isAvailable: true,
      ),
      MealModel(
        id: "${mealTime}_salad_1",
        name: "Kupus salata",
        image: "",
        type: MealType.salad,
        mealTime: mealTime,
        price: 0,
        calories: 80,
        isAvailable: true,
      ),
      MealModel(
        id: "${mealTime}_salad_2",
        name: "Šopska salata",
        image: "",
        type: MealType.salad,
        mealTime: mealTime,
        price: 0,
        calories: 140,
        isAvailable: true,
      ),
      MealModel(
        id: "${mealTime}_drink_1",
        name: "Jogurt",
        image: "",
        type: MealType.drink,
        mealTime: mealTime,
        price: 0,
        calories: 120,
        isAvailable: true,
      ),
      MealModel(
        id: "${mealTime}_drink_2",
        name: "Sok",
        image: "",
        type: MealType.drink,
        mealTime: mealTime,
        price: 0,
        calories: 150,
        isAvailable: true,
      ),
    ];
  }

  List<MealModel> _byType(MealType t) =>
      _todayOffer.where((m) => m.type == t).toList();

  double get _totalPrice {
    final mainCost =
        selectedMain != null ? _mealPrice(selectedMain!.mealTime) : 0.0;
    return mainCost;
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
              "\n\nUkupno: ${_totalPrice.toStringAsFixed(0)} RSD • $_totalCalories kcal",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalji: ${widget.meal.name}")),
      body: SingleChildScrollView(
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
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ),
                    Text(
                      "Ponuda dana",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_requiredTypesFor(widget.meal.mealTime)
                .contains(MealType.main)) ...[
              sectionTitle("Glavno jelo "),
              choiceList(
                items: _byType(MealType.main),
                selected: selectedMain,
                onPick: (m) => setState(() => selectedMain = m),
              ),
              const SizedBox(height: 14),
            ],
            if (_requiredTypesFor(widget.meal.mealTime)
                .contains(MealType.dessert)) ...[
              sectionTitle("Dezert "),
              choiceList(
                items: _byType(MealType.dessert),
                selected: selectedDessert,
                onPick: (m) => setState(() => selectedDessert = m),
              ),
              const SizedBox(height: 14),
            ],
            if (_requiredTypesFor(widget.meal.mealTime)
                .contains(MealType.salad)) ...[
              sectionTitle("Salata "),
              choiceList(
                items: _byType(MealType.salad),
                selected: selectedSalad,
                onPick: (m) => setState(() => selectedSalad = m),
              ),
              const SizedBox(height: 14),
            ],
            if (_requiredTypesFor(widget.meal.mealTime)
                .contains(MealType.drink)) ...[
              sectionTitle("Piće"),
              choiceList(
                items: _byType(MealType.drink),
                selected: selectedDrink,
                onPick: (m) => setState(() => selectedDrink = m),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _row("Ukupno cena:",
                        "${_totalPrice.toStringAsFixed(0)} RSD"),
                    const SizedBox(height: 8),
                    _row("Ukupno kalorije:", "$_totalCalories kcal"),
                    const SizedBox(height: 10),
                    Text(
                      _canReserve
                          ? "Spremno za rezervaciju"
                          : "Izaberi po 1 stavku iz svake kategorije",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.event_available),
                label: const Text("Rezerviši obrok"),
                onPressed: _canReserve ? _reserve : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleMedium?.color,
        ),
      );

  Widget choiceList({
    required List<MealModel> items,
    required MealModel? selected,
    required void Function(MealModel m) onPick,
  }) {
    return Column(
      children: items.map((m) {
        final isSelected = selected?.id == m.id;
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: null,
            title: Text(
              m.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            subtitle: Text(
              m.type == MealType.main
                  ? "${_mealPrice(m.mealTime).toStringAsFixed(0)} RSD • ${m.calories} kcal"
                  : "${m.calories} kcal",
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle)
                : const Icon(Icons.circle_outlined),
            onTap: () => onPick(m),
          ),
        );
      }).toList(),
    );
  }

  Widget _row(String left, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left,
            style:
                TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
        Text(
          right,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}

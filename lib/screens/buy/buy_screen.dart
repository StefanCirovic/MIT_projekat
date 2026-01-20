import 'package:flutter/material.dart';
import 'purchase_meals_screen.dart';

class AccountScreen extends StatefulWidget {
  static const routeName = "/AccountScreen";
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  double _balance = 5050.0;
  final Map<MealTime, int> _monthlyLimit = {
    MealTime.breakfast: 30,
    MealTime.lunch: 30,
    MealTime.dinner: 30,
  };

  final Map<MealTime, int> _usedThisMonth = {
    MealTime.breakfast: 0,
    MealTime.lunch: 0,
    MealTime.dinner: 0,
  };

  final Map<MealTime, int> _onCard = {
    MealTime.breakfast: 5,
    MealTime.lunch: 10,
    MealTime.dinner: 3,
  };

  int remaining(MealTime t) => _monthlyLimit[t]! - _usedThisMonth[t]!;

  Future<void> _openPurchase(MealTime selectedMeal) async {
    final result = await Navigator.push<PurchaseResult>(
      context,
      MaterialPageRoute(
        builder: (_) => PurchaseMealsScreen(
          currentBalance: _balance,
          remainingMealsThisMonth: remaining(selectedMeal),
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _balance -= result.totalCost;
      _onCard[result.mealTime] = _onCard[result.mealTime]! + result.quantity;
      _usedThisMonth[result.mealTime] =
          _usedThisMonth[result.mealTime]! + result.quantity;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Kupljeno: ${result.quantity} x ${result.mealTime.label} (-${result.totalCost.toStringAsFixed(0)} RSD)",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Moj račun")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Stanje na računu",
                        style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 8),
                    Text(
                      "${_balance.toStringAsFixed(0)} RSD",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Obroci",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _mealRow(MealTime.breakfast),
            const SizedBox(height: 10),
            _mealRow(MealTime.lunch),
            const SizedBox(height: 10),
            _mealRow(MealTime.dinner),
          ],
        ),
      ),
    );
  }

  Widget _mealRow(MealTime t) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _miniStat("Dostupno za mesec", "${remaining(t)}")),
                const SizedBox(width: 10),
                Expanded(child: _miniStat("Na kartici", "${_onCard[t]}")),
                const SizedBox(width: 10),
                Expanded(child: _miniStat("Limit", "${_monthlyLimit[t]}")),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text("Kupi ${t.label}"),
                onPressed: () => _openPurchase(t),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String title, String value) {
    return Column(
      children: [
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

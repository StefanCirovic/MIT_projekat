import 'package:e_menza/providers/student_providers.dart';
import 'package:flutter/material.dart';
import 'purchase_meals_screen.dart';
import 'package:provider/provider.dart';
import 'package:e_menza/modals/meal/meal_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuyScreen extends StatefulWidget {
  static const routeName = "/BuyScreen";
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<BuyScreen> {
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

  double get _balance =>
      context.read<StudentProvider>().balance?.toDouble() ?? 0.0;

  int getOnCard(MealTime mealTime) {
    final student = context.read<StudentProvider>().currentStudent;
    switch (mealTime) {
      case MealTime.breakfast:
        return student?['onCardBreakfast']?.toInt() ?? 0;
      case MealTime.lunch:
        return student?['onCardLunch']?.toInt() ?? 0;
      case MealTime.dinner:
        return student?['onCardDinner']?.toInt() ?? 0;
    }
  }

  int remaining(MealTime t) {
    final student = context.read<StudentProvider>().currentStudent;

    final fieldMap = {
      MealTime.breakfast: 'remainingBreakfast',
      MealTime.lunch: 'remainingLunch',
      MealTime.dinner: 'remainingDinner',
    };
    return (student?[fieldMap[t]] as num?)?.toInt() ?? 0;
  }

  Future<void> _openPurchase(MealTime selectedMeal) async {
    final studentStatus = context.read<StudentProvider>().status;
    final result = await Navigator.push<PurchaseResult>(
      context,
      MaterialPageRoute(
        builder: (_) => PurchaseMealsScreen(
          currentBalance: _balance,
          remainingMealsThisMonth: remaining(selectedMeal),
          preselectedMeal: selectedMeal,
          studentStatus: studentStatus,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _usedThisMonth[result.mealTime] =
          _usedThisMonth[result.mealTime]! + result.quantity;
    });

    final studentProvider = context.read<StudentProvider>();
    final newBalance = (studentProvider.balance ?? 0.0) - result.totalCost;

    await FirebaseFirestore.instance
        .collection('students')
        .doc(studentProvider.cardNumber)
        .update({'balance': newBalance});

    final currentOnCard = getOnCard(result.mealTime);
    final newOnCard = currentOnCard + result.quantity;

    String onCardField;
    switch (result.mealTime) {
      case MealTime.breakfast:
        onCardField = 'onCardBreakfast';
        break;
      case MealTime.lunch:
        onCardField = 'onCardLunch';
        break;
      case MealTime.dinner:
        onCardField = 'onCardDinner';
        break;
    }

    String remainingField;
    switch (result.mealTime) {
      case MealTime.breakfast:
        remainingField = 'remainingBreakfast';
        break;
      case MealTime.lunch:
        remainingField = 'remainingLunch';
        break;
      case MealTime.dinner:
        remainingField = 'remainingDinner';
        break;
    }
    final currentRemaining = remaining(result.mealTime);
    final newRemaining = currentRemaining - result.quantity;

    final currentUsed = _usedThisMonth[result.mealTime]!;
    String usedField;
    switch (result.mealTime) {
      case MealTime.breakfast:
        usedField = 'usedBreakfast';
        break;
      case MealTime.lunch:
        usedField = 'usedLunch';
        break;
      case MealTime.dinner:
        usedField = 'usedDinner';
        break;
    }

    await FirebaseFirestore.instance
        .collection('students')
        .doc(studentProvider.cardNumber)
        .update({
      onCardField: newOnCard,
      usedField: currentUsed,
      remainingField: newRemaining,
    });

    final updatedStudent =
        Map<String, dynamic>.from(studentProvider.currentStudent ?? {});
    updatedStudent['balance'] = newBalance;
    updatedStudent[onCardField] = newOnCard;
    updatedStudent[usedField] = currentUsed;
    updatedStudent[remainingField] = newRemaining;
    studentProvider.setCurrentStudent(updatedStudent);

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
                    Text(
                      "Stanje na računu",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                )),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _miniStat("Dostupno za mesec", "${remaining(t)}")),
                const SizedBox(width: 10),
                Expanded(child: _miniStat("Na kartici", "${getOnCard(t)}")),
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
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            )),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:e_menza/modals/student_status.dart';
import 'package:e_menza/providers/student_providers.dart';

enum MealTime { breakfast, lunch, dinner }

extension MealTimeX on MealTime {
  String get label {
    switch (this) {
      case MealTime.breakfast:
        return "Doručak";
      case MealTime.lunch:
        return "Ručak";
      case MealTime.dinner:
        return "Večera";
    }
  }
}

class PurchaseResult {
  final MealTime mealTime;
  final int quantity;
  final double totalCost;

  const PurchaseResult({
    required this.mealTime,
    required this.quantity,
    required this.totalCost,
  });
}

class PurchaseMealsScreen extends StatefulWidget {
  static const routeName = "/PurchaseMealsScreen";

  const PurchaseMealsScreen({
    super.key,
    required this.currentBalance,
    required this.remainingMealsThisMonth,
    required this.preselectedMeal,
    required this.studentStatus,
  });

  final double currentBalance;
  final int remainingMealsThisMonth;
  final MealTime preselectedMeal;
  final StudentStatus studentStatus;

  @override
  State<PurchaseMealsScreen> createState() => _PurchaseMealsScreenState();
}

class _PurchaseMealsScreenState extends State<PurchaseMealsScreen> {
  late MealTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.preselectedMeal;
  }

  int _qty = 1;

  double basePrice(MealTime t) {
    switch (t) {
      case MealTime.breakfast:
        return 120;
      case MealTime.lunch:
        return 250;
      case MealTime.dinner:
        return 220;
    }
  }

  double mealPrice(MealTime t) {
    final p = basePrice(t);
    return p * widget.studentStatus.priceMultiplier; // x1.5 za samofinansiranje
  }

  double get _total => mealPrice(_selected) * _qty;

  bool get _canBuy {
    if (_qty <= 0) return false;
    if (_qty > widget.remainingMealsThisMonth) return false;
    if (_total > widget.currentBalance) return false;
    return true;
  }

  String? get _errorText {
    if (_qty > widget.remainingMealsThisMonth) {
      return "Nemaš dovoljno dostupnih obroka za ovaj mesec.";
    }
    if (_total > widget.currentBalance) {
      return "Nemaš dovoljno sredstava na računu.";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final price = mealPrice(_selected);
    return Scaffold(
      appBar: AppBar(title: const Text("Kupi obroke")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Izaberi obrok",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // izbor obroka
            Wrap(
              spacing: 10,
              children: MealTime.values.map((m) {
                final selected = m == _selected;
                return ChoiceChip(
                  label: Text(
                      "${m.label} (${mealPrice(m).toStringAsFixed(0)} RSD)"),
                  selected: selected,
                  onSelected: (_) => setState(() => _selected = m),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const Text(
              "Broj obroka",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 38, 88, 255)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$_qty",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _qty++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const Spacer(),
                Text(
                  "Cena/obrok: ${price.toStringAsFixed(0)} RSD",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                )
              ],
            ),

            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row("Trenutno stanje:",
                        "${widget.currentBalance.toStringAsFixed(0)} RSD"),
                    const SizedBox(height: 8),
                    _row("Dostupno ovaj mesec:",
                        "${widget.remainingMealsThisMonth}"),
                    const Divider(height: 24),
                    _row(
                      "Ukupno za kupovinu:",
                      "${_total.toStringAsFixed(0)} RSD",
                      valueStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 10),
                      Text(_errorText!,
                          style: const TextStyle(color: Colors.red)),
                    ]
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Potvrdi kupovinu"),
                onPressed: _canBuy
                    ? () {
                        Navigator.pop(
                          context,
                          PurchaseResult(
                            mealTime: _selected,
                            quantity: _qty,
                            totalCost: _total,
                          ),
                        );
                      }
                    : null,
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

  Widget _row(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
        Text(value,
            style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_menza/providers/student_providers.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController(); // MM/YY
  final _cvvController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String? _amountValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Unesi iznos';
    final value = double.tryParse(v.replaceAll(',', '.'));
    if (value == null || value <= 0) return 'Unesi ispravan iznos (> 0)';
    return null;
  }

  String? _notEmpty(String? v, String label) {
    if (v == null || v.trim().isEmpty) return 'Unesi $label';
    return null;
  }

  String? _cardValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Unesi broj kartice';
    final digits = v.replaceAll(RegExp(r'\s+'), '');
    if (digits.length != 16)
      return 'Broj kartice mora imati tačno 16 cifara';
    return null;
  }

  String? _cvvValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Unesi CVV';
    final digits = v.replaceAll(RegExp(r'\s+'), '');
    if (digits.length != 3)
      return 'CVV mora imati tačno 3 cifre';
    return null;
  }

  String? _expiryValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Unesi MM/YY';
    final parts = v.split('/');
    if (parts.length != 2) return 'Format je MM/YY';
    final mm = int.tryParse(parts[0]);
    final yy = int.tryParse(parts[1]);
    if (mm == null || yy == null || mm < 1 || mm > 12)
      return 'Neispravan datum';
    return null;
  }

  String _maskCard(String input) {
    final digits = input.replaceAll(RegExp(r'\s+'), '');
    if (digits.length <= 4) return digits;
    final last4 = digits.substring(digits.length - 4);
    return '**** **** **** $last4';
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (!valid) return;

    setState(() => _isLoading = true);

    try {
      final amount = _amountController.text.replaceAll(',', '.');
      final masked = _maskCard(_cardController.text);

      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      final currentBalance = studentProvider.balance ?? 0.0;
      final newBalance = currentBalance + double.parse(amount);

      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentProvider.cardNumber)
          .update({'balance': newBalance});

      final updatedStudent = Map<String, dynamic>.from(studentProvider.currentStudent ?? {});
      updatedStudent['balance'] = newBalance;
      studentProvider.setCurrentStudent(updatedStudent);

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Uplata uspešna'),
          content: Text(
              'Kartica: $masked\nIznos: ${double.parse(amount).toStringAsFixed(2)} RSD\nNovo stanje: ${newBalance.toStringAsFixed(2)} RSD'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri uplati: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final accountNumber = studentProvider.accountNumber ?? 'N/A';
    
    return Scaffold(
      appBar: AppBar(title: const Text('Uplata sredstava')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vaš žiro račun:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              accountNumber,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Iznos (RSD)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: _amountValidator,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ime i prezime (na kartici)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _notEmpty(v, 'ime i prezime'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cardController,
                  decoration: const InputDecoration(
                    labelText: 'Broj kartice',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _cardValidator,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryController,
                        decoration: const InputDecoration(
                          labelText: 'MM/YY',
                          prefixIcon: Icon(Icons.date_range_outlined),
                        ),
                        keyboardType: TextInputType.datetime,
                        validator: _expiryValidator,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        validator: _cvvValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(_isLoading ? 'Uplata u toku...' : 'Potvrdi uplatu'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

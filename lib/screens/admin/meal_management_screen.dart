import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_menza/widgets/title_text.dart';
import 'package:e_menza/widgets/subtitle_text.dart';

class MealManagementScreen extends StatefulWidget {
  static const String routeName = "/MealManagementScreen";
  const MealManagementScreen({super.key});

  @override
  State<MealManagementScreen> createState() => _MealManagementScreenState();
}

class _MealManagementScreenState extends State<MealManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedMealTime = 'breakfast';
  String _selectedMealType = 'main';
  bool _isLoading = false;

  final List<String> _mealTimes = ['breakfast', 'lunch', 'dinner'];
  final List<String> _mealTypes = ['main', 'drink', 'dessert', 'salad'];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _caloriesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addMeal() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unesite naziv i cenu obroka'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final mealData = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'calories': int.tryParse(_caloriesController.text) ?? 0,
        'description': _descriptionController.text,
        'mealTime': _selectedMealTime,
        'type': _selectedMealType,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('meals').add(mealData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Obrok uspešno dodat'),
          backgroundColor: Colors.green,
        ),
      );

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleMealStatus(String mealId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('meals')
          .doc(mealId)
          .update({'isAvailable': !currentStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(!currentStatus ? 'Obrok aktiviran' : 'Obrok deaktiviran'),
          backgroundColor: !currentStatus ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }

  Future<void> _deleteMeal(String mealId) async {
    try {
      await FirebaseFirestore.instance.collection('meals').doc(mealId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Obrok obrisan'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _caloriesController.clear();
    _descriptionController.clear();
    _selectedMealTime = 'breakfast';
    _selectedMealType = 'main';
  }

  void _showEditDialog(Map<String, dynamic> meal) {
    _nameController.text = meal['name'] ?? '';
    _priceController.text = meal['price']?.toString() ?? '';
    _caloriesController.text = meal['calories']?.toString() ?? '';
    _descriptionController.text = meal['description'] ?? '';
    _selectedMealTime = meal['mealTime'] ?? 'breakfast';
    _selectedMealType = meal['type'] ?? 'main';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izmeni obrok'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Naziv'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Cena'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Kalorije'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Opis'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedMealTime,
                decoration: const InputDecoration(labelText: 'Vreme obroka'),
                items: _mealTimes.map((time) {
                  return DropdownMenuItem(
                    value: time,
                    child: Text(time),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMealTime = value!;
                  });
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedMealType,
                decoration: const InputDecoration(labelText: 'Tip obroka'),
                items: _mealTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMealType = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _updateMeal(meal['id']);
            },
            child: const Text('Sačuvaj'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMeal(String mealId) async {
    try {
      await FirebaseFirestore.instance.collection('meals').doc(mealId).update({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'calories': int.tryParse(_caloriesController.text) ?? 0,
        'description': _descriptionController.text,
        'mealTime': _selectedMealTime,
        'type': _selectedMealType,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Obrok uspešno ažuriran'),
          backgroundColor: Colors.green,
        ),
      );

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upravljanje Obrocima'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Form za dodavanje obroka
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TitlesTextWidget(label: "Dodaj Novi Obrok"),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Naziv obroka',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Cena',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _caloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Kalorije',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Opis',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedMealTime,
                      decoration:
                          const InputDecoration(labelText: 'Vreme obroka'),
                      items: _mealTimes.map((time) {
                        return DropdownMenuItem(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMealTime = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedMealType,
                      decoration:
                          const InputDecoration(labelText: 'Tip obroka'),
                      items: _mealTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMealType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addMeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Dodaj obrok'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lista obroka
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('meals').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Greška: ${snapshot.error}'));
                }

                final meals = snapshot.data!.docs;

                if (meals.isEmpty) {
                  return const Center(
                    child: Text('Nema dodatih obroka'),
                  );
                }

                return ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index].data() as Map<String, dynamic>;
                    final mealId = meals[index].id;
                    final name = meal['name'] ?? '';
                    final price = meal['price']?.toString() ?? '0';
                    final calories = meal['calories']?.toString() ?? '0';
                    final mealTime = meal['mealTime'] ?? '';
                    final type = meal['type'] ?? '';
                    final isAvailable = meal['isAvailable'] ?? true;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isAvailable ? Colors.green : Colors.grey,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'M',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        title: Text(name),
                        subtitle: Text(
                            '$price RSD • $calories kal • $mealTime • $type'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status toggle
                            Switch(
                              value: isAvailable,
                              onChanged: (value) {
                                _toggleMealStatus(mealId, isAvailable);
                              },
                            ),
                            const SizedBox(width: 8),
                            // Edit dugme
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showEditDialog({...meal, 'id': mealId});
                              },
                            ),
                            // Delete dugme
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmDialog(mealId, name);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(String mealId, String mealName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obriši obrok'),
        content:
            Text('Da li ste sigurni da želite da obrišete obrok "$mealName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteMeal(mealId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );
  }
}

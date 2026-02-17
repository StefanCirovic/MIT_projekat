import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:e_menza/providers/student_providers.dart';
import 'package:e_menza/widgets/title_text.dart';
import 'package:e_menza/widgets/subtitle_text.dart';
import 'package:e_menza/modals/student_status.dart';

class StudentManagementScreen extends StatefulWidget {
  static const String routeName = "/StudentManagementScreen";
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _indexController = TextEditingController();
  final TextEditingController _newCardNumberController =
      TextEditingController();
  bool _isLoading = false;
  StudentStatus _selectedStatus = StudentStatus.budget;

  final List<StudentStatus> _statusOptions = [
    StudentStatus.budget,
    StudentStatus.selfFinancing,
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _indexController.dispose();
    _newCardNumberController.dispose();
    super.dispose();
  }

  Future<void> _toggleStudentStatus(
      String cardNumber, bool currentStatus) async {
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(cardNumber)
          .update({'isActive': !currentStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              !currentStatus ? 'Student aktiviran' : 'Student deaktiviran'),
          backgroundColor: !currentStatus ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetRemainingMeals(String cardNumber) async {
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(cardNumber)
          .update({
        'remainingBreakfast': 30,
        'remainingLunch': 30,
        'remainingDinner': 30,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remaining obroka je resetovan na 30'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateCardNumber(
      String oldCardNumber, String newCardNumber) async {
    setState(() => _isLoading = true);

    try {
      // Proveri da li novi broj kartice već postoji
      final newDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(newCardNumber)
          .get();

      if (newDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Novi broj kartice već postoji'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Ažuriraj broj kartice
      await FirebaseFirestore.instance
          .collection('students')
          .doc(oldCardNumber)
          .update({'cardNumber': newCardNumber});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Broj kartice uspešno promenjen'),
          backgroundColor: Colors.green,
        ),
      );

      _clearControllers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearControllers() {
    _cardNumberController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _newCardNumberController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upravljanje Studentima'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Greška: ${snapshot.error}'));
          }

          final students = snapshot.data!.docs;

          if (students.isEmpty) {
            return const Center(
              child: Text('Nema registrovanih studenata'),
            );
          }

          return Column(
            children: [
              // Form za promenu broja kartice
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TitlesTextWidget(label: "Promena Broja Kartice"),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _cardNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Trenutni broj kartice',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _newCardNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Novi broj kartice',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_cardNumberController.text.isNotEmpty &&
                                        _newCardNumberController
                                            .text.isNotEmpty) {
                                      _updateCardNumber(
                                        _cardNumberController.text,
                                        _newCardNumberController.text,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('Promeni broj kartice'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Lista studenata
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student =
                        students[index].data() as Map<String, dynamic>;
                    final cardNumber = student['cardNumber'] ?? '';
                    final firstName = student['firstName'] ?? '';
                    final lastName = student['lastName'] ?? '';
                    final email = student['email'] ?? '';
                    final isActive = student['isActive'] ?? true;
                    final status = student['status'] ?? 'budget';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            '${firstName[0]}${lastName.isNotEmpty ? lastName[0] : ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text('$firstName $lastName'),
                        subtitle: Text(
                            '$cardNumber - $email\nStatus: ${status == 'budget' ? 'Budžet' : 'Samofinansiranje'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: isActive,
                              onChanged: (value) {
                                _toggleStudentStatus(cardNumber, isActive);
                              },
                            ),
                            const SizedBox(width: 8),
                            if (isActive)
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _showEditDialog(student);
                                },
                              ),
                            if (isActive)
                              IconButton(
                                icon: const Icon(Icons.refresh,
                                    color: Colors.green),
                                onPressed: () {
                                  _resetRemainingMeals(cardNumber);
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddStudentDialog() {
    _cardNumberController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _indexController.clear();
    _selectedStatus = StudentStatus.budget;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dodaj Novog Studenta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Broj kartice',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Ime',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Prezime',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _indexController,
                decoration: const InputDecoration(
                  labelText: 'Index',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<StudentStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status studenta'),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem<StudentStatus>(
                    value: status,
                    child: Text(status == StudentStatus.budget
                        ? 'Budžet'
                        : 'Samofinansiranje'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
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
              await _addNewStudent();
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewStudent() async {
    if (_cardNumberController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _indexController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sva polja su obavezna'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final existingDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(_cardNumberController.text)
          .get();

      if (existingDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Broj kartice već postoji'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('students')
          .doc(_cardNumberController.text)
          .set({
        'cardNumber': _cardNumberController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'index': _indexController.text,
        'email': '', // prazan email
        'status': _selectedStatus.name,
        'isActive': true,
        'role': 'student',
        'balance': 0.0,
        'mealsRemaining': 0,
        'pinHash': '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student uspešno dodat'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEditDialog(Map<String, dynamic> student) {
    _cardNumberController.text = student['cardNumber'] ?? '';
    _firstNameController.text = student['firstName'] ?? '';
    _lastNameController.text = student['lastName'] ?? '';
    _emailController.text = student['email'] ?? '';

    final statusString = student['status'] ?? 'budget';
    _selectedStatus = statusString == 'self_financing'
        ? StudentStatus.selfFinancing
        : StudentStatus.budget;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izmeni podatke'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Ime'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Prezime'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<StudentStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status studenta'),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem<StudentStatus>(
                    value: status,
                    child: Text(status == StudentStatus.budget
                        ? 'Budžet'
                        : 'Samofinansiranje'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
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
              await _updateStudentData(student['cardNumber']);
            },
            child: const Text('Sačuvaj'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStudentData(String cardNumber) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(cardNumber)
          .update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'status': _selectedStatus.name,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Podaci uspešno ažurirani'),
          backgroundColor: Colors.green,
        ),
      );

      _clearControllers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    }
  }
}

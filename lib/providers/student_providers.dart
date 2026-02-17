import 'package:flutter/material.dart';
import 'package:e_menza/modals/student_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class StudentProvider with ChangeNotifier {
  StudentStatus _status = StudentStatus.budget;
  Map<String, dynamic>? _currentStudent;

  StudentStatus get status => _status;
  Map<String, dynamic>? get currentStudent => _currentStudent;
  String? get cardNumber => _currentStudent?['cardNumber'];
  String? get firstName => _currentStudent?['firstName'];
  String? get lastName => _currentStudent?['lastName'];
  String? get email => _currentStudent?['email'];
  String? get index => _currentStudent?['index'];
  String? get accountNumber => _currentStudent?['accountNumber'];
  double? get balance => currentStudent?['balance']?.toDouble();
  String? get role => _currentStudent?['role'];
  bool get isLoggedIn => _currentStudent != null;
  bool get isAdmin => role == 'admin';

  void setStatus(StudentStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  void setCurrentStudent(Map<String, dynamic> student) {
    _currentStudent = student;

    final statusString = student['status'] ?? 'budget';
    if (statusString == 'selfFinancing') {
      _status = StudentStatus.selfFinancing;
    } else {
      _status = StudentStatus.budget;
    }

    notifyListeners();
  }

  Future<void> updateStatus() async {
    if (_currentStudent == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(_currentStudent!['cardNumber'])
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setCurrentStudent(data);
      }
    } catch (e) {
      print('Update status error: $e');
    }
  }

  void logout() {
    _currentStudent = null;
    notifyListeners();
  }

  // Hash funkcija za PIN
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> login(String cardNumber, String pin) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(cardNumber)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data()!;
      final storedPinHash = data['pinHash'] ?? '';
      final isActive = data['isActive'] ?? false;

      if (storedPinHash.isEmpty) {
        return false;
      }

      if (!isActive) {
        return false;
      }

      // Provera PIN-a sa hash-om
      final enteredPinHash = _hashPin(pin);
      if (storedPinHash != enteredPinHash) {
        return false;
      }

      setCurrentStudent(data);
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<String> register(String cardNumber, String pin, String email) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(cardNumber)
          .get();

      if (!doc.exists) {
        return 'Broj kartice ne postoji';
      }

      final pinHash = _hashPin(pin);

      await doc.reference.update({
        'pinHash': pinHash,
        'email': email,
      });

      return 'success';
    } catch (e) {
      print('Register error: $e');
      return 'Greška pri registraciji';
    }
  }

  Future<String> forgotPin(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return 'Email nije pronađen';
      }

      return 'Poslat je email sa PIN-om';
    } catch (e) {
      print('Forgot PIN error: $e');
      return 'Greška pri slanju email-a';
    }
  }
}

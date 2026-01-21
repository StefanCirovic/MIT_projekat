import 'package:flutter/material.dart';
import 'package:e_menza/modals/student_status.dart';

class StudentProvider with ChangeNotifier {
  StudentStatus _status = StudentStatus.budget;

  StudentStatus get status => _status;

  void setStatus(StudentStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}

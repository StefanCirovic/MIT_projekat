enum StudentStatus {
  budget,
  selfFinancing,
}

extension StudentStatusX on StudentStatus {
  String get label {
    switch (this) {
      case StudentStatus.budget:
        return "Budžet";
      case StudentStatus.selfFinancing:
        return "Samofinansiranje";
    }
  }

  double get priceMultiplier {
    switch (this) {
      case StudentStatus.budget:
        return 1.0;
      case StudentStatus.selfFinancing:
        return 1.5;
    }
  }
}

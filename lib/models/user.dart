class User {
  final String cardNumber;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  User({
    required this.cardNumber,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.role = 'user',
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      cardNumber: map['cardNumber'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  bool get isAdmin => role == 'admin';
  
  String get fullName => '$firstName $lastName';
  
  Map<String, dynamic> toMap() {
    return {
      'cardNumber': cardNumber,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
    };
  }
}

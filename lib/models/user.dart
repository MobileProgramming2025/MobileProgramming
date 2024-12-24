class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  // final List<Course> courses;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    // required this.courses,
  });

  // Convert a User object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'department': department,
    };
  }

  // Create a User object from Firestore Map
  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      department: map['department'] as String,
    );
  }

}
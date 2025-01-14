class Department {
  final String id;
  final String name;
  final String capacity;

  Department({
    required this.id,
    required this.name,
    required this.capacity,
  });

  // Convert a Department object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
    };
  }

  // Convert Firestore data to a Department object
  // factory constructor is a special type of constructor used to return an instance of a class
  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      capacity: map['capacity'] ?? '',
    );
  }
}

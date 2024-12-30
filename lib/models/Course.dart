class Course {
  final String id;
  final String name;
  final String code;
  final String drName;
  final String taName;
  final String departmentName;
  final String year;

  Course(
      {required this.id,
      required this.name,
      required this.code,
      required this.drName,
      required this.taName,
      required this.year,
      required this.departmentName});

  // Convert a Course object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'drName': drName,
      'taName': taName,
      'departmentName': departmentName,
      'year': year,
    };
  }

  // Convert Firestore data to a course object
  factory Course.fromMap(Map<String, dynamic> data) {
    return Course(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      drName: data['drName'] ?? '',
      taName: data['taName'] ?? '',
      departmentName: data['departmentName'] ?? '',
      year: data['year'] ?? '',
    );
  }
}

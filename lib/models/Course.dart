class Course {
  final String id;
  final String name;
  final String code;
  final String drId;
  final String taId;
  final String departmentName;
  final String year;

  Course(
      {required this.id,
      required this.name,
      required this.code,
      required this.drId,
      required this.taId,
      required this.year,
      required this.departmentName});

  // Convert a Course object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'drId': drId,
      'taId': taId,
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
      drId: data['drId'] ?? '',
      taId: data['taId'] ?? '',
      departmentName: data['departmentName'] ?? '',
      year: data['year'] ?? '',
    );
  }
}

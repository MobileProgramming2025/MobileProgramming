class Course{
  final String id;
  final String name;
  final String code;
  final String departmentId;
  final String year;

  Course(
      {required this.id,
      required this.name,
      required this.code,
      required this.year,
      required this.departmentId});

  // Convert a Course object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'departmentId': departmentId,
      'year': year,
    };
  }

  // Convert Firestore data to a course object
  factory Course.fromMap(Map<String, dynamic> data) {
    return Course(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      departmentId: data['departmentId'] ?? '',
      year: data['year'] ?? '',
    );
  }
}
 
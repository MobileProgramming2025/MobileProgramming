class Assignment {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String createdBy;

  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      courseId: map['courseId'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      createdBy: map['createdBy'],
    );
  }
}

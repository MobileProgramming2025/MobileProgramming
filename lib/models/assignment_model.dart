class Assignment {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String createdBy;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.createdBy,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      courseId: json['courseId'],
      createdBy: json['createdBy'],
    );
  }
}
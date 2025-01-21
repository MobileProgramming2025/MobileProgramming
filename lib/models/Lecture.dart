class Lecture {
  final String title;
  final String description;
  final DateTime dateAdded;
  final String courseId;
  final String fileUrl;

  Lecture({
    required this.title,
    required this.description,
    required this.dateAdded,
    required this.courseId,
    required this.fileUrl,
  });

  // Convert a Lecture object to a Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date_added': dateAdded.toIso8601String(),
      'course_id': courseId,
      'file_url': fileUrl,
    };
  }

  // Create a Lecture object from a Firebase document snapshot
  // factory Lecture.fromMap(Map<String, dynamic> map) {
  //   return Lecture(
  //     title: map['title'] as String,
  //     description: map['description'] as String,
  //     dateAdded: DateTime.parse(map['date_added'] as String),
  //     courseId: map['course_id'] as String,
  //     fileUrl: map['file_url'] as String,
  //   );
  // }
  factory Lecture.fromMap(Map<String, dynamic> map) {
    return Lecture(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '', 
      dateAdded: map['date_added'] != null
          ? DateTime.parse(map['date_added'] as String)
          : DateTime.now(), // Default to current date if null
      courseId: map['course_id'] as String? ?? '',
      fileUrl: map['file_url'] as String? ?? '', 
    );
  }

}

class Submission {
  final String id;
  final String assignmentId;
  final String studentId;
  final String submissionFileUrl;
  final DateTime submissionDate;

  Submission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.submissionFileUrl,
    required this.submissionDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'studentId': studentId,
      'submissionFileUrl': submissionFileUrl,
      'submissionDate': submissionDate.toIso8601String(),
    };
  }

  factory Submission.fromMap(Map<String, dynamic> map) {
    return Submission(
      id: map['id'],
      assignmentId: map['assignmentId'],
      studentId: map['studentId'],
      submissionFileUrl: map['submissionFileUrl'],
      submissionDate: DateTime.parse(map['submissionDate']),
    );
  }
}

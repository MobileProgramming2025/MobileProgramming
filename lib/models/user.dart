import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? departmentId;
  final List<Map<String, dynamic>>? enrolledCourses;
  final List<Map<String, dynamic>>? takenCourses;
  final DateTime? addedDate;
  final String? year;
  final String? profileImagePath;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.departmentId,
    this.enrolledCourses,
    this.takenCourses,
    this.addedDate,
    this.year,
    this.profileImagePath,
  });

  // Convert a User object to a Map for Firestore
  Map<String, dynamic> toMap() {
    if (role == "Student") {
      return {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'departmentId': departmentId,
        'enrolled_courses': enrolledCourses != null
            ? enrolledCourses!
                .map((course) => Map<String, dynamic>.from(course))
                .toList()
            : [], // Serialize Course objects
        'taken_courses': takenCourses != null
            ? takenCourses!
                .map((course) => Map<String, dynamic>.from(course))
                .toList()
            : [],
        'added_date': addedDate,
        'year': year,
      };
    } else if (role == "Admin") {
      return {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      };
    } else {
      return {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'departmentId': departmentId,
        'enrolled_courses': enrolledCourses!, 
        'profile_image_path': profileImagePath,// Serialize Course objects
      };
    }
  }

  // Create a User object from Firestore Map
  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String? ?? '', // provide default value if null
      name: (map['name'] as String?) ??
          map['email'].split('@')[0], // Default to email before '@'
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      role: map['role'] as String? ?? 'Unknown',
      departmentId: map['departmentId'] as String? ?? 'Unknown',
      enrolledCourses: map['enrolled_courses'] != null
          ? List<Map<String, dynamic>>.from(
              map['enrolled_courses'] as List<dynamic>)
          : [],
      takenCourses: map['taken_courses'] != null
          ? List<Map<String, dynamic>>.from(
              map['taken_courses'] as List<dynamic>)
          : [],
      addedDate: map['added_date'] is Timestamp
          ? (map['added_date'] as Timestamp)
              .toDate() // Convert Timestamp to DateTime
          : (map['added_date'] is String
              ? DateTime.parse(
                  map['added_date'] as String) // Parse String to DateTime
              : DateTime.now()), // Default to current date
      year: map['year'] as String? ?? '',
      profileImagePath: map['profile_image_path'],
    );
  }
// CopyWith method to create a copy of the User with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? departmentId,
    List<Map<String, dynamic>>? enrolledCourses,
    List<Map<String, dynamic>>? takenCourses,
    DateTime? addedDate,
    String? year,
    String? profileImagePath,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      takenCourses: takenCourses ?? this.takenCourses,
      addedDate: addedDate ?? this.addedDate,
      year: year ?? this.year,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  // Save user to Firestore
  Future<void> saveToFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(id).set(toMap());
  }

  // // Retrieve all users from Firestore
  // static Future<List<User>> getAllUsers() async {
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   final QuerySnapshot querySnapshot =
  //       await firestore.collection('users').get();
  //   return querySnapshot.docs
  //       .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
  //       .toList();
  // }

  // Retrieve a user by ID from Firestore
  static Future<User?> getUserDetails(String id) async {
    try {
      var userDoc =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (userDoc.exists) {
        print("User doc exists $userDoc");
      }
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await firestore.collection('users').doc(id).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        print("Fetched User Data: ${docSnapshot.data()}");
        return User.fromMap(docSnapshot.data()!);
      } else {
        print('User with ID $id not found in Firestore.');
        return null;
      }
    } catch (e) {
      print('Error retrieving user with ID $id: $e');
      return null;
    }
  }
}

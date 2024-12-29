import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  // final List<Course> courses;
  
  AppUser({
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
  static AppUser fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String? ?? '',  // provide default value if null
      name: (map['name'] as String?) ?? map['email'].split('@')[0],  // Default to email before '@'
      email: map['email'] as String? ?? '', 
      role: map['role'] as String? ?? 'Unknown',
      department: map['department'] as String? ?? 'Unknown',
    );
  }

  // Save user to Firestore
  Future<void> saveToFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(id).set(toMap());
  }

  // Retrieve all users from Firestore
  static Future<List<AppUser>> getAllUsers() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot = await firestore.collection('users').get();
    // print('Fetched ${querySnapshot.docs.length} users from Firestore');
    // for (var doc in querySnapshot.docs) {
    //   print('User document: ${doc.data()}');
    // }
    return querySnapshot.docs.map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  // Retrieve a user by ID from Firestore
  static Future<AppUser?> getUserDetails(String id) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await firestore.collection('users').doc(id).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return AppUser.fromMap(docSnapshot.data()!);
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
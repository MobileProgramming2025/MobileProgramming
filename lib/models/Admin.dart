class Admin {
  String? uid;
  String? email;
  String? role; // Role field

  Admin({this.uid, this.email, this.role});

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      uid: map['uid'],
      email: map['email'],
      role: map['role'], // Get role from Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role, // Add role to Firestore
    };
  }
}

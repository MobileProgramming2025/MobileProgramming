class Doctor {
  String id;
  String name;
  String email;
  String specialization;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.specialization,
  });

  // // Convert Firestore data to a Doctor object
  // factory Doctor.fromMap(Map<String, dynamic> data, String id) {
  //   return Doctor(
  //     id: id,
  //     name: data['name'],
  //     email: data['email'],
  //     specialization: data['specialization'],
  //   );
  // }

  // // Convert Doctor object to Firestore format
  // Map<String, dynamic> toMap() {
  //   return {
  //     'name': name,
  //     'email': email,
  //     'specialization': specialization,
  //   };
  // }
}

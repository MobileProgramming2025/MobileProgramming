//Provides authentication functionality (sign in, sign up, sign out, etc.).
import 'package:firebase_auth/firebase_auth.dart';
//Allows interaction with Firestore (to read/write data in Firestore).
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Admin.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<User?> login(String email, String password) async {
    try {
      //userCredential: stores the result after Firebase tries to sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw e;
    }
  }

  Future<User?> signUp(String email, String password, String role) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'role': role, // Store role in Firestore
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      throw e;
    }
  }

//method retieves a user’s information from db by their uid, it is used to access the data of user after sign up or login
  Future<Admin?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return Admin.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  // Future<void> logout() async {
  //   await _auth.signOut();
  // }
}

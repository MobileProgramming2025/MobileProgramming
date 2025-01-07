//Provides authentication functionality (sign in, sign up, sign out, etc.).
import 'package:firebase_auth/firebase_auth.dart';
//Allows interaction with Firestore (to read/write data in Firestore).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobileprogramming/models/Admin.dart';

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
      rethrow;
    }
  }

  Future<User?> signUp(String email, String password, String role) async {
    final firstAdded = DateTime.utc(2023, DateTime.november, 9);
    final currentYear = DateTime.now();
    final educationYear = currentYear.year - firstAdded.year;

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': email,
          'role': role, // Store role in Firestore
          'password': password,
          'takenCourses': [],
          'enrolledCourses': [],
          'addedDate': firstAdded,
          'year': (educationYear).toString(),
        });
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null; // User canceled the sign-in process
      }

      // Obtain the Google Sign-In authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a Firebase credential using the Google token
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Return the signed-in user
      return userCredential.user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
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
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

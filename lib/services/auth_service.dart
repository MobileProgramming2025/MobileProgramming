//Provides authentication functionality (sign in, sign up, sign out, etc.).
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
//Allows interaction with Firestore (to read/write data in Firestore).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobileprogramming/models/Admin.dart';
import 'package:mobileprogramming/models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<firebase_auth.User?> login(String email, String password) async {
    try {
      //userCredential: stores the result after Firebase tries to sign in the user
      firebase_auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<firebase_auth.User?> signUp(String email, String password, String role) async {
    final firstAdded = DateTime.utc(2023, DateTime.november, 9);
    final currentYear = DateTime.now();
    final educationYear = currentYear.year - firstAdded.year;

    try {
      firebase_auth.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      firebase_auth.User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': email,
          'role': role, // Store role in Firestore
          'password': password,
          'taken_courses': [],
          'enrolled_courses': [],
          'added_date': firstAdded,
          'year': (educationYear).toString(),
        });
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<firebase_auth.User?> signUp2(String name, String email, String password, String role, String departmentId) async {
    final firstAdded = DateTime.utc(2023, DateTime.november, 9);
    final currentYear = DateTime.now();
    final educationYear = currentYear.year - firstAdded.year;

    try {
      firebase_auth.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      firebase_auth.User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'name': name,
          'email': email,
          'password': password,
          'role': role, // Store role in Firestore
          'departmentId': departmentId,
          'taken_courses': [],
          'enrolled_courses': [],
          'added_date': firstAdded,
          'year': (educationYear).toString(),
        });
      }
      return user;
    } catch (e) {
      rethrow;
    } 
  }

  Future<firebase_auth.User?> signInWithGoogle() async {
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
      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final firebase_auth.UserCredential userCredential =
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

  // Checks if a user with the given uid exists in Firestore
  Future<bool> checkIfUserExists(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      return userDoc.exists;
    } catch (e) {
      // print("Error checking if user exists: $e");
      return false;
    }
  }

  Future<void> saveUserDetails(User userModel) async {
    await _firestore.collection('users').doc(userModel.id).set(userModel.toMap());
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

}

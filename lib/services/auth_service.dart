import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _isGoogleInitialized = false;

  // 1. Sign in with Email
  static Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print("Login Error: $e");
      rethrow;
    }
  }

  // 2. Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      if (!_isGoogleInitialized) {
        await _googleSignIn.initialize();
        _isGoogleInitialized = true;
      }
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
    
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'first_name': userCredential.user!.displayName?.split(' ').first ?? '',
          'last_name': userCredential.user!.displayName?.split(' ').skip(1).join(' ') ?? '',
        });
      }

      return userCredential;
    } catch (e) {
      print("Google Sign-In Error: $e");
      rethrow;
    }
  }

  // 3. Register with Email and Save Profile to Firestore
  static Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime birthdate,
    required String carModel,
    required String licensePlate,
    String? insuranceCompany,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      String uid = userCredential.user!.uid;
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'email': email,
        'birthdate': Timestamp.fromDate(birthdate),
        'car_model': carModel,
        'license_plate': licensePlate,
        if (insuranceCompany != null && insuranceCompany.isNotEmpty)
          'insurance_company': insuranceCompany,
      });

      return userCredential;
    } catch (e) {
      print("Registration Error: $e");
      rethrow;
    }
  }

  // 4. Sign Out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Sign-Out Error: $e");
      rethrow;
    }
  }
}

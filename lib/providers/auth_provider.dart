import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchUserData(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      await _fetchUserData(cred.user!.uid);
      
      if (_currentUser == null) {
        throw Exception("User profile not found in database. Please register again.");
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String shipName,
    required String imoNumber,
    required String country,
    required String phoneWhatsapp,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      
      UserModel newUser = UserModel(
        uid: cred.user!.uid,
        email: email.trim(),
        shipName: shipName,
        imoNumber: imoNumber,
        country: country,
        phoneWhatsapp: phoneWhatsapp,
        role: 'user',
      );

      await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
      _currentUser = newUser;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        debugPrint("Firestore User missing: $uid");
      }
    } catch (e) {
      debugPrint("Firestore Fetch Error: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}

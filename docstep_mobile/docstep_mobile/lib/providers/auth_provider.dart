import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart' as custom_models;
import '../firebase_options.dart';

class AuthProvider extends ChangeNotifier {
  custom_models.User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  custom_models.User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  static Future<void>? _initFuture;

  static Future<void> ensureFirebaseInitialized() {
    _initFuture ??= Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return _initFuture!;
  }

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      await ensureFirebaseInitialized();
      fb_auth.FirebaseAuth.instance.authStateChanges().listen((
        fb_auth.User? fbUser,
      ) async {
        if (fbUser != null) {
          await _fetchUserAndNotify(fbUser.uid);
        } else {
          _user = null;
          _isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Firebase initialization failed';
      notifyListeners();
    }
  }

  Future<void> _fetchUserAndNotify(String uid) async {
    try {
      await ensureFirebaseInitialized();
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = uid;
        data['user_id'] = uid;

        if (data['role'] == 'employer') {
          final empSnapshot = await FirebaseFirestore.instance
              .collection('employer_profiles')
              .where('user_id', isEqualTo: uid)
              .limit(1)
              .get();
          if (empSnapshot.docs.isNotEmpty) {
            final empData = empSnapshot.docs.first.data();
            data['organization_name'] =
                empData['organization_name'] ?? empData['organizationName'];
          }
        }

        _user = custom_models.User.fromJson(data);
      } else {
        final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
        if (fbUser != null && fbUser.uid == uid) {
          final email = fbUser.email ?? '';
          final name = email.split('@').first;
          final fullName = name.isNotEmpty
              ? name[0].toUpperCase() + name.substring(1)
              : 'User';

          final newUserDoc = {
            'id': uid,
            'user_id': uid,
            'email': email,
            'role': 'doctor',
            'name': fullName,
            'full_name': fullName,
            'phone': '',
          };

          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set(newUserDoc);
          _user = custom_models.User.fromJson(newUserDoc);
        } else {
          _user = null;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load user profile';
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✨ UPDATED GOOGLE SIGN IN METHOD WITH ROLE SELECTION FOR NEW USERS
  Future<bool> signInWithGoogle({
    Future<String?> Function()? onRoleRequired,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ensureFirebaseInitialized();

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            '660206687276-4pgq55qrjrlbesp30tmk3dlbcsla63a6.apps.googleusercontent.com',
        scopes: <String>['email'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final fb_auth.AuthCredential credential =
          fb_auth.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

      final userCredential = await fb_auth.FirebaseAuth.instance
          .signInWithCredential(credential);

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (!doc.exists) {
          String? selectedRole = 'doctor';
          if (onRoleRequired != null) {
            selectedRole = await onRoleRequired();
            if (selectedRole == null) {
              await fb_auth.FirebaseAuth.instance.signOut();
              _isLoading = false;
              notifyListeners();
              return false;
            }
          }

          final email = userCredential.user!.email ?? '';
          final name = email.split('@').first;
          final fullName = name.isNotEmpty
              ? name[0].toUpperCase() + name.substring(1)
              : 'User';

          final newUserDoc = {
            'id': uid,
            'user_id': uid,
            'email': email,
            'role': selectedRole,
            'name': selectedRole == 'employer' ? 'DocStep Partner' : fullName,
            'full_name': selectedRole == 'employer'
                ? 'DocStep Partner'
                : fullName,
            'fullName': selectedRole == 'employer'
                ? 'DocStep Partner'
                : fullName,
            'phone': '',
            'phoneNumber': '',
            'created_at': DateTime.now().toUtc().toIso8601String(),
          };

          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set(newUserDoc);

          if (selectedRole == 'doctor') {
            final doctorProfile = {
              'user_id': uid,
              'name': fullName,
              'full_name': fullName,
              'fullName': fullName,
              'email': email,
              'phone': '',
              'phoneNumber': '',
              'specialty': 'General Practice',
              'speciality': 'General Practice',
              'city': 'Karachi',
              'pmdc_verified': 0,
              'pmdcVerified': 0,
              'availability': 'Flexible',
              'open_to_remote': false,
              'openToRemote': false,
              'hourly_rate': 0.0,
              'hourlyRate': 0.0,
            };
            await FirebaseFirestore.instance
                .collection('doctor_profiles')
                .doc(uid)
                .set(doctorProfile);
          } else if (selectedRole == 'employer') {
            final employerProfile = {
              'user_id': uid,
              'name': 'DocStep Partner',
              'organization_name': 'DocStep Partner',
              'organizationName': 'DocStep Partner',
              'city': 'Karachi',
              'phone': '',
              'phoneNumber': '',
              'email': email,
            };
            await FirebaseFirestore.instance
                .collection('employer_profiles')
                .doc(uid)
                .set(employerProfile);
          } else if (selectedRole == 'patient') {
            final patientProfile = {
              'user_id': uid,
              'name': fullName,
              'full_name': fullName,
              'fullName': fullName,
              'email': email,
              'phone': '',
              'phoneNumber': '',
              'created_at': DateTime.now().toUtc().toIso8601String(),
            };
            await FirebaseFirestore.instance
                .collection('patient_profiles')
                .doc(uid)
                .set(patientProfile);
          }
        }

        await _fetchUserAndNotify(uid);
        return true;
      }

      _errorMessage = 'Google sign-in failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ensureFirebaseInitialized();
      final credential = await fb_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _fetchUserAndNotify(credential.user!.uid);
        if (_user != null) return true;
      }
      _errorMessage = 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      final String primaryError = e is fb_auth.FirebaseAuthException
          ? (e.message ?? 'Login failed')
          : e.toString();

      try {
        await fb_auth.FirebaseAuth.instance.signInAnonymously();
        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final userDoc = userQuery.docs.first;
          final userData = userDoc.data();

          if (userData.containsKey('password_hash')) {
            String hashedPassword = userData['password_hash'];
            bool isPasswordMatch = DBCrypt().checkpw(password, hashedPassword);

            if (isPasswordMatch) {
              userData['id'] = userDoc.id;
              _user = custom_models.User.fromJson(userData);
              _isLoading = false;
              notifyListeners();
              return true;
            } else {
              _errorMessage = "The supplied password is incorrect.";
            }
          } else {
            _errorMessage =
                "Password record missing for this user in database.";
          }
        } else {
          _errorMessage = "No user account found matching this email.";
        }
        await fb_auth.FirebaseAuth.instance.signOut();
      } catch (fallbackError) {
        _errorMessage = primaryError;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    String? organizationName,
    String? specialty,
    String? city,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ensureFirebaseInitialized();
      final credential = await fb_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = credential.user?.uid;
      if (uid == null) {
        _errorMessage = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      String hashedPassword = DBCrypt().hashpw(password, DBCrypt().gensalt());

      final userDoc = {
        'id': uid,
        'user_id': uid,
        'email': email,
        'role': role,
        'name': role == 'employer' ? (organizationName ?? fullName) : fullName,
        'full_name': role == 'employer'
            ? (organizationName ?? fullName)
            : fullName,
        'phone': phone ?? '',
        'password_hash': hashedPassword,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userDoc);

      if (role == 'doctor') {
        final doctorProfile = {
          'user_id': uid,
          'name': fullName,
          'full_name': fullName,
          'fullName': fullName,
          'email': email,
          'phone': phone ?? '',
          'phoneNumber': phone ?? '',
          'specialty': specialty ?? 'General Practice',
          'speciality': specialty ?? 'General Practice',
          'city': city ?? '',
          'pmdc_verified': 0,
          'pmdcVerified': 0,
          'availability': 'Flexible',
          'open_to_remote': false,
          'openToRemote': false,
          'hourly_rate': 0.0,
          'hourlyRate': 0.0,
        };
        await FirebaseFirestore.instance
            .collection('doctor_profiles')
            .doc(uid)
            .set(doctorProfile);

        await fb_auth.FirebaseAuth.instance.signOut();
        _user = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (role == 'employer') {
        final employerProfile = {
          'user_id': uid,
          'name': organizationName ?? 'DocStep Partner',
          'organization_name': organizationName ?? 'DocStep Partner',
          'organizationName': organizationName ?? 'DocStep Partner',
          'city': city ?? '',
          'phone': phone ?? '',
          'phoneNumber': phone ?? '',
          'email': email,
        };
        await FirebaseFirestore.instance
            .collection('employer_profiles')
            .doc(uid)
            .set(employerProfile);

        await _fetchUserAndNotify(uid);
        return true;
      } else if (role == 'patient') {
        final patientProfile = {
          'user_id': uid,
          'id': uid,
          'name': fullName,
          'full_name': fullName,
          'fullName': fullName,
          'role': 'patient',
          'email': email,
          'phone': phone ?? '',
          'phoneNumber': phone ?? '',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        };
        try {
          await FirebaseFirestore.instance
              .collection('patient_profiles')
              .doc(uid)
              .set(patientProfile);
        } catch (_) {}

        await fb_auth.FirebaseAuth.instance.signOut();
        _user = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (e is fb_auth.FirebaseAuthException) {
        _errorMessage = e.message ?? 'Registration failed';
      } else {
        _errorMessage = e.toString();
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ensureFirebaseInitialized();
      await fb_auth.FirebaseAuth.instance.signOut();

      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {}

    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await ensureFirebaseInitialized();
      await fb_auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetPassword(String token, String password) async {
    try {
      await ensureFirebaseInitialized();
      await fb_auth.FirebaseAuth.instance.confirmPasswordReset(
        code: token,
        newPassword: password,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

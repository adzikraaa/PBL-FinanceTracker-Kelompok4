import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;
  User? _currentUser;

  // Firebase & Google Sign-In instances
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  // Constructor: Check current auth state
  AuthViewModel() {
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    _currentUser = _firebaseAuth.currentUser;
    _isLoggedIn = _currentUser != null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // ─── Login dengan Email & Password ───────────────────────────────────────
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      if (email.isEmpty || password.isEmpty) {
        _setError('Email dan password tidak boleh kosong.');
        return false;
      }

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = userCredential.user;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _setError('Email tidak terdaftar.');
          break;
        case 'wrong-password':
          _setError('Password salah.');
          break;
        case 'invalid-email':
          _setError('Format email tidak valid.');
          break;
        case 'too-many-requests':
          _setError('Terlalu banyak percobaan login. Coba lagi nanti.');
          break;
        default:
          _setError('Login gagal: ${e.message}');
      }
      return false;
    } catch (e) {
      _setError('Error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Login dengan Google ──────────────────────────────────────────────────
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _setError(null);

    try {
      await _googleSignIn.signOut(); // ← tambahkan baris ini
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _setError('Login Google dibatalkan.');
        _setLoading(false);
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      _currentUser = userCredential.user;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError('Login Google gagal: ${e.message}');
      return false;
    } catch (e) {
      _setError('Error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Registrasi dengan Email & Password ──────────────────────────────
  Future<bool> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
        _setError('Semua field harus diisi.');
        return false;
      }

      if (password.length < 6) {
        _setError('Password minimal 6 karakter.');
        return false;
      }

      // 1. Create User
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Update Profile (Dibungkus try-catch agar tidak crash jika Pigeon error)
      try {
        if (userCredential.user != null) {
          await userCredential.user!.updateDisplayName(fullName);
          await userCredential.user!.reload();
        }
      } catch (e) {
        debugPrint("Profil update skipped (Pigeon bug): $e");
      }

      // 3. Ambil data user terbaru
      _currentUser = _firebaseAuth.currentUser;
      _isLoggedIn = _currentUser != null;

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _setError('Email sudah terdaftar.');
          break;
        case 'invalid-email':
          _setError('Format email tidak valid.');
          break;
        case 'weak-password':
          _setError('Password terlalu lemah.');
          break;
        case 'operation-not-allowed':
          _setError('Registrasi tidak diizinkan.');
          break;
        default:
          _setError('Registrasi gagal: ${e.message}');
      }
      return false;
    } catch (e) {
      // Menangkap error Pigeon / Type Cast agar tidak mematikan aplikasi
      if (e.toString().contains('PigeonUserDetails')) {
        debugPrint("Caught Pigeon Bug - User created successfully anyway.");
        _currentUser = _firebaseAuth.currentUser;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
      _setError('Error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();

      _currentUser = null;
      _isLoggedIn = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout gagal: ${e.toString()}');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import '../datasources/firebase_datasource.dart';

class AuthRepository {
  final FirebaseDatasource _datasource;

  AuthRepository({required FirebaseDatasource datasource})
      : _datasource = datasource;

  Stream<User?> get authStateChanges => _datasource.authStateChanges;

  User? get currentUser => _datasource.currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    final credential = await _datasource.signInWithEmail(email, password);
    if (credential.user != null) {
      await _datasource.saveUserProfile(credential.user!);
    }
    return credential.user;
  }

  Future<User?> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final credential = await _datasource.signUpWithEmail(
      email,
      password,
      displayName,
    );
    if (credential.user != null) {
      await _datasource.saveUserProfile(credential.user!);
    }
    return credential.user;
  }

  Future<User?> signInWithGoogle() async {
    final credential = await _datasource.signInWithGoogle();
    if (credential?.user != null) {
      await _datasource.saveUserProfile(credential!.user!);
    }
    return credential?.user;
  }

  Future<void> signOut() => _datasource.signOut();

  Future<void> sendPasswordReset(String email) =>
      _datasource.sendPasswordReset(email);
}

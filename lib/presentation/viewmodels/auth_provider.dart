import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/firebase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import 'providers.dart';

// ---------------------------------------------------------------------------
// Auth state stream
// ---------------------------------------------------------------------------

final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

// ---------------------------------------------------------------------------
// Auth actions notifier
// ---------------------------------------------------------------------------

enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({this.status = AuthStatus.idle, this.errorMessage});

  AuthState copyWith({AuthStatus? status, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> signInWithEmail(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await _repo.signInWithEmail(email, password);
      state = const AuthState(status: AuthStatus.success);
      return true;
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred.',
      );
      return false;
    }
  }

  Future<bool> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await _repo.signUpWithEmail(email, password, displayName);
      state = const AuthState(status: AuthStatus.success);
      return true;
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred.',
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final user = await _repo.signInWithGoogle();
      if (user == null) {
        state = const AuthState(status: AuthStatus.idle);
        return false;
      }
      state = const AuthState(status: AuthStatus.success);
      return true;
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Google sign-in failed.',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AuthState(status: AuthStatus.loading);
    await _repo.signOut();
    state = const AuthState(status: AuthStatus.idle);
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await _repo.sendPasswordReset(email);
      state = const AuthState(status: AuthStatus.success);
      return true;
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Failed to send reset email.',
      );
      return false;
    }
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      state = const AuthState(status: AuthStatus.idle);
    }
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

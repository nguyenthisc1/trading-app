import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/watchlist_item.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class FirebaseDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseDatasource()
      : _auth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        _googleSignIn = GoogleSignIn();

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e.code));
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // ---------------------------------------------------------------------------
  // User profile
  // ---------------------------------------------------------------------------

  CollectionReference get _users => _firestore.collection('users');

  Future<void> saveUserProfile(User user) async {
    await _users.doc(user.uid).set(
      {
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ---------------------------------------------------------------------------
  // Watchlist
  // ---------------------------------------------------------------------------

  CollectionReference _watchlistCollection(String uid) =>
      _users.doc(uid).collection('watchlist');

  Stream<List<WatchlistItem>> watchlistStream(String uid) {
    return _watchlistCollection(uid)
        .orderBy('addedAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => WatchlistItem.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<List<WatchlistItem>> getWatchlist(String uid) async {
    final snapshot = await _watchlistCollection(uid)
        .orderBy('addedAt', descending: false)
        .get();
    return snapshot.docs.map((doc) => WatchlistItem.fromFirestore(doc)).toList();
  }

  Future<void> addToWatchlist(String uid, String symbol, {String? name}) async {
    await _watchlistCollection(uid).doc(symbol).set(
      WatchlistItem(
        symbol: symbol,
        name: name,
        addedAt: DateTime.now(),
      ).toFirestore(),
    );
  }

  Future<void> removeFromWatchlist(String uid, String symbol) async {
    await _watchlistCollection(uid).doc(symbol).delete();
  }

  Future<bool> isInWatchlist(String uid, String symbol) async {
    final doc = await _watchlistCollection(uid).doc(symbol).get();
    return doc.exists;
  }

  // ---------------------------------------------------------------------------
  // Price alerts
  // ---------------------------------------------------------------------------

  CollectionReference _alertsCollection(String uid) =>
      _users.doc(uid).collection('alerts');

  Future<void> addAlert({
    required String uid,
    required String symbol,
    required double targetPrice,
    required bool isAbove,
  }) async {
    await _alertsCollection(uid).add({
      'symbol': symbol,
      'targetPrice': targetPrice,
      'isAbove': isAbove,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> alertsStream(String uid) {
    return _alertsCollection(uid)
        .where('active', isEqualTo: true)
        .snapshots();
  }

  Future<void> deleteAlert(String uid, String alertId) async {
    await _alertsCollection(uid).doc(alertId).delete();
  }
}

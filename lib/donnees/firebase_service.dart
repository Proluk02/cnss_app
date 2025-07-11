import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔐 Inscription
  Future<User?> register({
    required String email,
    required String password,
    required String nom,
    required String role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      await _db.collection('utilisateurs').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'nom': nom,
        'role': role,
      });
    }
    return user;
  }

  // 🔐 Connexion
  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  // 🔐 Récupération du rôle
  Future<String?> getUserRole(String uid) async {
    final doc = await _db.collection('utilisateurs').doc(uid).get();
    return doc.exists && doc.data() != null
        ? doc.data()!['role'] as String?
        : null;
  }

  // 🔐 Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔄 Stream des changements utilisateur
  Stream<User?> get userChanges => _auth.authStateChanges();
}

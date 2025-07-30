// lib/donnees/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart'; // Assurez-vous que ce chemin d'import est correct

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();
  String? getCurrentUserId() => _auth.currentUser?.uid;

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
        'dernierePeriodeDeclaree': null,
      });
    }
    return user;
  }

  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<void> logout() async => await _auth.signOut();

  Future<Map<String, dynamic>?> getDonneesUtilisateur(String uid) async {
    final doc = await _db.collection('utilisateurs').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<String?> getUserRole(String uid) async {
    final data = await getDonneesUtilisateur(uid);
    return data != null ? data['role'] as String? : null;
  }

  Future<void> syncTravailleur(String uid, Map<String, dynamic> data) async {
    await _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('travailleurs')
        .doc(data['id'])
        .set(data, SetOptions(merge: true));
  }

  Future<void> syncBrouillon(String uid, Map<String, dynamic> data) async {
    await _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('brouillons')
        .doc(data['id'])
        .set(data, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getTousLesTravailleurs(String uid) async {
    final snapshot =
        await _db
            .collection('utilisateurs')
            .doc(uid)
            .collection('travailleurs')
            .orderBy('nom') // Optionnel: trier par nom
            .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getTousLesBrouillons(String uid) async {
    final snapshot =
        await _db
            .collection('utilisateurs')
            .doc(uid)
            .collection('brouillons')
            .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> finaliserDeclarationEnLigne(
    String uid,
    String periode,
    DateTime datePeriode,
    RapportDeclaration rapport,
  ) async {
    final batch = _db.batch();
    final rapportRef = _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('declarations_finalisees')
        .doc(periode);
    batch.set(rapportRef, rapport.toMap());

    final brouillonsSnapshot =
        await _db
            .collection('utilisateurs')
            .doc(uid)
            .collection('brouillons')
            .where('periode', isEqualTo: periode)
            .get();
    for (var doc in brouillonsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    final userRef = _db.collection('utilisateurs').doc(uid);
    batch.update(userRef, {
      'dernierePeriodeDeclaree': Timestamp.fromDate(datePeriode),
    });

    await batch.commit();
  }
}

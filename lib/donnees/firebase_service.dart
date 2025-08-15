// lib/donnees/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cnss_app/donnees/modeles/declaration_modele.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();
  String? getCurrentUserId() => _auth.currentUser?.uid;

  Future<User?> register(
      {required String email,
      required String password,
      required String nom,
      required String role}) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = cred.user;
    if (user != null) {
      await user.updateDisplayName(nom);
      await _db.collection('utilisateurs').doc(user.uid).set({
        'email': email,
        'nom': nom,
        'role': role,
        'dernierePeriodeDeclaree': null,
        'numAffiliation': '',
        'nom_lower': nom.toLowerCase(),
      });
    }
    return user;
  }

  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
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

  Future<void> updateUserProfile(String uid,
      {required String nom, required String numAffiliation}) async {
    await _auth.currentUser?.updateDisplayName(nom);
    await _db.collection('utilisateurs').doc(uid).update({
      'nom': nom,
      'numAffiliation': numAffiliation,
      'nom_lower': nom.toLowerCase(),
    });
  }

  Future<void> changePassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> syncTravailleur(String uid, Map<String, dynamic> data) async {
    await _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('travailleurs')
        .doc(data['id'])
        .set(data, SetOptions(merge: true));
  }

  Future<void> deleteTravailleur(String uid, String travailleurId) async {
    await _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('travailleurs')
        .doc(travailleurId)
        .delete();
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
    final snapshot = await _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('travailleurs')
        .orderBy('nom')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getTousLesBrouillons(String uid) async {
    final snapshot = await _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('brouillons')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getDeclarationsRecentes(String uid) async {
    final snapshot = await _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('declarations_finalisees')
        .orderBy('dateFinalisation', descending: true)
        .limit(5)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getToutHistorique(String uid) async {
    final snapshot = await _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('declarations_finalisees')
        .orderBy('dateFinalisation', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getFeuilleDePaieArchivee(
      String uid, String periode) async {
    final snapshot = await _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('declarations_finalisees')
        .doc(periode)
        .collection('feuille_de_paie')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> finaliserDeclarationEnLigne(
      String uid,
      String periode,
      DateTime datePeriode,
      RapportDeclaration rapport,
      List<DeclarationTravailleurModele> lignesDeclarees) async {
    final batch = _db.batch();
    final rapportRef = _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('declarations_finalisees')
        .doc(periode);
    batch.set(rapportRef, rapport.toMap());
    for (var ligne in lignesDeclarees) {
      final feuillePaieRef =
          rapportRef.collection('feuille_de_paie').doc(ligne.travailleurId);
      batch.set(feuillePaieRef, ligne.toMap());
    }
    final brouillonsSnapshot = await _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('brouillons')
        .where('periode', isEqualTo: periode)
        .get();
    for (var doc in brouillonsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    final userRef = _db.collection('utilisateurs').doc(uid);
    batch.update(
        userRef, {'dernierePeriodeDeclaree': Timestamp.fromDate(datePeriode)});
    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getTousLesUtilisateurs() async {
    final snapshot = await _db.collection('utilisateurs').get();
    return snapshot.docs.map((doc) {
      var data = doc.data();
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> updateUserRole(String uid, String nouveauRole) async {
    await _db.collection('utilisateurs').doc(uid).update({'role': nouveauRole});
  }

  Future<void> deleteUserDocument(String uid) async {
    await _db.collection('utilisateurs').doc(uid).delete();
  }

  Stream<QuerySnapshot> getDeclarationsEnAttenteStream() {
    return _db
        .collectionGroup('declarations_finalisees')
        .where('statut', isEqualTo: 'EN_ATTENTE')
        .snapshots();
  }

  Stream<QuerySnapshot> getToutesLesDeclarationsFinaliseesStream() {
    return _db
        .collectionGroup('declarations_finalisees')
        .orderBy('dateFinalisation', descending: true)
        .snapshots();
  }

  Future<void> updateDeclarationStatus(
      String employeurUid, String periode, StatutDeclaration nouveauStatut,
      {String? motifRejet}) async {
    final dataToUpdate = <String, dynamic>{
      'statut': nouveauStatut.toString().split('.').last
    };
    if (nouveauStatut == StatutDeclaration.VALIDEE)
      dataToUpdate['dateValidation'] = Timestamp.now();
    if (motifRejet != null) dataToUpdate['motifRejet'] = motifRejet;
    await _db
        .collection('utilisateurs')
        .doc(employeurUid)
        .collection('declarations_finalisees')
        .doc(periode)
        .update(dataToUpdate);
  }

  Future<List<Map<String, dynamic>>>
      getToutesLesDeclarationsAvecEmployeur() async {
    final declarationsSnapshot =
        await _db.collectionGroup('declarations_finalisees').get();
    List<Map<String, dynamic>> results = [];
    await Future.forEach(declarationsSnapshot.docs, (declaDoc) async {
      var data = declaDoc.data();
      final employeurUid = declaDoc.reference.parent.parent!.id;
      final employeurDoc =
          await _db.collection('utilisateurs').doc(employeurUid).get();
      if (employeurDoc.exists) {
        data['employeurNom'] = employeurDoc.data()?['nom'];
        data['employeurUid'] = employeurUid;
      }
      results.add(data);
    });
    results.sort((a, b) {
      final dateA =
          (a['dateFinalisation'] as Timestamp?)?.toDate() ?? DateTime(1970);
      final dateB =
          (b['dateFinalisation'] as Timestamp?)?.toDate() ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });
    return results;
  }

  Future<List<Map<String, dynamic>>> getDeclarationsValideesDuJourAvecEmployeur(
      DateTime jour) async {
    final debutJour =
        Timestamp.fromDate(DateTime(jour.year, jour.month, jour.day));
    final finJour = Timestamp.fromDate(
        DateTime(jour.year, jour.month, jour.day, 23, 59, 59));

    final declarationsSnapshot = await _db
        .collectionGroup('declarations_finalisees')
        .where('statut', isEqualTo: 'VALIDEE')
        .where('dateValidation', isGreaterThanOrEqualTo: debutJour)
        .where('dateValidation', isLessThanOrEqualTo: finJour)
        .get();

    List<Map<String, dynamic>> results = [];
    await Future.forEach(declarationsSnapshot.docs, (declaDoc) async {
      var data = declaDoc.data();
      final employeurUid = declaDoc.reference.parent.parent!.id;
      final employeurDoc =
          await _db.collection('utilisateurs').doc(employeurUid).get();

      if (employeurDoc.exists) {
        data['employeurNom'] = employeurDoc.data()?['nom'];
        data['numAffiliation'] = employeurDoc.data()?['numAffiliation'];
      }
      results.add(data);
    });

    return results;
  }

  Future<List<Map<String, dynamic>>> rechercherEmployeurs(String query) async {
    if (query.isEmpty) return [];
    final queryLower = query.toLowerCase();

    final snapshot = await _db
        .collection('utilisateurs')
        .where('role', isEqualTo: 'employeur')
        .where('nom_lower', isGreaterThanOrEqualTo: queryLower)
        .where('nom_lower', isLessThanOrEqualTo: '$queryLower\uf8ff')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getHistoriqueCompletEmployeur(
      String uid) async {
    final snapshot = await _db
        .collection('utilisateurs')
        .doc(uid)
        .collection('declarations_finalisees')
        .orderBy('dateFinalisation', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getTousLesEmployeurs() async {
    final snapshot = await _db
        .collection('utilisateurs')
        .where('role', isEqualTo: 'employeur')
        .orderBy('nom_lower')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id; // Enrichir avec l'ID du document
      return data;
    }).toList();
  }
}

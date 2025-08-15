// lib/donnees/modeles/utilisateur_modele.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UtilisateurModele {
  final String uid;
  final String? nom;
  final String? email;
  final String? role;
  final String? numAffiliation;

  UtilisateurModele({
    required this.uid,
    this.nom,
    this.email,
    this.role,
    this.numAffiliation,
  });

  // CORRECTION : Ajout de la méthode `fromFirestore`
  factory UtilisateurModele.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists || doc.data() == null) {
      throw Exception("Le document utilisateur n'existe pas ou est vide.");
    }
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UtilisateurModele(
      uid: doc.id, // Utilise l'ID du document comme UID
      nom: data['nom'],
      email: data['email'],
      role: data['role'],
      numAffiliation: data['numAffiliation'],
    );
  }

  // Cette méthode reste utile
  factory UtilisateurModele.fromMap(Map<String, dynamic> data) {
    if (data['uid'] == null || (data['uid'] as String).isEmpty) {
      throw ArgumentError(
          "Les données utilisateur sont invalides : le champ 'uid' est manquant.");
    }
    return UtilisateurModele(
      uid: data['uid'],
      nom: data['nom'],
      email: data['email'],
      role: data['role'],
      numAffiliation: data['numAffiliation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'role': role,
      'numAffiliation': numAffiliation,
    };
  }
}

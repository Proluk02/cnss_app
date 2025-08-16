// lib/donnees/modeles/utilisateur_modele.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UtilisateurModele {
  final String uid;
  final String? nom; // Raison Sociale
  final String? email;
  final String? role;

  // --- NOUVEAUX CHAMPS POUR L'EMPLOYEUR ---
  final String? sigle;
  final String? numAffiliation;
  final String? telephone;
  final String? adresse;
  final String? centreGestion;

  UtilisateurModele({
    required this.uid,
    this.nom,
    this.email,
    this.role,
    this.sigle,
    this.numAffiliation,
    this.telephone,
    this.adresse,
    this.centreGestion,
  });

  bool get isProfileComplete {
    // Un profil est complet si le numéro d'affiliation ET le numéro de téléphone sont remplis.
    return numAffiliation != null &&
        numAffiliation!.isNotEmpty &&
        telephone != null &&
        telephone!.isNotEmpty;
  }

  factory UtilisateurModele.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists || doc.data() == null) {
      throw Exception("Le document utilisateur n'existe pas ou est vide.");
    }
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UtilisateurModele(
      uid: doc.id,
      nom: data['nom'],
      email: data['email'],
      role: data['role'],
      sigle: data['sigle'],
      numAffiliation: data['numAffiliation'],
      telephone: data['telephone'],
      adresse: data['adresse'],
      centreGestion: data['centreGestion'],
    );
  }

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
      sigle: data['sigle'],
      numAffiliation: data['numAffiliation'],
      telephone: data['telephone'],
      adresse: data['adresse'],
      centreGestion: data['centreGestion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'role': role,
      'sigle': sigle,
      'numAffiliation': numAffiliation,
      'telephone': telephone,
      'adresse': adresse,
      'centreGestion': centreGestion,
    };
  }
}

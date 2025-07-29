import 'package:cloud_firestore/cloud_firestore.dart';

class Travailleur {
  final String id;
  final String matricule;
  final String immatriculationCNSS;
  final String nom;
  final String postNoms;
  final String prenoms;
  final int typeTravailleur; // 1 = Travailleur, 2 = Assimilé
  final String communeAffectation;

  Travailleur({
    required this.id,
    required this.matricule,
    required this.immatriculationCNSS,
    required this.nom,
    required this.postNoms,
    required this.prenoms,
    required this.typeTravailleur,
    required this.communeAffectation,
  });

  String get nomComplet => '$nom $postNoms $prenoms';

  /// Pour récupérer depuis Firestore
  factory Travailleur.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Travailleur(
      id: doc.id,
      matricule: data['matricule'] ?? '',
      immatriculationCNSS: data['immatriculationCNSS'] ?? '',
      nom: data['nom'] ?? '',
      postNoms: data['postNoms'] ?? '',
      prenoms: data['prenoms'] ?? '',
      typeTravailleur: data['typeTravailleur'] ?? 1,
      communeAffectation: data['communeAffectation'] ?? '',
    );
  }

  /// Pour stocker dans Firestore
  Map<String, dynamic> toMap() {
    return {
      'matricule': matricule,
      'immatriculationCNSS': immatriculationCNSS,
      'nom': nom,
      'postNoms': postNoms,
      'prenoms': prenoms,
      'typeTravailleur': typeTravailleur,
      'communeAffectation': communeAffectation,
    };
  }

  /// Pour SQLite
  factory Travailleur.fromMap(Map<String, dynamic> map) {
    return Travailleur(
      id: map['id'].toString(),
      matricule: map['matricule'] ?? '',
      immatriculationCNSS: map['immatriculationCNSS'] ?? '',
      nom: map['nom'] ?? '',
      postNoms: map['postNoms'] ?? '',
      prenoms: map['prenoms'] ?? '',
      typeTravailleur: map['typeTravailleur'] ?? 1,
      communeAffectation: map['communeAffectation'] ?? '',
    );
  }

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'matricule': matricule,
      'immatriculationCNSS': immatriculationCNSS,
      'nom': nom,
      'postNoms': postNoms,
      'prenoms': prenoms,
      'typeTravailleur': typeTravailleur,
      'communeAffectation': communeAffectation,
    };
  }
}

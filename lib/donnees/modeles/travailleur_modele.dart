// lib/donnees/modeles/travailleur_modele.dart

class TravailleurModele {
  final String id;
  final String matricule;
  final String immatriculationCNSS;
  final String nom;
  final String postNoms;
  final String prenoms;
  final int typeTravailleur;
  final String communeAffectation;
  final int enfantsBeneficiaires;
  final String syncStatus;
  final DateTime lastModified;

  TravailleurModele({
    required this.id,
    required this.matricule,
    required this.immatriculationCNSS,
    required this.nom,
    required this.postNoms,
    required this.prenoms,
    required this.typeTravailleur,
    required this.communeAffectation,
    required this.enfantsBeneficiaires,
    this.syncStatus = 'pending',
    DateTime? lastModified,
  }) : this.lastModified = lastModified ?? DateTime.now();

  String get nomComplet => '$nom $postNoms $prenoms'.trim();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'matricule': matricule,
      'immatriculationCNSS': immatriculationCNSS,
      'nom': nom,
      'postNoms': postNoms,
      'prenoms': prenoms,
      'typeTravailleur': typeTravailleur,
      'communeAffectation': communeAffectation,
      'enfantsBeneficiaires': enfantsBeneficiaires,
      'syncStatus': syncStatus,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory TravailleurModele.fromMap(Map<String, dynamic> map) {
    return TravailleurModele(
      id: map['id'] ?? '',
      matricule: map['matricule'] ?? '',
      immatriculationCNSS: map['immatriculationCNSS'] ?? '',
      nom: map['nom'] ?? '',
      postNoms: map['postNoms'] ?? '',
      prenoms: map['prenoms'] ?? '',
      typeTravailleur: map['typeTravailleur'] ?? 1,
      communeAffectation: map['communeAffectation'] ?? '',
      enfantsBeneficiaires: map['enfantsBeneficiaires'] ?? 0,
      syncStatus: map['syncStatus'] ?? 'synced',
      lastModified:
          map['lastModified'] != null
              ? DateTime.parse(map['lastModified'])
              : DateTime.now(),
    );
  }

  // MÉTHODE AJOUTÉE : Factory statique pour créer une instance vide
  // C'est une méthode de secours utilisée dans le service PDF si un travailleur
  // déclaré n'est plus dans la liste des travailleurs actuels.
  static TravailleurModele empty() {
    return TravailleurModele(
      id: '',
      matricule: 'N/A',
      immatriculationCNSS: 'N/A',
      nom: 'Employé',
      postNoms: 'Introuvable',
      prenoms: '',
      typeTravailleur: 1,
      communeAffectation: '',
      enfantsBeneficiaires: 0,
      lastModified: DateTime.now(),
    );
  }
}

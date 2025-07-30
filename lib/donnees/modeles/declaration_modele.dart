// lib/donnees/modeles/declaration_modele.dart

class DeclarationTravailleurModele {
  final String id;
  final String travailleurId;
  final String periode;
  final double salaireBrut;
  final int joursTravail;
  final int heuresTravail;
  final int typeTravailleur;
  final String syncStatus;
  final DateTime lastModified;

  DeclarationTravailleurModele({
    required this.id,
    required this.travailleurId,
    required this.periode,
    required this.salaireBrut,
    required this.joursTravail,
    required this.heuresTravail,
    required this.typeTravailleur,
    this.syncStatus = 'pending',
    DateTime? lastModified,
  }) : this.lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'travailleurId': travailleurId,
      'periode': periode,
      'salaireBrut': salaireBrut,
      'joursTravail': joursTravail,
      'heuresTravail': heuresTravail,
      'typeTravailleur': typeTravailleur,
      'syncStatus': syncStatus,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory DeclarationTravailleurModele.fromMap(Map<String, dynamic> map) {
    return DeclarationTravailleurModele(
      id: map['id'],
      travailleurId: map['travailleurId'],
      periode: map['periode'],
      salaireBrut: map['salaireBrut'],
      joursTravail: map['joursTravail'],
      heuresTravail: map['heuresTravail'],
      typeTravailleur: map['typeTravailleur'],
      syncStatus: map['syncStatus'] ?? 'synced',
      lastModified: DateTime.parse(map['lastModified']),
    );
  }
}

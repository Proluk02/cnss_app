// Modèle utilisateur
class UtilisateurModele {
  final String uid;
  final String nom;
  final String email;
  final String role;

  UtilisateurModele({
    required this.uid,
    required this.nom,
    required this.email,
    required this.role,
    required String numAffiliation,
  });

  factory UtilisateurModele.fromMap(Map<String, dynamic> data) {
    return UtilisateurModele(
      uid: data['uid'] ?? '',
      nom: data['nom'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'employeur',
      numAffiliation: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'nom': nom, 'email': email, 'role': role};
  }
}

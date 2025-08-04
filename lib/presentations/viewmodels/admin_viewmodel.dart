// lib/presentations/viewmodels/admin_viewmodel.dart

import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
import 'package:flutter/foundation.dart';

class AdminViewModel extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();

  AdminViewModel() {
    chargerUtilisateurs();
  }

  bool _isLoading = false;
  String? _errorMessage;
  List<UtilisateurModele> _utilisateurs = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<UtilisateurModele> get utilisateurs => _utilisateurs;

  Future<void> chargerUtilisateurs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final usersData = await _firebase.getTousLesUtilisateurs();
      _utilisateurs =
          usersData.map((data) => UtilisateurModele.fromMap(data)).toList();
      // On s'assure que l'administrateur ne se voit pas lui-même dans la liste pour éviter une auto-suppression
      final adminUid = _firebase.getCurrentUserId();
      _utilisateurs.removeWhere((user) => user.uid == adminUid);
    } catch (e) {
      _errorMessage = "Erreur de chargement des utilisateurs : ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Note : La création d'utilisateur est gérée par le `AuthViewModel` via le formulaire d'inscription.
  // L'admin pourrait avoir un formulaire dédié, mais pour l'instant, on se concentre sur la gestion.

  Future<void> changerRoleUtilisateur(String uid, String nouveauRole) async {
    try {
      await _firebase.updateUserRole(uid, nouveauRole);
      // Mettre à jour la liste locale pour un retour visuel instantané
      final index = _utilisateurs.indexWhere((user) => user.uid == uid);
      if (index != -1) {
        final userToUpdate = _utilisateurs[index];
        _utilisateurs[index] = UtilisateurModele(
          uid: userToUpdate.uid,
          nom: userToUpdate.nom,
          email: userToUpdate.email,
          role: nouveauRole, // Le seul champ qui change
          numAffiliation: userToUpdate.numAffiliation,
        );
        notifyListeners();
      }
    } catch (e) {
      throw Exception("Erreur lors du changement de rôle : ${e.toString()}");
    }
  }

  Future<void> supprimerUtilisateur(String uid) async {
    try {
      // Note : La suppression d'un utilisateur dans Firebase Auth est une opération sensible
      // qui nécessite des droits élevés, souvent via des Cloud Functions.
      // Ici, nous nous contentons de supprimer le document Firestore.
      await _firebase.deleteUserDocument(uid);
      _utilisateurs.removeWhere((user) => user.uid == uid);
      notifyListeners();
    } catch (e) {
      throw Exception("Erreur lors de la suppression : ${e.toString()}");
    }
  }
}

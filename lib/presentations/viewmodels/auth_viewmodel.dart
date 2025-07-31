// lib/presentations/viewmodels/auth_viewmodel.dart

import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
import 'package:cnss_app/donnees/sqlite_service.dart';
import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final SQLiteService _sqliteService = SQLiteService.instance;

  bool _isLoading = false;
  String? _errorMessage;
  UtilisateurModele? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UtilisateurModele? get currentUser => _currentUser;

  Future<void> register({
    required String email,
    required String password,
    required String nom,
    required String role,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _firebaseService.register(
        email: email,
        password: password,
        nom: nom,
        role: role,
      );
      if (user == null) {
        throw Exception(
          "Erreur lors de la création de l'utilisateur Firebase.",
        );
      }

      final utilisateur = UtilisateurModele(
        uid: user.uid,
        email: email,
        nom: nom,
        role: role,
        numAffiliation: '',
      );

      await _sqliteService.saveOrUpdateUtilisateur(utilisateur);
      // NOUVEAU : Mettre à jour l'état de l'utilisateur courant apres la connexion
      _currentUser = utilisateur;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // --- CONNEXION ---
  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _firebaseService.login(email, password);
      if (user == null) {
        throw Exception(
          "Impossible de récupérer l'utilisateur après la connexion.",
        );
      }

      final donneesUtilisateur = await _firebaseService.getDonneesUtilisateur(
        user.uid,
      );
      if (donneesUtilisateur == null) {
        throw Exception(
          "Le profil de l'utilisateur est introuvable dans la base de données.",
        );
      }

      final utilisateur = UtilisateurModele.fromMap(donneesUtilisateur);

      await _sqliteService.saveOrUpdateUtilisateur(utilisateur);
      // NOUVEAU : Mettre à jour l'état de l'utilisateur courant après la connexion
      _currentUser = utilisateur;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // --- DÉCONNEXION ---
  Future<void> logout() async {
    _setLoading(true);
    _setError(null);

    try {
      final String? currentUid = _firebaseService.getCurrentUserId();
      await _firebaseService.logout();
      if (currentUid != null) {
        await _sqliteService.deleteUtilisateur(currentUid);
      }
      // NOUVEAU : Réinitialiser l'état de l'utilisateur courant
      _currentUser = null;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentUser() async {
    final uid = _firebaseService.getCurrentUserId();
    if (uid != null) {
      try {
        _currentUser = await _sqliteService.getUtilisateur(uid);
        notifyListeners();

        final onlineData = await _firebaseService.getDonneesUtilisateur(uid);
        if (onlineData != null) {
          _currentUser = UtilisateurModele.fromMap(onlineData);
          await _sqliteService.saveOrUpdateUtilisateur(_currentUser!);
          notifyListeners();
        }
      } catch (e) {
        // Gérer l'erreur si besoin
      }
    }
  }

  Future<void> updateUserProfile({
    required String nom,
    required String numAffiliation,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final uid = _firebaseService.getCurrentUserId();
      if (uid == null) throw Exception("Utilisateur non connecté.");

      await _firebaseService.updateUserProfile(
        uid,
        nom: nom,
        numAffiliation: numAffiliation,
      );
      if (_currentUser != null) {
        _currentUser = UtilisateurModele(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          role: _currentUser!.role,
          nom: nom,
          numAffiliation: numAffiliation,
        );
        await _sqliteService.saveOrUpdateUtilisateur(_currentUser!);
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // --- Méthodes privées pour gérer l'état ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}

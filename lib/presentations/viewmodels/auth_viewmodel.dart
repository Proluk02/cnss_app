// lib/presentations/viewmodels/auth_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cnss_app/donnees/sqlite_service.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  final SQLiteService _sqliteService = SQLiteService.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- INSCRIPTION ---
  Future<void> register({
    required String email,
    required String password,
    required String nom,
    required String role,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // 1. Enregistrement en ligne sur Firebase
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

      // 2. Création du modèle de données local
      final utilisateur = UtilisateurModele(
        uid: user.uid,
        email: email,
        nom: nom,
        role: role,
      );

      // 3. Sauvegarde de la session dans la base de données locale SQLite
      await _sqliteService.saveOrUpdateUtilisateur(utilisateur);
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
      // 1. Connexion en ligne avec Firebase
      final user = await _firebaseService.login(email, password);

      if (user == null) {
        throw Exception(
          "Impossible de récupérer l'utilisateur après la connexion.",
        );
      }

      // 2. Récupération des données complètes de l'utilisateur depuis Firestore
      final donneesUtilisateur = await _firebaseService.getDonneesUtilisateur(
        user.uid,
      );

      if (donneesUtilisateur == null) {
        throw Exception(
          "Le profil de l'utilisateur est introuvable dans la base de données.",
        );
      }

      // 3. Création et sauvegarde du modèle local pour la session hors-ligne
      final utilisateur = UtilisateurModele.fromMap(donneesUtilisateur);
      await _sqliteService.saveOrUpdateUtilisateur(utilisateur);
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
      // 1. Récupérer l'ID de l'utilisateur actuel AVANT de le déconnecter
      final String? currentUid = _firebaseService.getCurrentUserId();

      // 2. Déconnexion de Firebase
      await _firebaseService.logout();

      // 3. Si un utilisateur était bien connecté, nettoyer sa session locale
      if (currentUid != null) {
        await _sqliteService.deleteUtilisateur(currentUid);
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

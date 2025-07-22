import 'package:flutter/foundation.dart';
import '/donnees/firebase_service.dart';
import '/donnees/sqlite_service.dart';
import '/donnees/modeles/utilisateur_modele.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final SqliteService _sqliteService = SqliteService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Inscription combinée Firebase + SQLite
  Future<void> register({
    required String email,
    required String password,
    required String nom,
    required String role,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // 1. Enregistrement Firebase + Firestore
      final user = await _firebaseService.register(
        email: email,
        password: password,
        nom: nom,
        role: role,
      );

      if (user == null) {
        throw Exception("Erreur lors de l'inscription Firebase");
      }

      // 2. Création de l'utilisateur local
      final utilisateur = UtilisateurModele(
        uid: user.uid,
        email: email,
        nom: nom,
        role: role,
      );

      // 3. Sauvegarde locale SQLite
      await _sqliteService.saveOrUpdateUtilisateur(utilisateur);

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      rethrow; // Optionnel : remonter l'erreur à la vue
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}

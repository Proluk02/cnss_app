// lib/presentations/viewmodels/prepose_viewmodel.dart

import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:flutter/foundation.dart';

class PreposeViewModel extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();

  // --- ÉTATS ---

  // Pour le chargement initial de la liste complète
  bool _isLoading = false;
  String? _errorMessage;
  List<UtilisateurModele> _tousLesEmployeurs = [];

  // Pour la recherche en temps réel
  bool _isSearching = false;
  String? _searchErrorMessage;
  List<UtilisateurModele> _searchResults = [];

  // Pour la fiche de compte
  bool _isLoadingFiche = false;
  String? _ficheErrorMessage;
  List<RapportDeclaration> _ficheDeCompte = [];

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<UtilisateurModele> get tousLesEmployeurs => _tousLesEmployeurs;

  bool get isSearching => _isSearching;
  String? get searchErrorMessage => _searchErrorMessage;
  List<UtilisateurModele> get searchResults => _searchResults;

  bool get isLoadingFiche => _isLoadingFiche;
  String? get ficheErrorMessage => _ficheErrorMessage;
  List<RapportDeclaration> get ficheDeCompte => _ficheDeCompte;

  PreposeViewModel() {
    chargerTousLesEmployeurs();
  }

  /// Charge la liste complète de tous les employeurs une seule fois
  Future<void> chargerTousLesEmployeurs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _firebase.getTousLesEmployeurs();
      _tousLesEmployeurs =
          data.map((d) => UtilisateurModele.fromMap(d)).toList();
      if (_tousLesEmployeurs.isEmpty) {
        _errorMessage = "Aucun employeur trouvé dans le système.";
      }
    } catch (e) {
      _errorMessage =
          "Erreur de chargement des employeurs. Un index est probablement manquant.";
      _tousLesEmployeurs = [];
      debugPrint("ERREUR PREPOSE VM (chargerTousLesEmployeurs): $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recherche les employeurs dans Firestore en fonction d'une requête.
  Future<void> rechercherEmployeurs(String query) async {
    if (query.length < 3) {
      _searchResults = [];
      _searchErrorMessage = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchErrorMessage = null;
    notifyListeners();

    try {
      final data = await _firebase.rechercherEmployeurs(query);
      _searchResults = data.map((d) => UtilisateurModele.fromMap(d)).toList();
    } catch (e) {
      _searchErrorMessage = "Erreur de recherche : ${e.toString()}";
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Charge l'historique complet des déclarations pour un employeur spécifique.
  Future<void> chargerFicheDeCompte(String employeurUid) async {
    _isLoadingFiche = true;
    _ficheErrorMessage = null;
    _ficheDeCompte = [];
    notifyListeners();

    try {
      final data = await _firebase.getHistoriqueCompletEmployeur(employeurUid);
      _ficheDeCompte = data.map((d) => RapportDeclaration.fromMap(d)).toList();
    } catch (e) {
      _ficheErrorMessage = "Erreur de chargement de la fiche : ${e.toString()}";
      _ficheDeCompte = [];
    } finally {
      _isLoadingFiche = false;
      notifyListeners();
    }
  }

  void clearFicheDeCompte() {
    _ficheDeCompte = [];
    notifyListeners();
  }
}

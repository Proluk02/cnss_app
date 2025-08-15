// lib/presentations/viewmodels/prepose_viewmodel.dart

import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:flutter/foundation.dart';

class PreposeViewModel extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();

  bool _isLoading = false;
  String? _errorMessage;
  List<UtilisateurModele> _tousLesEmployeurs = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<UtilisateurModele> get tousLesEmployeurs => _tousLesEmployeurs;

  bool _isLoadingFiche = false;
  String? _ficheErrorMessage;
  List<RapportDeclaration> _ficheDeCompte = [];

  bool get isLoadingFiche => _isLoadingFiche;
  String? get ficheErrorMessage => _ficheErrorMessage;
  List<RapportDeclaration> get ficheDeCompte => _ficheDeCompte;

  PreposeViewModel() {
    chargerTousLesEmployeurs();
  }

  Future<void> chargerTousLesEmployeurs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _firebase.getTousLesEmployeurs();

      _tousLesEmployeurs =
          data.map((d) => UtilisateurModele.fromMap(d)).toList();

      if (_tousLesEmployeurs.isEmpty) {
        _errorMessage =
            "Aucun document avec role: 'employeur' n'a été trouvé. Vérifiez les données dans Firestore.";
      }
    } catch (e) {
      _errorMessage =
          "Erreur de chargement des employeurs. Un index est probablement manquant sur Firestore (role ASC, nom_lower ASC).";
      _tousLesEmployeurs = [];
      debugPrint("ERREUR PREPOSE VM: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

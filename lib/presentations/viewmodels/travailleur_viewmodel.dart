// lib/presentations/viewmodels/travailleur_viewmodel.dart

import 'package:cnss_app/donnees/modeles/travailleur_modele.dart';
import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class TravailleurViewModel extends ChangeNotifier {
  final String uid;
  final FirebaseService _firebase = FirebaseService();
  final Uuid _uuid = Uuid();

  TravailleurViewModel({required this.uid}) {
    chargerTravailleurs();
  }

  bool _isLoading = false;
  String? _errorMessage;
  List<TravailleurModele> _travailleurs = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TravailleurModele> get travailleurs => _travailleurs;

  Future<void> chargerTravailleurs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final serverData = await _firebase.getTousLesTravailleurs(uid);
      _travailleurs =
          serverData.map((data) => TravailleurModele.fromMap(data)).toList();
    } catch (e) {
      _errorMessage = "Erreur de chargement des travailleurs : ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ajouterTravailleur(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Les champs `syncStatus` et `lastModified` sont toujours utiles pour le modèle de données,
      // même si la synchro est directe.
      final nouveauTravailleur = TravailleurModele(
        id: _uuid.v4(),
        matricule: data['matricule'],
        immatriculationCNSS: data['immatriculationCNSS'],
        nom: data['nom'],
        postNoms: data['postNoms'],
        prenoms: data['prenoms'],
        typeTravailleur: data['typeTravailleur'],
        communeAffectation: data['communeAffectation'],
        enfantsBeneficiaires: 0,
        syncStatus: 'synced', // Directement synchronisé
        lastModified: DateTime.now(),
      );

      // 1. Enregistrement direct sur Firebase
      await _firebase.syncTravailleur(uid, nouveauTravailleur.toMap());

      // 2. Mise à jour de l'état local pour une UI réactive
      _travailleurs.add(nouveauTravailleur);
    } catch (e) {
      _errorMessage = "L'ajout a échoué : ${e.toString()}";
      throw Exception(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// lib/presentations/viewmodels/decompteur_viewmodel.dart

import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cnss_app/donnees/pdf_service.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:flutter/foundation.dart';

// Modèle pour combiner les données du rapport et de l'employeur
class RapportJournalier {
  final RapportDeclaration rapport;
  final String employeurNom;
  final String numAffiliation;

  RapportJournalier({
    required this.rapport,
    required this.employeurNom,
    required this.numAffiliation,
  });
}

class DecompteurViewModel extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();

  DateTime _selectedDate = DateTime.now();
  List<RapportJournalier> _declarationsDuJour = [];
  bool _isLoading = false;
  String? _errorMessage;

  DateTime get selectedDate => _selectedDate;
  List<RapportJournalier> get declarationsDuJour => _declarationsDuJour;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DecompteurViewModel() {
    chargerDeclarationsDuJour(_selectedDate);
  }

  // La logique est maintenant dans un Future, plus simple à gérer
  Future<void> chargerDeclarationsDuJour(DateTime jour) async {
    _selectedDate = jour;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data =
          await _firebase.getDeclarationsValideesDuJourAvecEmployeur(jour);
      _declarationsDuJour = data
          .map((d) => RapportJournalier(
                rapport: RapportDeclaration.fromMap(d),
                employeurNom: d['employeurNom'] ?? 'N/A',
                numAffiliation: d['numAffiliation'] ?? 'N/A',
              ))
          .toList();
      _errorMessage = null;
    } catch (e) {
      debugPrint(
          "ERREUR DECOMPTEUR VM: L'index Firestore est probablement manquant.");
      debugPrint("Détail de l'erreur: $e");
      _errorMessage =
          "Erreur de chargement. Un index Firestore est requis. Vérifiez la console.";
      _declarationsDuJour = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> imprimerEtatJournalier() async {
    if (_declarationsDuJour.isEmpty) return;

    final pdfService = PdfService();
    await pdfService.imprimerEtatJournalier(
      date: _selectedDate,
      rapportsJournaliers: _declarationsDuJour,
    );
  }
}

// lib/presentations/viewmodels/chef_ses_viewmodel.dart

import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:flutter/foundation.dart';

class DeclarationEnAttente {
  final RapportDeclaration rapport;
  final String employeurUid;
  final String employeurNom;

  DeclarationEnAttente({
    required this.rapport,
    required this.employeurUid,
    required this.employeurNom,
  });
}

class ChefSesViewModel extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();

  ChefSesViewModel() {
    _ecouterDeclarationsEnAttente();
  }

  bool _isLoading = true;
  String? _errorMessage;
  List<DeclarationEnAttente> _declarations = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DeclarationEnAttente> get declarations => _declarations;

  void _ecouterDeclarationsEnAttente() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _firebase.getDeclarationsEnAttenteStream().listen(
      (snapshot) async {
        try {
          List<DeclarationEnAttente> tempList = [];
          for (var doc in snapshot.docs) {
            final rapport = RapportDeclaration.fromMap(
              doc.data() as Map<String, dynamic>,
            );
            final employeurUid = doc.reference.parent.parent!.id;
            final employeurData = await _firebase.getDonneesUtilisateur(
              employeurUid,
            );

            tempList.add(
              DeclarationEnAttente(
                rapport: rapport,
                employeurUid: employeurUid,
                employeurNom: employeurData?['nom'] ?? 'Employeur inconnu',
              ),
            );
          }
          _declarations = tempList;
          _errorMessage = null;
        } catch (e) {
          _errorMessage = "Erreur de traitement des données : ${e.toString()}";
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (error) {
        _errorMessage = "Erreur de chargement : ${error.toString()}";
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> validerDeclaration(DeclarationEnAttente declaration) async {
    try {
      await _firebase.updateDeclarationStatus(
        declaration.employeurUid,
        declaration.rapport.periode,
        StatutDeclaration.VALIDEE,
      );
    } catch (e) {
      throw Exception("La validation a échoué : ${e.toString()}");
    }
  }

  Future<void> rejeterDeclaration(
    DeclarationEnAttente declaration,
    String motif,
  ) async {
    try {
      if (motif.trim().isEmpty) {
        throw Exception("Le motif de rejet ne peut pas être vide.");
      }
      await _firebase.updateDeclarationStatus(
        declaration.employeurUid,
        declaration.rapport.periode,
        StatutDeclaration.REJETEE,
        motifRejet: motif,
      );
    } catch (e) {
      throw Exception("Le rejet a échoué : ${e.toString()}");
    }
  }
}

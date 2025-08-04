// lib/presentations/viewmodels/chef_ses_viewmodel.dart

import 'dart:async';
import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  StreamSubscription? _declarationsSubscription;

  ChefSesViewModel() {
    _ecouterToutesLesDeclarations();
  }

  bool _isLoading = true;
  String? _errorMessage;

  List<DeclarationEnAttente> _declarationsEnAttente = [];
  List<RapportDeclaration> _toutesDeclarations = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DeclarationEnAttente> get declarations => _declarationsEnAttente;
  List<RapportDeclaration> get historiqueComplet =>
      _toutesDeclarations
          .where((d) => d.statut != StatutDeclaration.EN_ATTENTE)
          .toList();

  int get nombreEnAttente => _declarationsEnAttente.length;

  int get nombreValideesAujourdhui {
    final now = DateTime.now();
    return _toutesDeclarations.where((d) {
      final docData = (d as dynamic).toMap();
      final timestamp = docData['dateFinalisation'] as Timestamp?;
      if (timestamp == null) return false;

      final date = timestamp.toDate();
      return d.statut == StatutDeclaration.VALIDEE &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).length;
  }

  Map<StatutDeclaration, double> get repartitionStatuts {
    final map = <StatutDeclaration, double>{};
    for (var declaration in _toutesDeclarations) {
      map[declaration.statut] = (map[declaration.statut] ?? 0) + 1;
    }
    return map;
  }

  void _ecouterToutesLesDeclarations() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _declarationsSubscription?.cancel();
    _declarationsSubscription = _firebase
        .getToutesLesDeclarationsFinaliseesStream()
        .listen(
          (snapshot) async {
            _isLoading = true;
            notifyListeners();

            try {
              _toutesDeclarations =
                  snapshot.docs
                      .map(
                        (doc) => RapportDeclaration.fromMap(
                          doc.data() as Map<String, dynamic>,
                        ),
                      )
                      .toList();

              List<DeclarationEnAttente> tempListEnAttente = [];
              for (var doc in snapshot.docs.where(
                (d) => d['statut'] == 'EN_ATTENTE',
              )) {
                final rapport = RapportDeclaration.fromMap(
                  doc.data() as Map<String, dynamic>,
                );
                final employeurUid = doc.reference.parent.parent!.id;
                final employeurData = await _firebase.getDonneesUtilisateur(
                  employeurUid,
                );

                tempListEnAttente.add(
                  DeclarationEnAttente(
                    rapport: rapport,
                    employeurUid: employeurUid,
                    employeurNom: employeurData?['nom'] ?? 'Employeur inconnu',
                  ),
                );
              }
              _declarationsEnAttente = tempListEnAttente;
              _errorMessage = null;
            } catch (e) {
              _errorMessage =
                  "Erreur de traitement des données : ${e.toString()}";
            } finally {
              _isLoading = false;
              notifyListeners();
            }
          },
          onError: (error) {
            _errorMessage =
                "Erreur de chargement du flux. L'index Firestore est peut-être manquant.";
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _declarationsSubscription?.cancel();
    super.dispose();
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
      if (motif.trim().isEmpty)
        throw Exception("Le motif de rejet ne peut pas être vide.");
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

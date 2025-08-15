// lib/presentations/viewmodels/directeur_viewmodel.dart

import 'dart:async';
import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DirecteurViewModel extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  StreamSubscription? _declarationsSubscription;
  StreamSubscription? _usersSubscription;

  DirecteurViewModel() {
    rafraichirDonnees();
  }

  // --- ÉTATS ---
  bool _isLoading = true;
  String? _errorMessage;

  int _nombreEmployeurs = 0;
  double _totalCotisationsMoisEnCours = 0.0;
  int _declarationsEnRetard = 0;
  List<RapportDeclaration> _declarationsRecentes = [];
  Map<String, double> _cotisationsParMois = {};

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get nombreEmployeurs => _nombreEmployeurs;
  double get totalCotisationsMoisEnCours => _totalCotisationsMoisEnCours;
  int get declarationsEnRetard => _declarationsEnRetard;
  List<RapportDeclaration> get declarationsRecentes => _declarationsRecentes;
  Map<String, double> get cotisationsParMois => _cotisationsParMois;

  // --- LOGIQUE ---
  Future<void> rafraichirDonnees() async {
    _ecouterLesDonnees();
  }

  void _ecouterLesDonnees() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _usersSubscription?.cancel();
    _usersSubscription =
        _firebase.getTousLesEmployeursStream().listen((userSnapshot) {
      final employeurs = userSnapshot.docs
          .map((doc) => UtilisateurModele.fromFirestore(doc))
          .toList();
      _nombreEmployeurs = employeurs.length;

      // Le calcul du retard se fait ici, car nous avons besoin de la liste des employeurs.
      final now = DateTime.now();
      final moisDeReference = DateTime(now.year, now.month - 1);
      int retardCount = 0;

      for (var employeur in employeurs) {
        final dernierePeriodeTs = (employeur as dynamic)
            .toMap()['dernierePeriodeDeclaree'] as Timestamp?;
        final dernierePeriode = dernierePeriodeTs?.toDate();

        if (dernierePeriode == null) {
          // Si un employeur n'a jamais déclaré, on peut le considérer en retard si le mois de référence est passé.
          // Pour l'instant, on ne compte que ceux qui ont déjà déclaré.
        } else {
          final prochainePeriodeADeclarer =
              DateTime(dernierePeriode.year, dernierePeriode.month + 1);
          if (prochainePeriodeADeclarer.isBefore(moisDeReference)) {
            retardCount++;
          }
        }
      }
      _declarationsEnRetard = retardCount;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = "Erreur de chargement des utilisateurs.";
      _isLoading = false;
      notifyListeners();
    });

    _declarationsSubscription?.cancel();
    _declarationsSubscription = _firebase
        .getToutesLesDeclarationsFinaliseesStream()
        .listen((declarationSnapshot) {
      final now = DateTime.now();
      final moisEnCours = DateTime(now.year, now.month);

      double totalCotisations = 0.0;
      List<RapportDeclaration> toutesDeclarations = [];
      final Map<String, double> monthlyTotals = {};

      for (var doc in declarationSnapshot.docs) {
        final rapport =
            RapportDeclaration.fromMap(doc.data() as Map<String, dynamic>);
        toutesDeclarations.add(rapport);

        final docData = doc.data() as Map<String, dynamic>;
        final dateValidation =
            (docData['dateValidation'] as Timestamp?)?.toDate();

        if (rapport.statut == StatutDeclaration.VALIDEE &&
            dateValidation != null &&
            dateValidation.year == moisEnCours.year &&
            dateValidation.month == moisEnCours.month) {
          totalCotisations += rapport.totalDesCotisations;
        }

        if (rapport.statut == StatutDeclaration.VALIDEE) {
          final monthKey = rapport.periode.substring(0, 7);
          monthlyTotals[monthKey] =
              (monthlyTotals[monthKey] ?? 0) + rapport.totalDesCotisations;
        }
      }

      _totalCotisationsMoisEnCours = totalCotisations;
      _declarationsRecentes = toutesDeclarations
          .where((d) => d.statut == StatutDeclaration.VALIDEE)
          .take(5)
          .toList();
      _cotisationsParMois = monthlyTotals;

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = "Erreur de chargement des déclarations.";
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _declarationsSubscription?.cancel();
    super.dispose();
  }
}

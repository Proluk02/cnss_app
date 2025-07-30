// lib/presentations/viewmodels/declaration_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:cnss_app/donnees/modeles/declaration_modele.dart';
import 'package:cnss_app/donnees/modeles/travailleur_modele.dart';
import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RapportDeclaration {
  final String periode;
  final double montantTotalBrut;
  final int nombreTravailleurs;
  final int nombreAssimiles;
  final double montantRev;
  final double cotisationPension;
  final double cotisationRisquePro;
  final double cotisationFamille;
  final double totalDesCotisations;

  RapportDeclaration({
    required this.periode,
    required this.montantTotalBrut,
    required this.nombreTravailleurs,
    required this.nombreAssimiles,
    required this.montantRev,
    required this.cotisationPension,
    required this.cotisationRisquePro,
    required this.cotisationFamille,
    required this.totalDesCotisations,
  });

  Map<String, dynamic> toMap() {
    return {
      'periode': periode,
      'montantTotalBrut': montantTotalBrut,
      'nombreTravailleurs': nombreTravailleurs,
      'nombreAssimiles': nombreAssimiles,
      'montantRev': montantRev,
      'cotisationPension': cotisationPension,
      'cotisationRisquePro': cotisationRisquePro,
      'cotisationFamille': cotisationFamille,
      'totalDesCotisations': totalDesCotisations,
      'dateFinalisation': Timestamp.now(),
    };
  }
}

class DeclarationViewModel extends ChangeNotifier {
  final String uid;
  final FirebaseService _firebase = FirebaseService();

  DeclarationViewModel({required this.uid}) {
    initialiser();
  }

  bool isLoading = true;
  String? erreurMessage;
  DateTime? periodeActuelle;
  Map<String, DeclarationTravailleurModele> brouillonActuel = {};
  List<TravailleurModele> tousLesTravailleurs = [];

  String get periodeAffichee =>
      periodeActuelle != null
          ? DateFormat.yMMMM('fr_FR').format(periodeActuelle!)
          : "Indéterminée";
  List<DeclarationTravailleurModele> get lignesBrouillon =>
      brouillonActuel.values.toList();
  bool get peutDeclarer => !isLoading && erreurMessage == null;

  Future<void> initialiser() async {
    isLoading = true;
    erreurMessage = null;
    notifyListeners();

    try {
      final donneesEmployeur = await _firebase.getDonneesUtilisateur(uid);
      final ts = donneesEmployeur?['dernierePeriodeDeclaree'] as Timestamp?;
      final dernierePeriodeDeclaree = ts?.toDate();

      if (dernierePeriodeDeclaree == null) {
        periodeActuelle = DateTime(
          DateTime.now().year,
          DateTime.now().month - 1,
        );
      } else {
        periodeActuelle = DateTime(
          dernierePeriodeDeclaree.year,
          dernierePeriodeDeclaree.month + 1,
        );
      }

      tousLesTravailleurs =
          (await _firebase.getTousLesTravailleurs(
            uid,
          )).map((data) => TravailleurModele.fromMap(data)).toList();
      if (tousLesTravailleurs.isEmpty) {
        throw Exception("Veuillez ajouter des travailleurs avant de déclarer.");
      }

      await chargerBrouillon(notify: false);
    } catch (e) {
      erreurMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> chargerBrouillon({bool notify = true}) async {
    if (periodeActuelle == null) return;
    final periodeCle = DateFormat('yyyy-MM').format(periodeActuelle!);

    final brouillonSauvegarde =
        (await _firebase.getTousLesBrouillons(uid))
            .where((b) => b['periode'] == periodeCle)
            .map((data) => DeclarationTravailleurModele.fromMap(data))
            .toList();

    brouillonActuel.clear();
    for (var travailleur in tousLesTravailleurs) {
      final entreeExistante = brouillonSauvegarde.firstWhere(
        (b) => b.travailleurId == travailleur.id,
        orElse:
            () => DeclarationTravailleurModele(
              id: '${travailleur.id}_$periodeCle',
              travailleurId: travailleur.id,
              periode: periodeCle,
              salaireBrut: 0.0,
              joursTravail: 0,
              heuresTravail: 0,
              typeTravailleur: travailleur.typeTravailleur,
              syncStatus: 'synced',
              lastModified: DateTime.now(),
            ),
      );
      brouillonActuel[travailleur.id] = entreeExistante;
    }
    if (notify) notifyListeners();
  }

  void updateLigneBrouillon({
    required String travailleurId,
    double? salaireBrut,
    int? heuresTravail,
  }) {
    if (brouillonActuel.containsKey(travailleurId) && periodeActuelle != null) {
      final oldLigne = brouillonActuel[travailleurId]!;
      final newLine = DeclarationTravailleurModele(
        id: oldLigne.id,
        travailleurId: oldLigne.travailleurId,
        periode: oldLigne.periode,
        salaireBrut: salaireBrut ?? oldLigne.salaireBrut,
        joursTravail: oldLigne.joursTravail,
        heuresTravail: heuresTravail ?? oldLigne.heuresTravail,
        typeTravailleur: oldLigne.typeTravailleur,
        syncStatus: 'synced',
        lastModified: DateTime.now(),
      );

      brouillonActuel[travailleurId] = newLine;
      notifyListeners();
      _firebase.syncBrouillon(uid, newLine.toMap());
    }
  }

  Future<void> finaliserDeclaration() async {
    if (!peutDeclarer)
      throw Exception("Impossible de finaliser la déclaration.");

    isLoading = true;
    notifyListeners();

    try {
      final rapport = _calculerRapportFinal();
      await _firebase.finaliserDeclarationEnLigne(
        uid,
        rapport.periode,
        periodeActuelle!,
        rapport,
      );
      await initialiser();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      throw Exception("La finalisation a échoué : ${e.toString()}");
    }
  }

  RapportDeclaration _calculerRapportFinal() {
    final lignes = brouillonActuel.values.toList();
    final montantTotalBrut = lignes.fold(0.0, (sum, d) => sum + d.salaireBrut);
    final montantR = montantTotalBrut;
    final nombreTravailleurs =
        lignes.where((d) => d.typeTravailleur == 1).length;
    final nombreAssimiles = lignes.where((d) => d.typeTravailleur == 2).length;
    final montantRev = lignes
        .where((d) => d.typeTravailleur == 2)
        .fold(0.0, (sum, d) => sum + d.salaireBrut);

    final cotisationPension = montantR * 0.10;
    final cotisationRisquePro = montantR * 0.015;
    final cotisationFamille = montantR * 0.065;
    final totalDesCotisations =
        cotisationPension + cotisationRisquePro + cotisationFamille;

    return RapportDeclaration(
      periode: DateFormat('yyyy-MM').format(periodeActuelle!),
      montantTotalBrut: montantTotalBrut,
      nombreTravailleurs: nombreTravailleurs,
      nombreAssimiles: nombreAssimiles,
      montantRev: montantRev,
      cotisationPension: cotisationPension,
      cotisationRisquePro: cotisationRisquePro,
      cotisationFamille: cotisationFamille,
      totalDesCotisations: totalDesCotisations,
    );
  }
}

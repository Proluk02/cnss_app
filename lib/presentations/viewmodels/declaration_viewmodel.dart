// lib/presentations/viewmodels/declaration_viewmodel.dart

import 'package:cnss_app/donnees/modeles/declaration_modele.dart';
import 'package:cnss_app/donnees/modeles/travailleur_modele.dart';
import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum StatutEmployeur { EN_ORDRE, EN_RETARD, A_JOUR, INDETERMINE }

enum StatutDeclaration { EN_ATTENTE, VALIDEE, REJETEE, INCONNU }

class RapportDeclaration {
  final String periode;
  final double totalDesCotisations;
  final StatutDeclaration statut;
  final String? motifRejet;
  final double montantTotalBrut;
  final int nombreTravailleurs;
  final int nombreAssimiles;
  final double montantRev;
  final double cotisationPension;
  final double cotisationRisquePro;
  final double cotisationFamille;

  RapportDeclaration({
    required this.periode,
    required this.totalDesCotisations,
    required this.statut,
    this.motifRejet,
    required this.montantTotalBrut,
    required this.nombreTravailleurs,
    required this.nombreAssimiles,
    required this.montantRev,
    required this.cotisationPension,
    required this.cotisationRisquePro,
    required this.cotisationFamille,
  });

  Map<String, dynamic> toMap() {
    return {
      'periode': periode,
      'totalDesCotisations': totalDesCotisations,
      'statut': statut.toString().split('.').last,
      'motifRejet': motifRejet,
      'montantTotalBrut': montantTotalBrut,
      'nombreTravailleurs': nombreTravailleurs,
      'nombreAssimiles': nombreAssimiles,
      'montantRev': montantRev,
      'cotisationPension': cotisationPension,
      'cotisationRisquePro': cotisationRisquePro,
      'cotisationFamille': cotisationFamille,
      'dateFinalisation': Timestamp.now(),
    };
  }

  factory RapportDeclaration.fromMap(Map<String, dynamic> map) {
    return RapportDeclaration(
      periode: map['periode'] ?? '',
      totalDesCotisations: (map['totalDesCotisations'] ?? 0.0).toDouble(),
      statut: StatutDeclaration.values.firstWhere(
        (e) => e.toString().split('.').last == map['statut'],
        orElse: () => StatutDeclaration.INCONNU,
      ),
      motifRejet: map['motifRejet'],
      montantTotalBrut: (map['montantTotalBrut'] ?? 0.0).toDouble(),
      nombreTravailleurs: map['nombreTravailleurs'] ?? 0,
      nombreAssimiles: map['nombreAssimiles'] ?? 0,
      montantRev: (map['montantRev'] ?? 0.0).toDouble(),
      cotisationPension: (map['cotisationPension'] ?? 0.0).toDouble(),
      cotisationRisquePro: (map['cotisationRisquePro'] ?? 0.0).toDouble(),
      cotisationFamille: (map['cotisationFamille'] ?? 0.0).toDouble(),
    );
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
  List<RapportDeclaration> declarationsRecentes = [];
  List<RapportDeclaration> historiqueComplet = [];

  String get periodeAffichee =>
      periodeActuelle != null
          ? DateFormat.yMMMM('fr_FR').format(periodeActuelle!)
          : "Indéterminée";
  List<DeclarationTravailleurModele> get lignesBrouillon =>
      brouillonActuel.values.toList();
  bool get peutDeclarer => !isLoading && erreurMessage == null;
  bool get isBrouillonEditable => statut != StatutEmployeur.A_JOUR;

  StatutEmployeur get statut {
    if (periodeActuelle == null) return StatutEmployeur.INDETERMINE;

    // Si la dernière déclaration a été rejetée, le statut est "en retard" jusqu'à correction.
    if (declarationsRecentes.isNotEmpty &&
        declarationsRecentes.first.statut == StatutDeclaration.REJETEE) {
      return StatutEmployeur.EN_RETARD;
    }

    final now = DateTime.now();
    final moisDeReference = DateTime(now.year, now.month - 1);
    if (periodeActuelle!.isBefore(moisDeReference))
      return StatutEmployeur.EN_RETARD;
    if (periodeActuelle!.isAtSameMomentAs(moisDeReference) ||
        (periodeActuelle!.year == now.year &&
            periodeActuelle!.month == now.month))
      return StatutEmployeur.EN_ORDRE;
    return StatutEmployeur.A_JOUR;
  }

  Future<void> initialiser() async {
    isLoading = true;
    erreurMessage = null;
    notifyListeners();
    try {
      await chargerDeclarationsRecentes();
      final derniereDeclaration =
          declarationsRecentes.isNotEmpty ? declarationsRecentes.first : null;

      if (derniereDeclaration != null &&
          derniereDeclaration.statut == StatutDeclaration.REJETEE) {
        final dateParts = derniereDeclaration.periode.split('-');
        periodeActuelle = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
        );
      } else {
        final donneesEmployeur = await _firebase.getDonneesUtilisateur(uid);
        final ts = donneesEmployeur?['dernierePeriodeDeclaree'] as Timestamp?;
        final dernierePeriodeDeclaree = ts?.toDate();
        periodeActuelle =
            (dernierePeriodeDeclaree == null)
                ? DateTime(DateTime.now().year, DateTime.now().month - 1)
                : DateTime(
                  dernierePeriodeDeclaree.year,
                  dernierePeriodeDeclaree.month + 1,
                );
      }

      tousLesTravailleurs =
          (await _firebase.getTousLesTravailleurs(
            uid,
          )).map((data) => TravailleurModele.fromMap(data)).toList();
      await chargerBrouillon(notify: false);
    } catch (e) {
      erreurMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> chargerDeclarationsRecentes() async {
    final data = await _firebase.getDeclarationsRecentes(uid);
    declarationsRecentes =
        data.map((d) => RapportDeclaration.fromMap(d)).toList();
  }

  Future<void> chargerHistoriqueComplet() async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await _firebase.getToutHistorique(uid);
      historiqueComplet =
          data.map((d) => RapportDeclaration.fromMap(d)).toList();
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
    erreurMessage = null;
    notifyListeners();
    try {
      final lignesValides =
          brouillonActuel.values
              .where((ligne) => ligne.salaireBrut > 0)
              .toList();
      if (lignesValides.isEmpty)
        throw Exception(
          "Veuillez renseigner le salaire pour au moins un employé.",
        );

      final rapport = _calculerRapportFinal(lignesValides);

      await _firebase.finaliserDeclarationEnLigne(
        uid,
        rapport.periode,
        periodeActuelle!,
        rapport,
        lignesValides,
      );
      await initialiser();
    } catch (e) {
      erreurMessage = "La finalisation a échoué : ${e.toString()}";
      throw Exception(erreurMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  RapportDeclaration _calculerRapportFinal(
    List<DeclarationTravailleurModele> lignes,
  ) {
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
      statut: StatutDeclaration.EN_ATTENTE,
      montantTotalBrut: montantTotalBrut,
      nombreTravailleurs: nombreTravailleurs,
      nombreAssimiles: nombreAssimiles,
      montantRev: montantRev,
      cotisationPension: cotisationPension,
      cotisationRisquePro: cotisationRisquePro,
      cotisationFamille: cotisationFamille,
      totalDesCotisations: totalDesCotisations,
      motifRejet: null,
    );
  }
}

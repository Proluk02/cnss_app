// lib/presentations/viewmodels/travailleur_viewmodel.dart

import 'package:cnss_app/donnees/modeles/travailleur_modele.dart';
import 'package:cnss_app/donnees/firebase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
    notifyListeners();
    try {
      final nouveauTravailleur = TravailleurModele(
        id: _uuid.v4(),
        matricule: data['matricule'],
        immatriculationCNSS: data['immatriculationCNSS'],
        nom: data['nom'],
        postNoms: data['postNoms'],
        prenoms: data['prenoms'],
        typeTravailleur: data['typeTravailleur'],
        communeAffectation: data['communeAffectation'],
        enfantsBeneficiaires: 0, // Initialisé à 0
        lastModified: DateTime.now(),
      );
      await _firebase.syncTravailleur(uid, nouveauTravailleur.toMap());
      _travailleurs.add(nouveauTravailleur);
      _travailleurs.sort((a, b) => a.nom.compareTo(b.nom));
    } catch (e) {
      throw Exception("L'ajout a échoué : ${e.toString()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> mettreAJourTravailleur(
    String id,
    Map<String, dynamic> data,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final index = _travailleurs.indexWhere((t) => t.id == id);
      if (index == -1) throw Exception("Travailleur introuvable");

      final travailleurActuel = _travailleurs[index];
      final travailleurMisAJour = TravailleurModele(
        id: id,
        matricule: data['matricule'],
        immatriculationCNSS: data['immatriculationCNSS'],
        nom: data['nom'],
        postNoms: data['postNoms'],
        prenoms: data['prenoms'],
        typeTravailleur: data['typeTravailleur'],
        communeAffectation: data['communeAffectation'],
        enfantsBeneficiaires: travailleurActuel.enfantsBeneficiaires,
        lastModified: DateTime.now(),
      );
      await _firebase.syncTravailleur(uid, travailleurMisAJour.toMap());
      _travailleurs[index] = travailleurMisAJour;
      _travailleurs.sort((a, b) => a.nom.compareTo(b.nom));
    } catch (e) {
      throw Exception("La mise à jour a échoué : ${e.toString()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> supprimerTravailleur(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebase.deleteTravailleur(uid, id);
      _travailleurs.removeWhere((t) => t.id == id);
    } catch (e) {
      throw Exception("La suppression a échoué : ${e.toString()}");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> imprimerListeTravailleurs() async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) {
          return pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Liste des Employés",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              headers: ['Nom Complet', 'Matricule', 'N° CNSS'],
              data:
                  travailleurs
                      .map(
                        (t) => [
                          t.nomComplet,
                          t.matricule,
                          t.immatriculationCNSS,
                        ],
                      )
                      .toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }
}

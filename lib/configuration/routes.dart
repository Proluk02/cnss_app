// Définition des routes
import 'package:flutter/material.dart';
import '../presentations/vues/authentification/connexion.dart';
import '../presentations/formulaires/formulaire_inscription.dart';
import '../presentations/vues/admin/gestion_utilisateurs.dart';
import '../presentations/vues/tableau_bord.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/connexion':
      return MaterialPageRoute(builder: (_) => const ConnexionPage());
    case '/inscription':
      return MaterialPageRoute(builder: (_) => const FormulaireInscription());
    case '/admin':
      return MaterialPageRoute(builder: (_) => const GestionUtilisateurs());
    case '/dashboard':
      return MaterialPageRoute(builder: (_) => const TableauBord(role: ''));
    default:
      return MaterialPageRoute(
        builder:
            (_) =>
                const Scaffold(body: Center(child: Text("Page non trouvée"))),
      );
  }
}

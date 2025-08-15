// lib/main.dart

import 'package:cnss_app/presentations/viewmodels/auth_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/declaration_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/travailleur_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// NOUVEAUX IMPORTS NÉCESSAIRES POUR LA LOCALISATION
import 'package:flutter_localizations/flutter_localizations.dart';

import 'donnees/firebase_service.dart';
import 'firebase_options.dart';
import 'presentations/vues/accueil/splash_screen.dart';
import 'presentations/vues/accueil/welcome_screen.dart';
import 'presentations/vues/admin/admin_dashboard.dart';
import 'presentations/vues/authentification/connexion.dart'; // Assurez-vous que cet import est là si ConnexionPage est utilisée
import 'presentations/vues/tableau_bord.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CNSSApp());
}

class CNSSApp extends StatelessWidget {
  const CNSSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: MaterialApp(
        title: 'CnssApp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),

        // --- CORRECTION AJOUTÉE ICI ---
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale(
            'fr',
            'FR',
          ), // Définir le français comme langue supportée par défaut
        ],
        locale: const Locale(
          'fr',
          'FR',
        ), // Forcer l'application à utiliser le français

        // --- FIN DE LA CORRECTION ---
        home: const SessionWrapper(),
      ),
    );
  }
}

class SessionWrapper extends StatelessWidget {
  const SessionWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseService().userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<String?>(
            future: FirebaseService().getUserRole(user.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              final role = roleSnapshot.data;
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (_) => TravailleurViewModel(uid: user.uid),
                  ),
                  ChangeNotifierProvider(
                    create: (_) => DeclarationViewModel(uid: user.uid),
                  ),
                ],
                child: Builder(
                  builder: (context) {
                    switch (role) {
                      case 'employeur':
                      case 'chefSES':
                      case 'préposé':
                      case 'décompteur':
                      case 'directeur':
                        return TableauBord(role: role!);
                      case 'administrateur':
                        return const AdminDashboard();
                      default:
                        return const WelcomeScreen();
                    }
                  },
                ),
              );
            },
          );
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}

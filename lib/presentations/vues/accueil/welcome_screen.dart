// lib/presentations/vues/accueil/welcome_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/formulaires/formulaire_inscription.dart';
import 'package:cnss_app/presentations/vues/authentification/connexion.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isLargeScreen = size.width > 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, kSecondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? size.width * 0.20 : 32,
              vertical: 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo avec fond circulaire et ombre soft
                Container(
                  width: isLargeScreen ? 180 : 140,
                  height: isLargeScreen ? 180 : 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(isLargeScreen ? 40 : 20),
                  child: Image.asset(
                    'assets/images/logo_cnss.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),

                const SizedBox(height: 48),

                // Titre
                Text(
                  'Bienvenue sur CNSSApp',
                  style: kTitleStyle.copyWith(
                    color: Colors.white,
                    fontSize: isLargeScreen ? 36 : 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    shadows: const [
                      Shadow(
                        color: Colors.black38,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description courte
                Text(
                  'Votre portail social numérique pour gérer vos cotisations rapidement et en toute simplicité.',
                  style: kSubtitleStyle.copyWith(
                    color: Colors.white70,
                    fontSize: isLargeScreen ? 18 : 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // Boutons principaux
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        // CORRECTION ICI : Remplacement de pushNamed par push
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ConnexionPage(),
                              ),
                            ),
                        icon: const Icon(Icons.login, size: 20),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: kPrimaryColor,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kButtonRadius),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        // CORRECTION ICI : Remplacement de pushNamed par push
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const FormulaireInscription(),
                              ),
                            ),
                        icon: const Icon(
                          Icons.person_add_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'Créer un compte',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kButtonRadius),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Footer copyright
                Text(
                  '© ${DateTime.now().year} CNSS - Direction Provinciale de Kamina',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

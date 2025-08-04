// lib/presentations/vues/admin/tabs/admin_settings_tab.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:flutter/material.dart';

class AdminSettingsTab extends StatelessWidget {
  const AdminSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings_suggest_outlined,
                size: 100,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                "Paramètres Système",
                style: kTitleStyle.copyWith(color: kDarkText),
              ),
              const SizedBox(height: 8),
              Text(
                "Cette section est réservée aux futures configurations globales de l'application.",
                textAlign: TextAlign.center,
                style: kLabelStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

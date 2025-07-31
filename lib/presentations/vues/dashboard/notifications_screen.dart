// lib/presentations/vues/dashboard/notifications_screen.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Notifications"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kAppBarGradient),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 100,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                "Aucune nouvelle notification",
                style: kTitleStyle.copyWith(color: kDarkText),
              ),
              const SizedBox(height: 8),
              Text(
                "Le statut de vos déclarations et autres alertes importantes apparaîtront ici.",
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

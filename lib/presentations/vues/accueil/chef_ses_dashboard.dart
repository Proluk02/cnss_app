// lib/presentations/vues/accueil/chef_ses_dashboard.dart

import 'package:cnss_app/core/constantes.dart';
import 'package:cnss_app/presentations/viewmodels/auth_viewmodel.dart';
import 'package:cnss_app/presentations/viewmodels/chef_ses_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chef_ses_tabs/ses_home_tab.dart';
import 'chef_ses_tabs/ses_pending_tab.dart';
import 'chef_ses_tabs/ses_history_tab.dart';

class ChefSESDashboard extends StatefulWidget {
  const ChefSESDashboard({super.key});

  @override
  State<ChefSESDashboard> createState() => _ChefSESDashboardState();
}

class _ChefSESDashboardState extends State<ChefSESDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const SesHomeTab(),
    const SesPendingTab(),
    const SesHistoryTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChefSesViewModel(),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: const Text(
            "Chef de Centre",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: kAppBarGradient),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => context.read<AuthViewModel>().logout(),
            ),
          ],
        ),
        drawer: _buildCustomDrawer(context),
        body: IndexedStack(index: _selectedIndex, children: _tabs),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: kGreyText,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: "Accueil",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hourglass_top_outlined),
              label: "À Valider",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              label: "Historique",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDrawer(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(gradient: kAppBarGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/images/logo_cnss.png', height: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  currentUser?.displayName ?? "Chef de Centre",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?.email ?? "chef.ses@cnss.app",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: [
                _drawerItem(0, 'Tableau de bord', Icons.dashboard_outlined),
                _drawerItem(
                  1,
                  'Déclarations à valider',
                  Icons.hourglass_top_outlined,
                ),
                _drawerItem(
                  2,
                  'Historique des validations',
                  Icons.history_outlined,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'CnssApp v1.0.0',
              style: TextStyle(color: kGreyText, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(int index, String title, IconData icon) {
    final bool isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? kPrimaryColor : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? kPrimaryColor : kDarkText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

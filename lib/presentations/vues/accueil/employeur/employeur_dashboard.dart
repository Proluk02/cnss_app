import 'package:cnss_app/core/constantes.dart';
import 'package:flutter/material.dart';
import 'dashboard_home.dart';
import 'workers_list.dart';
import 'worker_add_form.dart';
import 'declaration_entry_screen.dart';
import 'package:cnss_app/donnees/modeles/travailleur.dart';

class EmployeurDashboard extends StatefulWidget {
  const EmployeurDashboard({super.key});

  @override
  State<EmployeurDashboard> createState() => _EmployeurDashboardState();
}

class _EmployeurDashboardState extends State<EmployeurDashboard> {
  int _selectedIndex = 0;
  Travailleur? _selectedTravailleur;

  final List<Map<String, dynamic>> _bottomNavItems = [
    {'icon': Icons.home_outlined, 'label': 'Accueil'},
    {'icon': Icons.people_outline, 'label': 'Employés'},
    {'icon': Icons.note_add_outlined, 'label': 'Déclarer'},
    {'icon': Icons.history_outlined, 'label': 'Historique'},
    {'icon': Icons.help_outline, 'label': 'Aide'},
  ];

  void _onWorkerSelected(Travailleur t) {
    setState(() {
      _selectedTravailleur = t;
      _selectedIndex = 2;
    });
  }

  void _onDeclarationSaved(Map<String, dynamic> data) {
    setState(() {
      _selectedIndex = 1;
      _selectedTravailleur = null;
    });
  }

  void _showAddWorkerDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: WorkerAddForm(
                onWorkerAdded: (travailleur) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Travailleur ${travailleur.nomComplet} ajouté !',
                      ),
                      backgroundColor: kSuccessColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const DashboardHome(),
      WorkersList(onWorkerSelected: _onWorkerSelected),
      DeclarationEntryScreen(
        travailleur: _selectedTravailleur,
        onDeclarationSaved: _onDeclarationSaved,
      ),
      const Center(child: Text('Historique des Déclarations')),
      const Center(child: Text('Aide et Support')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'E-Déclaration CNSS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kSecondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.account_circle_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryColor, kSecondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text("Nom de l'employeur"),
              accountEmail: Text("employeur@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person_outline, color: kPrimaryColor),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(0, 'Tableau de bord', Icons.dashboard_outlined),
                  _drawerItem(
                    1,
                    'Gestion des employés',
                    Icons.people_alt_outlined,
                  ),
                  _drawerItem(
                    2,
                    'Nouvelle déclaration',
                    Icons.note_add_outlined,
                  ),
                  _drawerItem(3, 'Historique', Icons.history_outlined),
                  _drawerItem(4, 'Aide & Support', Icons.help_outline_outlined),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('Paramètres'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      'Déconnexion',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(color: Colors.grey[50], child: tabs[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index != 2) _selectedTravailleur = null;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontSize: 12),
        items:
            _bottomNavItems.map((item) {
              return BottomNavigationBarItem(
                icon: Icon(item['icon']),
                label: item['label'],
              );
            }).toList(),
      ),
      floatingActionButton:
          _selectedIndex == 1
              ? FloatingActionButton(
                onPressed: _showAddWorkerDialog,
                child: Icon(Icons.person_add_alt_1, size: 28),
                backgroundColor: kPrimaryColor,
                elevation: 4,
              )
              : null,
    );
  }

  Widget _drawerItem(int index, String title, IconData icon) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index ? kPrimaryColor : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _selectedIndex == index ? kPrimaryColor : Colors.grey[800],
          fontWeight:
              _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
          if (index != 2) _selectedTravailleur = null;
        });
        Navigator.pop(context);
      },
    );
  }
}

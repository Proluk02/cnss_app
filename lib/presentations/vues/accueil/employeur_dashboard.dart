import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constantes.dart';
import 'package:flutter/services.dart';

class Travailleur {
  final String id;
  final String matricule;
  final String immatriculationCNSS;
  final String nom;
  final String postNoms;
  final String prenoms;
  final int typeTravailleur;
  final String communeAffectation;

  Travailleur({
    required this.id,
    required this.matricule,
    required this.immatriculationCNSS,
    required this.nom,
    required this.postNoms,
    required this.prenoms,
    required this.typeTravailleur,
    required this.communeAffectation,
  });

  String get nomComplet => '$nom $postNoms $prenoms';

  factory Travailleur.fromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Travailleur(
      id: doc.id,
      matricule: data['matricule'] ?? '',
      immatriculationCNSS: data['immatriculationCNSS'] ?? '',
      nom: data['nom'] ?? '',
      postNoms: data['postNoms'] ?? '',
      prenoms: data['prenoms'] ?? '',
      typeTravailleur: data['typeTravailleur'] ?? 1,
      communeAffectation: data['communeAffectation'] ?? '',
    );
  }
}

class EmployeurDashboard extends StatefulWidget {
  const EmployeurDashboard({super.key});

  @override
  State<EmployeurDashboard> createState() => _EmployeurDashboardState();
}

class _EmployeurDashboardState extends State<EmployeurDashboard> {
  int _selectedIndex = 0;
  Travailleur? _selectedTravailleur;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar avec gradient linéaire CNSS
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text('E-Déclaration CNSS'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kSecondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          PopupMenuButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person_outline, size: 20, color: Colors.white),
            ),
            offset: const Offset(0, 50),
            itemBuilder:
                (context) => const [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.account_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Mon profil'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Paramètres'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Déconnexion'),
                      ],
                    ),
                  ),
                ],
            onSelected: (value) {
              // TODO: gérer actions menu
            },
          ),
          const SizedBox(width: 16),
        ],
      ),

      drawer: _buildDrawer(),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildMainDashboard(context),
          _buildWorkersList(),
          DeclarationEntryScreen(
            travailleur: _selectedTravailleur,
            onDeclarationSaved: (data) => _saveDeclaration(data),
          ),
          const Center(child: Text('Historique')),
          const Center(child: Text('Aide')),
          const Center(child: Text('À propos')),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex < 4 ? _selectedIndex : 0,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1),
            label: 'Employés',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_outlined),
            label: 'Déclarer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'Historique',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          if (_selectedIndex == 1) {
            _showAddWorkerDialog();
          } else if (_selectedIndex == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sélectionnez un travailleur pour déclarer.'),
              ),
            );
          } else {
            showModalBottomSheet(
              context: context,
              builder: (context) => _buildQuickActionsSheet(),
            );
          }
        },
      ),
    );
  }

  Drawer _buildDrawer() => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kSecondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/logo_cnss.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'CNSS E-Déclaration',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        _drawerItem(0, 'Tableau de bord', Icons.dashboard_outlined),
        _drawerItem(1, 'Déclarer un employé', Icons.person_add_alt_1),
        _drawerItem(
          2,
          'Déclaration mensuelle',
          Icons.assignment_turned_in_outlined,
        ),
        _drawerItem(3, 'Historique', Icons.history_outlined),
        const Divider(),
        _drawerItem(4, 'Aide', Icons.help_outline),
        _drawerItem(5, 'À propos', Icons.info_outline),
      ],
    ),
  );

  ListTile _drawerItem(int index, String title, IconData icon) {
    final selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: selected ? kPrimaryColor : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? kPrimaryColor : Colors.black87,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      onTap: () {
        setState(() {
          _selectedIndex = index;
          if (index != 2) _selectedTravailleur = null;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildMainDashboard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatCard(
                title: 'Déclarations',
                value: '265',
                icon: Icons.assignment_turned_in_outlined,
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 16),
              _StatCard(
                title: 'Notifications',
                value: '12',
                icon: Icons.notifications_outlined,
                color: Colors.orange,
              ),
            ],
          ),
          // Reste de votre contenu dashboard (ex : graphiques, listes)
          // Vous pouvez intégrer ici les graphs avec fl_chart et données Firestore
        ],
      ),
    );
  }

  Widget _StatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('travailleurs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text('Erreur lors du chargement'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty)
          return const Center(child: Text('Aucun travailleur enregistré.'));

        final travailleurs =
            docs.map((doc) => Travailleur.fromDoc(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(kDefaultPadding),
          itemCount: travailleurs.length,
          itemBuilder: (context, index) {
            final t = travailleurs[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kCardRadius),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(t.nomComplet),
                subtitle: Text(
                  'Matricule: ${t.matricule} | CNSS: ${t.immatriculationCNSS}',
                ),
                trailing: Text(
                  t.typeTravailleur == 1 ? 'Travailleur' : 'Assimilé',
                ),
                onTap: () {
                  setState(() {
                    _selectedTravailleur = t;
                    _selectedIndex = 2;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveDeclaration(Map<String, dynamic> data) async {
    if (_selectedTravailleur == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun travailleur sélectionné')),
      );
      return;
    }
    try {
      final path = _db
          .collection('travailleurs')
          .doc(_selectedTravailleur!.id)
          .collection('declarations');
      await path.add(data);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Déclaration sauvegardée')));
      setState(() => _selectedIndex = 1);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur en sauvegardant: $e')));
    }
  }

  void _showAddWorkerDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: WorkerAddForm(
              onWorkerAdded: (travailleur) {
                _db.collection('travailleurs').add({
                  'matricule': travailleur.matricule,
                  'immatriculationCNSS': travailleur.immatriculationCNSS,
                  'nom': travailleur.nom,
                  'postNoms': travailleur.postNoms,
                  'prenoms': travailleur.prenoms,
                  'typeTravailleur': travailleur.typeTravailleur,
                  'communeAffectation': travailleur.communeAffectation,
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Travailleur ajouté')),
                );
              },
            ),
          ),
    );
  }

  Widget _buildQuickActionsSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction('Nouvel employé', Icons.person_add, () {
                Navigator.pop(context);
                _showAddWorkerDialog();
                setState(() => _selectedIndex = 1);
              }),
              _buildQuickAction('Déclarer', Icons.assignment_add, () {
                Navigator.pop(context);
                if (_selectedTravailleur == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sélectionnez un travailleur d’abord'),
                    ),
                  );
                  return;
                }
                setState(() => _selectedIndex = 2);
              }),
              _buildQuickAction('Historique', Icons.history, () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 3);
              }),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kButtonRadius),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(kButtonRadius),
            ),
            child: Icon(icon, color: kPrimaryColor, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// Formulaire d'ajout d'un travailleur avec validation et input formatters
class WorkerAddForm extends StatefulWidget {
  final Function(Travailleur) onWorkerAdded;
  const WorkerAddForm({super.key, required this.onWorkerAdded});

  @override
  State<WorkerAddForm> createState() => _WorkerAddFormState();
}

class _WorkerAddFormState extends State<WorkerAddForm> {
  final _formKey = GlobalKey<FormState>();

  final _matriculeController = TextEditingController();
  final _cnssController = TextEditingController();
  final _nomController = TextEditingController();
  final _postNomsController = TextEditingController();
  final _prenomsController = TextEditingController();
  final _communeController = TextEditingController();
  int _typeTravailleur = 1;

  @override
  void dispose() {
    _matriculeController.dispose();
    _cnssController.dispose();
    _nomController.dispose();
    _postNomsController.dispose();
    _prenomsController.dispose();
    _communeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onWorkerAdded(
      Travailleur(
        id: '',
        matricule: _matriculeController.text.trim(),
        immatriculationCNSS: _cnssController.text.trim(),
        nom: _nomController.text.trim(),
        postNoms: _postNomsController.text.trim(),
        prenoms: _prenomsController.text.trim(),
        typeTravailleur: _typeTravailleur,
        communeAffectation: _communeController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ajouter un travailleur',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _matriculeController,
              decoration: const InputDecoration(
                labelText: 'Matricule travailleur',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              ],
            ),
            TextFormField(
              controller: _cnssController,
              decoration: const InputDecoration(
                labelText: 'Numéro immatriculation CNSS',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s-]')),
              ],
            ),
            TextFormField(
              controller: _postNomsController,
              decoration: const InputDecoration(labelText: 'Post-noms'),
              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s-]')),
              ],
            ),
            TextFormField(
              controller: _prenomsController,
              decoration: const InputDecoration(labelText: 'Prénoms'),
              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s-]')),
              ],
            ),
            DropdownButtonFormField<int>(
              value: _typeTravailleur,
              decoration: const InputDecoration(
                labelText: 'Type de travailleur',
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Travailleur')),
                DropdownMenuItem(value: 2, child: Text('Assimilé')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _typeTravailleur = v);
              },
            ),
            TextFormField(
              controller: _communeController,
              decoration: const InputDecoration(
                labelText: 'Commune ou territoire d\'affectation',
              ),
              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s-]')),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _submit, child: const Text('Ajouter')),
          ],
        ),
      ),
    );
  }
}

// Formulaire déclaration avec contrôle strict des champs numériques et dates
class DeclarationEntryScreen extends StatefulWidget {
  final Travailleur? travailleur;
  final Function(Map<String, dynamic>)? onDeclarationSaved;

  const DeclarationEntryScreen({
    super.key,
    this.travailleur,
    this.onDeclarationSaved,
  });

  @override
  State<DeclarationEntryScreen> createState() => _DeclarationEntryScreenState();
}

class _DeclarationEntryScreenState extends State<DeclarationEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _periodeController = TextEditingController();
  final _montantCotiseController = TextEditingController();
  final _nbJoursController = TextEditingController();
  final _nbHeuresController = TextEditingController();
  final _montantBrutController = TextEditingController();

  @override
  void dispose() {
    _periodeController.dispose();
    _montantCotiseController.dispose();
    _nbJoursController.dispose();
    _nbHeuresController.dispose();
    _montantBrutController.dispose();
    super.dispose();
  }

  // Expression régulière simple pour date au format jj/mm/aaaa
  final RegExp dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final declaration = {
        "periodeCotisee": _periodeController.text,
        "montantCotise": double.parse(_montantCotiseController.text),
        "nbJoursTravail": int.parse(_nbJoursController.text),
        "nbHeuresTravail": int.parse(_nbHeuresController.text),
        "montantBrutImposable": double.parse(_montantBrutController.text),
        "dateEnregistrement": DateTime.now(),
      };
      widget.onDeclarationSaved?.call(declaration);
      _clearForm();
    }
  }

  void _clearForm() {
    _periodeController.clear();
    _montantCotiseController.clear();
    _nbJoursController.clear();
    _nbHeuresController.clear();
    _montantBrutController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.travailleur;
    if (t == null) {
      return const Center(
        child: Text("Veuillez sélectionner un travailleur pour déclarer."),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              "Déclaration pour : ${t.nomComplet}",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text("Matricule : ${t.matricule}"),
            Text("Immatriculation CNSS : ${t.immatriculationCNSS}"),
            Text(
              "Type : ${t.typeTravailleur == 1 ? 'Travailleur' : 'Assimilé'}",
            ),
            Text("Commune : ${t.communeAffectation}"),
            const SizedBox(height: 16),
            TextFormField(
              controller: _periodeController,
              decoration: const InputDecoration(
                labelText: "Période cotisée (jj/mm/aaaa)",
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Champ obligatoire';
                if (!dateRegex.hasMatch(v)) return 'Format jj/mm/aaaa requis';
                return null;
              },
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
              ],
            ),
            TextFormField(
              controller: _montantCotiseController,
              decoration: const InputDecoration(labelText: "Montant cotisé"),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Champ obligatoire';
                final d = double.tryParse(v.replaceAll(',', '.'));
                if (d == null || d < 0) return 'Nombre valide requis';
                return null;
              },
            ),
            TextFormField(
              controller: _nbJoursController,
              decoration: const InputDecoration(
                labelText: "Nombre de jours de travail",
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Champ obligatoire';
                final n = int.tryParse(v);
                if (n == null || n < 0) return 'Nombre valide requis';
                return null;
              },
            ),
            TextFormField(
              controller: _nbHeuresController,
              decoration: const InputDecoration(
                labelText: "Nombre d'heures de travail",
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Champ obligatoire';
                final n = int.tryParse(v);
                if (n == null || n < 0) return 'Nombre valide requis';
                return null;
              },
            ),
            TextFormField(
              controller: _montantBrutController,
              decoration: const InputDecoration(
                labelText: "Montant brut imposable",
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Champ obligatoire';
                final d = double.tryParse(v.replaceAll(',', '.'));
                if (d == null || d < 0) return 'Nombre valide requis';
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Soumettre la déclaration'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'modeles/utilisateur_modele.dart';

class SqliteService {
  static final SqliteService _instance = SqliteService._internal();
  factory SqliteService() => _instance;
  SqliteService._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'cnss_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE utilisateur (
            uid TEXT PRIMARY KEY,
            email TEXT,
            nom TEXT,
            role TEXT
          )
        ''');
        // 🔜 Tu pourras ajouter ici la création des tables déclaration, fiche_cotisant, etc.
      },
    );
  }

  // 🧾 Enregistrer ou mettre à jour un utilisateur
  Future<void> saveOrUpdateUtilisateur(UtilisateurModele utilisateur) async {
    final db = await database;
    await db.insert(
      'utilisateur',
      utilisateur.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 🔍 Lire un utilisateur localement par UID
  Future<UtilisateurModele?> getUtilisateur(String uid) async {
    final db = await database;
    final result = await db.query(
      'utilisateur',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    if (result.isNotEmpty) {
      return UtilisateurModele.fromMap(result.first);
    }
    return null;
  }

  // 🔍 Obtenir rôle local (pour TableauBord offline)
  Future<String?> getUserRoleLocally(String uid) async {
    final user = await getUtilisateur(uid);
    return user?.role;
  }

  // 🔐 Supprimer utilisateur local
  Future<void> deleteUtilisateur(String uid) async {
    final db = await database;
    await db.delete('utilisateur', where: 'uid = ?', whereArgs: [uid]);
  }

  // 🧹 Nettoyer base
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('utilisateur');
  }
}

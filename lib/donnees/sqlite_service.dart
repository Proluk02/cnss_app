// lib/donnees/sqlite_service.dart

import 'package:cnss_app/donnees/modeles/declaration_modele.dart';
import 'package:cnss_app/donnees/modeles/travailleur_modele.dart';
import 'package:cnss_app/donnees/modeles/utilisateur_modele.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// CORRECTION : Renommé en SQLiteService avec un 'Q' majuscule
class SQLiteService {
  // CORRECTION : Le constructeur interne doit correspondre
  SQLiteService._internal();

  // CORRECTION : L'instance doit correspondre
  static final SQLiteService instance = SQLiteService._internal();
  factory SQLiteService() => instance;

  static Database? _db;
  Future<Database> get database async => _db ??= await _initDB();

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'cnss_full_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE utilisateur (uid TEXT PRIMARY KEY, email TEXT, nom TEXT, role TEXT)
    ''');
    await db.execute('''
      CREATE TABLE travailleurs (id TEXT PRIMARY KEY, employeurUid TEXT NOT NULL, matricule TEXT, immatriculationCNSS TEXT, nom TEXT, postNoms TEXT, prenoms TEXT, typeTravailleur INTEGER NOT NULL, communeAffectation TEXT, enfantsBeneficiaires INTEGER, syncStatus TEXT NOT NULL, lastModified TEXT NOT NULL)
    ''');
    await db.execute('''
      CREATE TABLE declarations_brouillons (id TEXT PRIMARY KEY, employeurUid TEXT NOT NULL, travailleurId TEXT NOT NULL, periode TEXT NOT NULL, salaireBrut REAL, joursTravail INTEGER, heuresTravail INTEGER, typeTravailleur INTEGER, syncStatus TEXT NOT NULL, lastModified TEXT NOT NULL)
    ''');
  }

  // --- CRUD Utilisateur ---
  Future<void> saveOrUpdateUtilisateur(UtilisateurModele utilisateur) async {
    final db = await database;
    await db.insert(
      'utilisateur',
      utilisateur.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UtilisateurModele?> getUtilisateur(String uid) async {
    final db = await database;
    final result = await db.query(
      'utilisateur',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    return result.isNotEmpty ? UtilisateurModele.fromMap(result.first) : null;
  }

  Future<int> deleteUtilisateur(String uid) async {
    final db = await database;
    return await db.delete('utilisateur', where: 'uid = ?', whereArgs: [uid]);
  }

  // --- CRUD & SYNC pour Travailleurs ---
  Future<void> addOrUpdateTravailleur(
    String employeurUid,
    TravailleurModele travailleur,
  ) async {
    final db = await database;
    var map = travailleur.toMap();
    map['employeurUid'] = employeurUid;
    await db.insert(
      'travailleurs',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TravailleurModele>> getTravailleurs(String employeurUid) async {
    final db = await database;
    final maps = await db.query(
      'travailleurs',
      where: 'employeurUid = ?',
      whereArgs: [employeurUid],
      orderBy: 'nom ASC',
    );
    return maps.map((map) => TravailleurModele.fromMap(map)).toList();
  }

  Future<int> deleteTravailleur(String id) async {
    final db = await database;
    return await db.delete('travailleurs', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD & SYNC pour Brouillons de Déclaration ---
  Future<void> saveLigneBrouillon(
    String employeurUid,
    DeclarationTravailleurModele brouillon,
  ) async {
    final db = await database;
    var map = brouillon.toMap();
    map['employeurUid'] = employeurUid;
    await db.insert(
      'declarations_brouillons',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DeclarationTravailleurModele>> getBrouillonPourPeriode(
    String employeurUid,
    String periode,
  ) async {
    final db = await database;
    final maps = await db.query(
      'declarations_brouillons',
      where: 'employeurUid = ? AND periode = ?',
      whereArgs: [employeurUid, periode],
    );
    return maps
        .map((map) => DeclarationTravailleurModele.fromMap(map))
        .toList();
  }

  Future<void> deleteBrouillonPourPeriode(
    String employeurUid,
    String periode,
  ) async {
    final db = await database;
    await db.delete(
      'declarations_brouillons',
      where: 'employeurUid = ? AND periode = ?',
      whereArgs: [employeurUid, periode],
    );
  }

  // --- Méthodes Génériques de Synchronisation ---
  Future<List<Map<String, dynamic>>> getPendingRecords(
    String tableName,
    String employeurUid,
  ) async {
    final db = await database;
    return db.query(
      tableName,
      where: 'employeurUid = ? AND syncStatus = ?',
      whereArgs: [employeurUid, 'pending'],
    );
  }

  Future<void> batchUpdateFromFirebase(
    String tableName,
    String employeurUid,
    List<Map<String, dynamic>> records,
  ) async {
    final db = await database;
    final batch = db.batch();
    for (var record in records) {
      record['employeurUid'] = employeurUid;
      batch.insert(
        tableName,
        record,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> markAsSynced(String tableName, String id) async {
    final db = await database;
    await db.update(
      tableName,
      {'syncStatus': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

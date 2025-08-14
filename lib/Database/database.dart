import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:visiting_card_app/main.dart';
import '../Model/user_profile.dart';

class DBService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cards.db');

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE visiting_cards(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fields TEXT,
            extras TEXT,
            qrData TEXT,
            type TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE visiting_cards ADD COLUMN type TEXT');
        }
      },
    );

    return _db!;
  }

  static Future<int> insertVisitingCard(VisitingCard card) async {
    final db = await database;
    return db.insert('visiting_cards', card.toMap());
  }

  static Future<List<VisitingCard>> getAllVisitingCards() async {
    final db = await database;
    final rows = await db.query('visiting_cards', orderBy: 'id DESC');
    return rows.map((r) => VisitingCard.fromMap(r)).toList();
  }

  static Future<int> deleteVisitingCard(int id) async {
    final db = await database;
    return db.delete('visiting_cards', where: 'id = ?', whereArgs: [id]);
  }

  static Future<VisitingCard?> getVisitingCardById(int id) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query('visiting_cards', where: 'id = ?', whereArgs: [id], limit: 1);

    if (results.isNotEmpty) {
      return VisitingCard.fromMap(results.first);
    }
    return null; // Not found
  }

  static Future<int> updateVisitingCard(VisitingCard card) async {
    final db = await database;
    if (card.id == null) {
      throw Exception("Card ID is required for update.");
    }
    return db.update('visiting_cards', card.toMap(), where: 'id = ?', whereArgs: [card.id]);
  }
}

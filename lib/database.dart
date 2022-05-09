import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'expense.dart';

class SQLiteDbProvider {
  SQLiteDbProvider._();
  static final SQLiteDbProvider db = SQLiteDbProvider._();
  static late Database _database;
  Future<Database> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await initDB();
      return _database;
    }
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "expense.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE expense (id INTEGER PRIMARY KEY,montant REAL,date TEXT,category TEXT)");
      await db.execute(
          "INSERT INTO expense (id,montant,date,category) VALUES (?,?,?,?)",
          [1, 100, '2020-01-01', 'food']);
    });
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    List<Map> results = await db.query("Expense",
        columns: Expense.colums, orderBy: 'date DESC');
    List<Expense> expenses = [];
    results.forEach((element) {
      expenses.add(Expense.fromMap(element));
    });
    return expenses;
  }

  Future<Expense?> getExpenseById(int id) async {
    final db = await database;
    var result = await db.query("Expense", where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? Expense.fromMap(result.first) : null;
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    List<Map> list = await db.rawQuery("SELECT SUM(montant) FROM Expense");
    return list.isNotEmpty ? list.first['SUM(montant)'] : null;
  }

  Future<Expense> insertExpense(Expense expense) async {
    final db = await database;
    var maxIdResult =
        await db.rawQuery("SELECT MAX(id)+1 AS last_insert_id FROM Expense");
    var id = int.parse(maxIdResult.first['last_insert_id'].toString());
    var result = await db.rawInsert(
        "INSERT INTO Expense (id,montant,date,category) VALUES (?,?,?,?)",
        [id, expense.montant, expense.date.toString(), expense.category]);
    return Expense(id, expense.montant, expense.date, expense.category);
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    var result = await db.update("Expense", expense.toMap(), where: "id = ?", whereArgs: [expense.id]);
    return result;
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete("Expense", where: "id = ?", whereArgs: [id]);
  }
}

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/my_transaction.dart';

class TransactionProvider with ChangeNotifier {
  static const String _dbName = 'expenses.db';
  static const String _tableName = 'transactions';
  Database? _database;
  List<MyTransaction> _transactions = [];

  double _totalBalance = 0.0;

  List<MyTransaction> get transactions => [..._transactions];
  double get totalBalance => _totalBalance;

  TransactionProvider() {
    fetchAndSetTransactions();
  }

  Future<void> _initDatabase() async {
    if (_database != null) return;
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      _database = await openDatabase(
        path,
        version: 2,
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, amount REAL, date TEXT, type TEXT, note TEXT)',
          );
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('ALTER TABLE $_tableName ADD COLUMN note TEXT');
          }
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  Future<void> fetchAndSetTransactions() async {
    await _initDatabase();
    if (_database == null) return;

    final dataList = await _database!.query(_tableName, orderBy: 'date DESC');
    _transactions = dataList
        .map((item) => MyTransaction.fromMap(item))
        .toList();

    final incomeData = await _database!.rawQuery(
      "SELECT SUM(amount) as total FROM $_tableName WHERE type = 'income'",
    );
    final expenseData = await _database!.rawQuery(
      "SELECT SUM(amount) as total FROM $_tableName WHERE type = 'expense'",
    );

    double totalIncome = (incomeData.first['total'] as num?)?.toDouble() ?? 0.0;
    double totalExpense =
        (expenseData.first['total'] as num?)?.toDouble() ?? 0.0;

    _totalBalance = totalIncome - totalExpense;

    notifyListeners();
  }

  Future<void> addTransaction(
    String title,
    double amount,
    DateTime date,
    TransactionType type, {
    String? note,
  }) async {
    await _initDatabase();
    final newTx = MyTransaction(
      title: title,
      amount: amount,
      date: date,
      type: type,
      note: note,
    );
    await _database!.insert(_tableName, newTx.toMap());
    await fetchAndSetTransactions();
  }

  Future<void> updateTransaction(int id, MyTransaction newTx) async {
    await _initDatabase();
    await _database!.update(
      _tableName,
      newTx.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchAndSetTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _initDatabase();
    await _database!.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    await fetchAndSetTransactions();
  }

  Future<String> insert100Normal() async {
    await _initDatabase();
    final stopwatch = Stopwatch()..start(); // เริ่มจับเวลา

    for (int i = 0; i < 100; i++) {
      final newTx = MyTransaction(
        title: 'ทดสอบปกติ #$i',
        amount: 10.0,
        date: DateTime.now(),
        type: TransactionType.expense,
        note: 'Insert Normal',
      );
      await _database!.insert(_tableName, newTx.toMap());
    }

    stopwatch.stop(); // หยุดจับเวลา
    await fetchAndSetTransactions();
    return 'เพิ่มปกติ 100 รายการ ใช้เวลา: ${stopwatch.elapsedMilliseconds} ms';
  }

  Future<String> insert100Batch() async {
    await _initDatabase();
    final stopwatch = Stopwatch()..start(); // เริ่มจับเวลา

    await _database!.transaction((txn) async {
      final batch = txn.batch();
      for (int i = 0; i < 100; i++) {
        final newTx = MyTransaction(
          title: 'ทดสอบ Batch #$i',
          amount: 20.0,
          date: DateTime.now(),
          type: TransactionType.income,
          note: 'Insert Batch',
        );
        batch.insert(_tableName, newTx.toMap());
      }
      await batch.commit(noResult: true);
    });

    stopwatch.stop(); // หยุดจับเวลา
    await fetchAndSetTransactions();
    return 'เพิ่มแบบ Batch 100 รายการ ใช้เวลา: ${stopwatch.elapsedMilliseconds} ms';
  }
}

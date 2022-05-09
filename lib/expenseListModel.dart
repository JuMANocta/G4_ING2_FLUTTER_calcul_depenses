import 'dart:collection';
import 'package:scoped_model/scoped_model.dart';
import 'expense.dart';
import 'database.dart';

class ExpenseListModel extends Model {
  ExpenseListModel() {
    load();
  }

  final List<Expense> _expenses = [];
  UnmodifiableListView<Expense> get expenses => UnmodifiableListView(_expenses);

  void load() {
    Future<List<Expense>> expenses = SQLiteDbProvider.db.getAllExpenses();
    expenses.then((dbItems) {
      for (var i = 0; i < dbItems.length; i++) {
        _expenses.add(dbItems[i]);
      }
      notifyListeners();
    });
  }

  Future<double> get totalExpenses async {
    return await SQLiteDbProvider.db.getTotalExpenses();
  }

  Future<Expense?> byId(int id) async {
    return await SQLiteDbProvider.db.getExpenseById(id);
  }

  void insertExpense(Expense expense) async {
    await SQLiteDbProvider.db.insertExpense(expense).then((val) {
      _expenses.add(val);
      notifyListeners();
    });
  }

  void updateExpense(Expense expense) async {
    await SQLiteDbProvider.db.updateExpense(expense).then((val) {
      var index = _expenses.indexWhere((element) => element.id == expense.id);
      _expenses[index] = expense;
      notifyListeners();
    });
  }

  void deleteExpense(Expense expense) async {
    await SQLiteDbProvider.db.deleteExpense(expense.id).then((val) {
      _expenses.removeWhere((element) => element.id == expense.id);
      notifyListeners();
    });
  }
}

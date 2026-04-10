import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';

// This class handles all reading and writing to Hive storage
class ExpenseDatasource {
  // Get the already-opened expenses box
  final Box<Expense> _box = Hive.box<Expense>('expenses');

  // Save a new expense to the box
  Future<void> addExpense(Expense expense) async {
    await _box.put(expense.id, expense);
  }

  // Get all expenses, sorted latest first
  List<Expense> getAllExpenses() {
    final expenses = _box.values.toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  // Delete an expense by its id
  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }

  // Calculate total amount of all expenses
  double getTotalExpenses() {
    return _box.values.fold(0.0, (sum, expense) => sum + expense.amount);
  }
}
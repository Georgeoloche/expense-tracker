import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/datasource/expense_datasource.dart';
import '../../data/models/expense_model.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExpenseDatasource _datasource = ExpenseDatasource();

  // Helper to calculate all stats at once from a list
  Map<String, double> _calculateStats(List<Expense> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    double todayTotal = all
        .where((e) => DateTime(e.date.year, e.date.month, e.date.day) == today)
        .fold(0.0, (sum, e) => sum + e.amount);

    double yesterdayTotal = all
        .where((e) => DateTime(e.date.year, e.date.month, e.date.day) == yesterday)
        .fold(0.0, (sum, e) => sum + e.amount);

    return {
      'total': all.fold(0.0, (sum, e) => sum + e.amount),
      'today': todayTotal,
      'yesterday': yesterdayTotal,
    };
  }

  Map<String, List<Expense>> _groupByDay(List<Expense> expenses) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final Map<String, List<Expense>> grouped = {};

    for (final e in expenses) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      String label;
      if (day == today) {
        label = 'Today';
      } else if (day == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('EEEE, MMM dd').format(e.date);
      }
      grouped.putIfAbsent(label, () => []).add(e);
    }
    return grouped;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant;
      case 'Transport': return Icons.directions_car;
      case 'Bills': return Icons.receipt_long;
      default: return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return const Color(0xFFFF6B6B);
      case 'Transport': return const Color(0xFF4ECDC4);
      case 'Bills': return const Color(0xFFFFE66D);
      default: return const Color(0xFF6C63FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        title: Text('Expense Tracker', 
          style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      // The ValueListenableBuilder makes the UI react to Hive changes automatically
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Expense>('expenses').listenable(),
        builder: (context, Box<Expense> box, _) {
          final allExpenses = _datasource.getAllExpenses();
          final stats = _calculateStats(allExpenses);
          final grouped = _groupByDay(allExpenses);
          final groupKeys = grouped.keys.toList();

          final bool spentMoreToday = stats['yesterday']! > 0 && stats['today']! > stats['yesterday']!;
          final bool spentLessToday = stats['yesterday']! > 0 && stats['today']! < stats['yesterday']!;
          final double diff = (stats['today']! - stats['yesterday']!).abs();

          return Column(
            children: [
              // -- Header Card ------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('EEEE, MMMM dd yyyy').format(DateTime.now()),
                      style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Text('Total Spending', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 15)),
                    Text('\$${stats['total']!.toStringAsFixed(2)}',
                      style: GoogleFonts.nunito(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatTile('Today', '\$${stats['today']!.toStringAsFixed(2)}'),
                        const SizedBox(width: 12),
                        _buildStatTile('Yesterday', '\$${stats['yesterday']!.toStringAsFixed(2)}'),
                      ],
                    ),
                    if (stats['yesterday']! > 0) ...[
                      const SizedBox(height: 12),
                      _buildComparisonBadge(spentMoreToday, spentLessToday, diff),
                    ]
                  ],
                ),
              ),
              
              // -- List Section -----------------------------------------------
              Expanded(
                child: allExpenses.isEmpty 
                  ? _buildEmptyState() 
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: groupKeys.length,
                      itemBuilder: (context, index) {
                        final label = groupKeys[index];
                        final items = grouped[label]!;
                        final dayTotal = items.fold(0.0, (sum, e) => sum + e.amount);
                        
                        return _buildGroupSection(label, dayTotal, items);
                      },
                    ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // UI Components to keep the build method clean
  Widget _buildStatTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12)),
            Text(value, style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonBadge(bool more, bool less, double diff) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: more ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(more ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            more ? 'Spent \$${diff.toStringAsFixed(2)} more than yesterday' 
                 : 'Spent \$${diff.toStringAsFixed(2)} less than yesterday',
            style: GoogleFonts.nunito(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSection(String label, double total, List<Expense> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.black87)),
              Text('\$${total.toStringAsFixed(2)}', style: GoogleFonts.nunito(color: const Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        ...items.map((e) => _buildExpenseItem(e)),
      ],
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _datasource.deleteExpense(expense.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddExpenseScreen(expense: expense))),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(expense.category).withValues(alpha: 0.1),
              child: Icon(_getCategoryIcon(expense.category), color: _getCategoryColor(expense.category)),
            ),
            title: Text(expense.category, style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
            subtitle: Text(DateFormat('hh:mm a').format(expense.date), style: GoogleFonts.nunito(fontSize: 12)),
            trailing: Text('\$${expense.amount.toStringAsFixed(2)}', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: const Color(0xFF6C63FF))),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No expenses yet!', style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey[400], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
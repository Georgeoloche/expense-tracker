import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  List<Expense> _expenses = [];
  double _total = 0.0;
  double _todayTotal = 0.0;
  double _yesterdayTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    final all = _datasource.getAllExpenses();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    setState(() {
      _expenses = all;
      _total = _datasource.getTotalExpenses();
      _todayTotal = all
          .where((e) {
            final d = DateTime(e.date.year, e.date.month, e.date.day);
            return d == today;
          })
          .fold(0.0, (sum, e) => sum + e.amount);
      _yesterdayTotal = all
          .where((e) {
            final d = DateTime(e.date.year, e.date.month, e.date.day);
            return d == yesterday;
          })
          .fold(0.0, (sum, e) => sum + e.amount);
    });
  }

  void _deleteExpense(String id) async {
    await _datasource.deleteExpense(id);
    _loadExpenses();
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

  // Group expenses by day label: Today, Yesterday, or date string
  Map<String, List<Expense>> _groupByDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final Map<String, List<Expense>> grouped = {};

    for (final e in _expenses) {
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

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDay();
    final groupKeys = grouped.keys.toList();
    final now = DateTime.now();
    final bool spentMoreToday = _yesterdayTotal > 0 && _todayTotal > _yesterdayTotal;
    final bool spentLessToday = _yesterdayTotal > 0 && _todayTotal < _yesterdayTotal;
    final double diff = (_todayTotal - _yesterdayTotal).abs();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        title: Text(
          'Expense Tracker',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
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
                // Today's date
                Text(
                  DateFormat('EEEE, MMMM dd yyyy').format(now),
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Total spending
                Text(
                  'Total Spending',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${_total.toStringAsFixed(2)}',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 16),

                // Today vs Yesterday row
                Row(
                  children: [
                    // Today's spending
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today',
                              style: GoogleFonts.nunito(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '?',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Yesterday's spending
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yesterday',
                              style: GoogleFonts.nunito(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '?',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Comparison message
                if (_yesterdayTotal > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: spentMoreToday
                          ? Colors.red.withValues(alpha: 0.25)
                          : Colors.green.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          spentMoreToday
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          spentMoreToday
                              ? 'You spent ? more than yesterday'
                              : spentLessToday
                                  ? 'You spent ? less than yesterday'
                                  : 'Same as yesterday',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // -- Grouped Expenses List --------------------------------------
          Expanded(
            child: _expenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 72, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses yet!',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first expense',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: groupKeys.length,
                    itemBuilder: (context, groupIndex) {
                      final label = groupKeys[groupIndex];
                      final items = grouped[label]!;
                      final groupTotal = items.fold(
                          0.0, (sum, e) => sum + e.amount);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Day header
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 10, top: 4),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  label,
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF2D3748),
                                  ),
                                ),
                                Text(
                                  '?',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF6C63FF),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Expense items for this day
                          ...items.map((expense) {
                            final categoryColor =
                                _getCategoryColor(expense.category);
                            return Dismissible(
                              key: Key(expense.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) =>
                                  _deleteExpense(expense.id),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.only(right: 20),
                                margin:
                                    const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red[400],
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete,
                                    color: Colors.white, size: 28),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AddExpenseScreen(
                                          expense: expense),
                                    ),
                                  );
                                  _loadExpenses();
                                },
                                child: Card(
                                  margin:
                                      const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: categoryColor
                                                .withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _getCategoryIcon(
                                                expense.category),
                                            color: categoryColor,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                expense.category,
                                                style: GoogleFonts.nunito(
                                                  fontWeight:
                                                      FontWeight.w800,
                                                  fontSize: 16,
                                                  color: const Color(
                                                      0xFF2D3748),
                                                ),
                                              ),
                                              if (expense.note != null &&
                                                  expense.note!.isNotEmpty)
                                                Text(
                                                  expense.note!,
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 13,
                                                    color: Colors.grey[500],
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              Text(
                                                DateFormat('hh:mm a')
                                                    .format(expense.date),
                                                style: GoogleFonts.nunito(
                                                  fontSize: 12,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '?',
                                          style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            color:
                                                const Color(0xFF6C63FF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 4),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddExpenseScreen(),
            ),
          );
          _loadExpenses();
        },
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

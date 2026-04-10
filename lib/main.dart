import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/expenses/data/models/expense_model.dart';
import 'features/expenses/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register the Expense adapter so Hive knows how to store it
 //// Hive.registerAdapter(ExpenseAdapter());

  // Open the expenses box (like a database table)
  await Hive.openBox<Expense>('expenses');

  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
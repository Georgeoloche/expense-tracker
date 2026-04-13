import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/expenses/data/models/expense_model.dart';
import 'features/expenses/presentation/screens/home_screen.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive for local storage
  await Hive.initFlutter();

  // 3. Register the Expense adapter
  // Added isAdapterRegistered check to prevent errors during Hot Restarts
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ExpenseAdapter());
  }

  // 4. Open the expenses box
  // We specify <Expense> to ensure type safety throughout the app
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
        // Using Nunito globally to match your UI design
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Nunito'),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
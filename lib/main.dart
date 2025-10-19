import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Still needed for Chart functionality

// Import other files
import 'auth_screens.dart';
import 'main_navigation_screen.dart';
import 'app_screens.dart';

// --- Main Application Setup ---
void main() {
  runApp(
    ChangeNotifierProvider<TransactionData>(
      create: (BuildContext context) => TransactionData(),
      child: const MyApp(),
    ),
  );
}

// --- DATA MODEL ---
class Transaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final IconData icon;
  final Color color;
  final String category;

  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.isExpense,
    required this.icon,
    required this.color,
    required this.category,
  });

  String get formattedAmount {
    final sign = isExpense ? '-' : '+';
    return '$sign ₹ ${amount.toStringAsFixed(2)}';
  }
}

class TransactionData extends ChangeNotifier {
  final List<Transaction> _transactions;

  List<Transaction> get transactions => _transactions;

  TransactionData() : _transactions = _generateDummyTransactions();

  static List<Transaction> _generateDummyTransactions() {
    return [
      Transaction(
        id: '1',
        title: 'Rythu Bazar Vegetables',
        description: 'Weekly grocery shopping at local market',
        amount: 550.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
        isExpense: true,
        icon: Icons.local_grocery_store,
        color: Colors.redAccent,
        category: 'Groceries',
      ),
      Transaction(
        id: '2',
        title: 'Salary Deposit (IT Firm)',
        description: 'Monthly salary credit from employer',
        amount: 75000.00,
        date: DateTime.now().subtract(const Duration(days: 2)),
        isExpense: false,
        icon: Icons.account_balance_wallet,
        color: Colors.green,
        category: 'Income',
      ),
      Transaction(
        id: '3',
        title: 'RTC Bus Ticket',
        description: 'Commute to office by state bus',
        amount: 80.00,
        date: DateTime.now().subtract(const Duration(hours: 5)),
        isExpense: true,
        icon: Icons.directions_bus,
        color: Colors.redAccent,
        category: 'Transport',
      ),
      Transaction(
        id: '4',
        title: 'APSPDCL Electricity Bill',
        description: 'Monthly electricity bill payment',
        amount: 1200.00,
        date: DateTime.now().subtract(const Duration(days: 7)),
        isExpense: true,
        icon: Icons.lightbulb_outline,
        color: Colors.redAccent,
        category: 'Bills',
      ),
      Transaction(
        id: '5',
        title: 'Online Shopping (Flipkart)',
        description: 'New shirt and trousers',
        amount: 1499.00,
        date: DateTime.now().subtract(const Duration(days: 3)),
        isExpense: true,
        icon: Icons.shopping_bag_outlined,
        color: Colors.redAccent,
        category: 'Shopping',
      ),
      Transaction(
        id: '6',
        title: 'Movie Tickets (Telugu Film)',
        description: 'Watched "Pushpa 2" at local cinema',
        amount: 400.00,
        date: DateTime.now().subtract(const Duration(days: 4)),
        isExpense: true,
        icon: Icons.movie_filter,
        color: Colors.redAccent,
        category: 'Entertainment',
      ),
      Transaction(
        id: '7',
        title: 'Freelance Project Payment',
        description: 'Payment for web development project',
        amount: 15000.00,
        date: DateTime.now().subtract(const Duration(days: 10)),
        isExpense: false,
        icon: Icons.work,
        color: Colors.green,
        category: 'Income',
      ),
      Transaction(
        id: '8',
        title: 'Tiffin at Local Hotel',
        description: 'Breakfast - idli and dosa',
        amount: 100.00,
        date: DateTime.now().subtract(const Duration(hours: 10)),
        isExpense: true,
        icon: Icons.restaurant,
        color: Colors.redAccent,
        category: 'Food & Dining',
      ),
      Transaction(
        id: '9',
        title: 'Children School Fees',
        description: 'Quarterly payment for primary school',
        amount: 5000.00,
        date: DateTime.now().subtract(const Duration(days: 15)),
        isExpense: true,
        icon: Icons.school,
        color: Colors.redAccent,
        category: 'Education',
      ),
      Transaction(
        id: '10',
        title: 'Jio Fiber Internet Bill',
        description: 'Monthly broadband internet subscription',
        amount: 999.00,
        date: DateTime.now().subtract(const Duration(days: 20)),
        isExpense: true,
        icon: Icons.wifi,
        color: Colors.redAccent,
        category: 'Bills',
      ),
      Transaction(
        id: '11',
        title: 'Medical Consultation',
        description: 'Doctor visit for common cold',
        amount: 300.00,
        date: DateTime.now().subtract(const Duration(days: 6)),
        isExpense: true,
        icon: Icons.medical_services,
        color: Colors.redAccent,
        category: 'Medical',
      ),
      Transaction(
        id: '12',
        title: 'ATM Withdrawal',
        description: 'Cash for daily expenses',
        amount: 2000.00,
        date: DateTime.now().subtract(const Duration(days: 5)),
        isExpense: true,
        icon: Icons.atm,
        color: Colors.redAccent,
        category: 'Other',
      ),
    ];
  }

  void addTransaction({
    required String title,
    required String category,
    required double amount,
    String? description,
    bool isExpense = true,
  }) {
    Color color = isExpense ? Colors.redAccent : Colors.green;
    IconData icon = Icons.label_important_outline;

    if (isExpense) {
      switch (category) {
        case 'Food & Dining':
          icon = Icons.restaurant;
          break;
        case 'Transport':
          icon = Icons.directions_car;
          break;
        case 'Rent':
          icon = Icons.home;
          break;
        case 'Groceries':
          icon = Icons.shopping_basket;
          break;
        case 'Entertainment':
          icon = Icons.movie;
          break;
        case 'Bills':
          icon = Icons.receipt;
          break;
        case 'Shopping':
          icon = Icons.shopping_bag;
          break;
        case 'Education':
          icon = Icons.school;
          break;
        case 'Medical':
          icon = Icons.medical_services;
          break;
        case 'Income':
        default:
          icon = Icons.label_important_outline;
      }
    } else {
      icon = Icons.savings;
    }

    final newTransaction = Transaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: description ?? title,
      amount: amount,
      date: DateTime.now(),
      isExpense: isExpense,
      icon: icon,
      color: color,
      category: category,
    );
    _transactions.insert(0, newTransaction);
    notifyListeners();
  }
}

// Simple User Profile Data Model (for display purposes)
class UserProfile {
  final String fullName;
  final String email;
  final String uid;
  final String profileImageUrl;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.uid,
    required this.profileImageUrl,
  });
}

// --- Main App Widget ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF4A00E0),
          elevation: 0,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

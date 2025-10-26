import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// Import other files
import 'auth_screens.dart';
import 'main_navigation_screen.dart';
import 'app_screens.dart';

// --- Main Application Setup ---
void main() {
  // Ensure Flutter widgets are initialized before assets are loaded
  WidgetsFlutterBinding.ensureInitialized();

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

  // Factory constructor to create a Transaction from a JSON map (for Week 3 API/JSON requirement)
  factory Transaction.fromJson(Map<String, dynamic> json) {
    final bool isExpense = json['isExpense'] as bool? ?? true;
    final String category = json['category'] as String? ?? 'Other';

    // Determine icon and color based on category and expense type
    IconData icon = isExpense ? Icons.label_important_outline : Icons.savings;
    Color color = isExpense ? Colors.redAccent : Colors.green;

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
        default:
          icon = Icons.label_important_outline;
      }
    } else {
      icon = Icons.savings;
    }

    return Transaction(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      isExpense: isExpense,
      icon: icon,
      color: color,
      category: category,
    );
  }

  String get formattedAmount {
    final sign = isExpense ? '-' : '+';
    return '$sign ₹ ${amount.toStringAsFixed(2)}';
  }
}

class TransactionData extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TransactionData() {
    _loadInitialData();
  }

  // New method to load data from JSON asset file
  Future<void> _loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay (2 seconds) for a real-world API feel
      await Future<void>.delayed(const Duration(seconds: 2));

      // Load the JSON string from assets/transactions.json
      final String jsonString =
          await rootBundle.loadString('assets/transactions.json');

      // Decode the JSON string
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      // Map to Transaction objects
      _transactions = jsonList
          .map((dynamic item) =>
              Transaction.fromJson(item as Map<String, dynamic>))
          .toList();

      // Sort to show newest first
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print('Error loading transactions from JSON: $e');
      _errorMessage =
          'Failed to load initial transactions. Check pubspec.yaml and assets.';
      _transactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Your existing addTransaction method remains the same and uses the same icon/color logic
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
        case 'Other':
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

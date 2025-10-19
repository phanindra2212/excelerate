import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import local files
import 'main.dart';
import 'app_screens.dart';

// --- Quick Add Modal Bottom Sheet ---
class QuickAddTransactionSheet extends StatefulWidget {
  const QuickAddTransactionSheet({super.key});

  @override
  State<QuickAddTransactionSheet> createState() =>
      _QuickAddTransactionSheetState();
}

class _QuickAddTransactionSheetState extends State<QuickAddTransactionSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  static const List<String> categories = [
    'Food & Dining',
    'Transport',
    'Rent',
    'Groceries',
    'Entertainment',
    'Bills',
    'Shopping',
    'Education',
    'Medical',
    'Other',
  ];
  String? _selectedCategory;

  // Helper to get the minimalist decoration from auth_screens.dart
  InputDecoration _minimalistInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.indigo.shade400,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: Colors.indigo.shade400),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
      ),
      filled: true,
      fillColor: Colors.indigo.shade50.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Add Expense',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A00E0),
            ),
          ),
          const Divider(color: Colors.indigo, thickness: 1.5),
          const SizedBox(height: 16),
          // 1. Amount Input
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: _minimalistInputDecoration(
              label: 'Amount (₹)',
              icon: Icons.currency_rupee,
            ).copyWith(
              fillColor: Colors.indigo.shade50.withOpacity(0.8),
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 24),
          // 2. Title/Description Input
          TextFormField(
            controller: _titleController,
            keyboardType: TextInputType.text,
            decoration: _minimalistInputDecoration(
              label: 'Title/Description',
              icon: Icons.edit_note,
            ).copyWith(fillColor: Colors.indigo.shade50.withOpacity(0.8)),
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 24),
          // 3. Category Dropdown
          DropdownButtonFormField<String>(
            decoration: _minimalistInputDecoration(
              label: 'Category',
              icon: Icons.category_outlined,
            ).copyWith(fillColor: Colors.indigo.shade50.withOpacity(0.8)),
            initialValue: _selectedCategory,
            hint: const Text('Select Category'),
            isExpanded: true,
            items: categories.map<DropdownMenuItem<String>>((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
          ),
          const SizedBox(height: 32),
          // 4. Save Button
          ElevatedButton(
            onPressed: () {
              final double? amount = double.tryParse(_amountController.text);
              if (amount != null &&
                  amount > 0 &&
                  _selectedCategory != null &&
                  _titleController.text.isNotEmpty) {
                Provider.of<TransactionData>(
                  context,
                  listen: false,
                ).addTransaction(
                  title: _titleController.text,
                  category: _selectedCategory!,
                  amount: amount,
                  isExpense: true,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Expense added: ₹${amount.toStringAsFixed(2)} to $_selectedCategory',
                    ),
                  ),
                );
                Navigator.pop(context); // Close the sheet
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please enter a valid amount (>0), title, and select a category.',
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            child: const Text(
              'SAVE TRANSACTION',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- MAIN NAVIGATION SCREEN ---
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TransactionsScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddTransactionSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return const QuickAddTransactionSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionSheet,
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

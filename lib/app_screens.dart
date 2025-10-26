import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

// Import data models and other screens
import 'main.dart'; // Import Transaction, TransactionData, UserProfile
import 'auth_screens.dart'; // Import LoginPage

// --- Reusable Transaction Tile Widget ---
class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({required this.transaction, super.key});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: transaction.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(transaction.icon, color: transaction.color),
          ),
          title: Text(
            transaction.title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${_formatDate(transaction.date)} · ${transaction.category}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            transaction.formattedAmount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transaction.color,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// --- CORE APP SCREENS ---

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildBalanceCard(BuildContext context, String balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4A00E0),
            Color(0xFF8E2DE2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade200.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Balance',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            balance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    String total,
    String spent,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Budget (Active)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget: $total',
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
              Text(
                'Spent: $spent',
                style: const TextStyle(fontSize: 14, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.indigo.shade50,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? Colors.red : Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% Used',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TransactionData transactionData =
        Provider.of<TransactionData>(context);
    final List<Transaction> allTransactions = transactionData.transactions;
    final bool isLoading = transactionData.isLoading;
    final String? errorMessage = transactionData.errorMessage;

    // --- Loading and Error Handling UI ---
    if (isLoading) {
      return const Scaffold(
        appBar: AppBar(title: Text('Home')),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4A00E0),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: $errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.redAccent),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    }
    // --- End Loading and Error Handling UI ---

    // Calculation logic (remains the same)
    double totalIncome = 0;
    double totalExpense = 0;
    for (final Transaction tx in allTransactions) {
      if (tx.isExpense) {
        totalExpense += tx.amount;
      } else {
        totalIncome += tx.amount;
      }
    }
    final double currentBalanceValue = totalIncome - totalExpense;
    final String currentBalance = '₹ ${currentBalanceValue.toStringAsFixed(2)}';
    const double monthlyBudgetLimit = 50000.00;
    final String monthlyBudget = '₹ ${monthlyBudgetLimit.toStringAsFixed(2)}';
    final String spent = '₹ ${totalExpense.toStringAsFixed(2)}';
    final double budgetProgress = totalExpense / monthlyBudgetLimit;

    final List<Transaction> recentTransactions =
        allTransactions.take(4).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hello, Welcome Back!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildBalanceCard(context, currentBalance),
            const SizedBox(height: 24),
            _buildBudgetCard(context, monthlyBudget, spent, budgetProgress),
            const SizedBox(height: 24),
            const Text(
              'Recent Expenses (This Month)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (recentTransactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'No recent transactions. Add one now!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...recentTransactions.map<Widget>(
                (Transaction tx) => TransactionTile(transaction: tx),
              ),
          ],
        ),
      ),
    );
  }
}

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionData transactionData =
        Provider.of<TransactionData>(context);
    final List<Transaction> allTransactions = transactionData.transactions;
    final bool isLoading = transactionData.isLoading;
    final String? errorMessage = transactionData.errorMessage;

    // --- Loading and Error Handling UI ---
    if (isLoading) {
      return const Scaffold(
        appBar: AppBar(title: Text('All Transactions')),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4A00E0)),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('All Transactions')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error loading data: $errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.redAccent),
            ),
          ),
        ),
      );
    }
    // --- End Loading and Error Handling UI ---

    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      body: allTransactions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 80, color: Color(0xFF4A00E0)),
                  SizedBox(height: 16),
                  Text(
                    'No Transactions Yet',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Your transaction history will appear here. Add your first expense!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: allTransactions.length,
              itemBuilder: (BuildContext context, int index) {
                final Transaction transaction = allTransactions[index];
                return TransactionTile(transaction: transaction);
              },
            ),
    );
  }
}

// Helper for ReportsScreen to format currency
String _formatCurrency(double amount) {
  return '₹ ${amount.toStringAsFixed(2)}';
}

// Helper for category colors in the PieChart
final Map<String, Color> _categoryColors = {
  'Food & Dining': Colors.orange.shade700,
  'Transport': Colors.blue.shade700,
  'Rent': Colors.purple.shade700,
  'Groceries': Colors.green.shade700,
  'Entertainment': Colors.pink.shade700,
  'Bills': Colors.deepOrange.shade700,
  'Shopping': Colors.teal.shade700,
  'Education': Colors.indigo.shade700,
  'Medical': Colors.red.shade700,
  'Other': Colors.grey.shade700,
  'Income': Colors.green.shade600,
};

Color _getCategoryColor(String category) {
  return _categoryColors[category] ?? Colors.cyan.shade700;
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Widget _buildSummaryItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Reports')),
      body: Consumer<TransactionData>(
        builder: (BuildContext context, TransactionData transactionData,
            Widget? child) {
          final List<Transaction> transactions = transactionData.transactions;
          final bool isLoading = transactionData.isLoading;
          final String? errorMessage = transactionData.errorMessage;

          if (isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: CircularProgressIndicator(color: Color(0xFF4A00E0)),
              ),
            );
          }

          if (errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error loading reports: $errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.redAccent),
                ),
              ),
            );
          }

          double totalIncome = 0.0;
          double totalExpense = 0.0;
          Map<String, double> categoryExpenses = {};

          for (final Transaction tx in transactions) {
            if (tx.isExpense) {
              totalExpense += tx.amount;
              categoryExpenses.update(
                tx.category,
                (double value) => value + tx.amount,
                ifAbsent: () => tx.amount,
              );
            } else {
              totalIncome += tx.amount;
            }
          }
          final double netBalance = totalIncome - totalExpense;

          final List<MapEntry<String, double>> sortedCategoryExpenses =
              categoryExpenses.entries.toList()
                ..sort(
                  (MapEntry<String, double> a, MapEntry<String, double> b) =>
                      b.value.compareTo(a.value),
                );

          final List<PieChartSectionData> pieSections =
              sortedCategoryExpenses.map<PieChartSectionData>((
            MapEntry<String, double> entry,
          ) {
            final double percentage =
                totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0;
            return PieChartSectionData(
              color: _getCategoryColor(entry.key),
              value: entry.value,
              title: '${percentage.toStringAsFixed(1)}%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black, blurRadius: 2)],
              ),
              showTitle: percentage > 5,
            );
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Overall Financial Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.shade200.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall Financial Summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            'Total Income',
                            _formatCurrency(totalIncome),
                            Colors.greenAccent,
                          ),
                          _buildSummaryItem(
                            'Total Expense',
                            _formatCurrency(totalExpense),
                            Colors.redAccent,
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white54, height: 32),
                      Center(
                        child: _buildSummaryItem(
                          'Net Balance',
                          _formatCurrency(netBalance),
                          netBalance >= 0
                              ? Colors.white
                              : Colors.redAccent.shade100,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Expenses by Category Chart
                const Text(
                  'Expenses by Category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (totalExpense == 0.0)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No expenses recorded yet.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Text(
                            'Add some transactions to see your spending breakdown.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(enabled: false),
                            startDegreeOffset: 270,
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: pieSections,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Legend for the pie chart
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: sortedCategoryExpenses.map<Widget>((
                          MapEntry<String, double> entry,
                        ) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getCategoryColor(entry.key),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${entry.key} (${_formatCurrency(entry.value)})',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ... (Rest of app_screens.dart, including ProfileScreen, remains the same)

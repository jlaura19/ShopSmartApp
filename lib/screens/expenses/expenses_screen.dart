import 'package:flutter/material.dart';
import 'package:smartshop_app/models/expense_model.dart';
import 'package:smartshop_app/services/firestore_service.dart';
import 'package:smartshop_app/widgets/empty_state.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<List<ExpenseModel>> _expensesStream;
  
  String _filterPeriod = 'All';

  @override
  void initState() {
    super.initState();
    _expensesStream = _firestoreService.watchExpenses();
  }

  List<ExpenseModel> _filterExpenses(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    return expenses.where((expense) {
      final expenseDay = DateTime(expense.expenseDate.year, expense.expenseDate.month, expense.expenseDate.day);
      
      switch (_filterPeriod) {
        case 'Today':
          return expenseDay == today;
        case 'Week':
          return expenseDay.isAfter(weekAgo);
        case 'Month':
          return expenseDay.isAfter(monthAgo);
        default:
          return true;
      }
    }).toList();
  }

  Map<String, double> _calculateByCategory(List<ExpenseModel> expenses) {
    final result = <String, double>{};
    for (final expense in expenses) {
      result[expense.category] = (result[expense.category] ?? 0) + expense.amount;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: _expensesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allExpenses = snapshot.data ?? [];
          final filteredExpenses = _filterExpenses(allExpenses);

          if (filteredExpenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses recorded',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start logging expenses to track spending',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          final totalExpenses = filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);
          final byCategory = _calculateByCategory(filteredExpenses);

          return Column(
            children: [
              // Summary Cards
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Total Expenses',
                            value: '\$${totalExpenses.toStringAsFixed(2)}',
                            icon: Icons.money_off,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Categories',
                            value: byCategory.length.toString(),
                            icon: Icons.category,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Entries',
                            value: filteredExpenses.length.toString(),
                            icon: Icons.receipt,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Today'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Week'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Month'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Category Summary
              if (byCategory.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'By Category',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...byCategory.entries.map((entry) {
                            final percentage = (entry.value / totalExpenses * 100);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentage / 100,
                                        minHeight: 6,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          _getCategoryColor(entry.key),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '\$${entry.value.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              // Expenses List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    return _buildExpenseCard(expense);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterPeriod == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterPeriod = label);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Category and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        label: Text(expense.category),
                        backgroundColor: _getCategoryColor(expense.category).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _getCategoryColor(expense.category),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(expense.expenseDate),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(expense.category),
                  ),
                ),
              ],
            ),
            if (expense.description != null && expense.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                expense.description!,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            // Delete Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _deleteExpense(expense.id),
                icon: const Icon(Icons.delete, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'rent':
        return Colors.red;
      case 'utilities':
        return Colors.blue;
      case 'supplies':
        return Colors.orange;
      case 'marketing':
        return Colors.purple;
      case 'food':
        return Colors.green;
      case 'transportation':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _deleteExpense(String expenseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteExpense(expenseId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting expense: $e')),
          );
        }
      }
    }
  }
}

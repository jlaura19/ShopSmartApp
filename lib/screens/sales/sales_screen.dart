import 'package:flutter/material.dart';
import 'package:smartshop_app/models/sale_model.dart';
import 'package:smartshop_app/services/firestore_service.dart';
import 'package:smartshop_app/widgets/empty_state.dart';
import 'add_sale_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<List<SaleModel>> _salesStream;
  
  String _filterPeriod = 'All'; // All, Today, Week, Month

  @override
  void initState() {
    super.initState();
    _salesStream = _firestoreService.watchSales();
  }

  List<SaleModel> _filterSales(List<SaleModel> sales) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = DateTime(now.year, now.month - 1, now.day);

    return sales.where((sale) {
      final saleDay = DateTime(sale.saleDate.year, sale.saleDate.month, sale.saleDate.day);
      
      switch (_filterPeriod) {
        case 'Today':
          return saleDay == today;
        case 'Week':
          return saleDay.isAfter(weekAgo);
        case 'Month':
          return saleDay.isAfter(monthAgo);
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: StreamBuilder<List<SaleModel>>(
        stream: _salesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allSales = snapshot.data ?? [];
          final filteredSales = _filterSales(allSales);

          if (filteredSales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.trending_up, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No sales recorded',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start recording sales to see them here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          // Calculate totals
          double totalRevenue = 0;
          for (final sale in filteredSales) {
            totalRevenue += sale.totalAmount;
          }
          int totalQuantity = filteredSales.fold(0, (sum, sale) => sum + sale.quantity);

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
                            title: 'Revenue',
                            value: '\$${totalRevenue.toStringAsFixed(2)}',
                            icon: Icons.money,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Items Sold',
                            value: totalQuantity.toString(),
                            icon: Icons.shopping_cart,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSummaryCard(
                            title: 'Transactions',
                            value: filteredSales.length.toString(),
                            icon: Icons.receipt,
                            color: Colors.orange,
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
              // Sales List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredSales.length,
                  itemBuilder: (context, index) {
                    final sale = filteredSales[index];
                    return _buildSaleCard(sale);
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
            MaterialPageRoute(builder: (_) => const AddSaleScreen()),
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

  Widget _buildSaleCard(SaleModel sale) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Product and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(sale.saleDate),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${sale.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Details Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailBadge('Qty: ${sale.quantity}', Colors.blue),
                _buildDetailBadge('\$${sale.pricePerUnit.toStringAsFixed(2)}/unit', Colors.orange),
              ],
            ),
            if (sale.notes != null && sale.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                sale.notes!,
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
                onPressed: () => _deleteSale(sale.id),
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

  Widget _buildDetailBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteSale(String saleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sale'),
        content: const Text('Are you sure you want to delete this sale?'),
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
        await _firestoreService.deleteSale(saleId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sale deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting sale: $e')),
          );
        }
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:smartshop_app/services/analytics_service.dart';
import 'package:smartshop_app/widgets/kpi_card.dart';
import 'package:smartshop_app/widgets/analytics_charts.dart';
import 'package:smartshop_app/widgets/empty_state.dart';
import '../profile/profile_screen.dart';
import '../products/products_screen.dart';
import '../sales/sales_screen.dart';
import '../expenses/expenses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardTab(),
    const ProductsScreen(),
    const SalesScreen(),
    const ExpensesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartShop'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  late AnalyticsService _analyticsService;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _analyticsService = AnalyticsService();
  }

  void _updateDateRange(int days) {
    setState(() {
      _endDate = DateTime.now();
      _startDate = DateTime.now().subtract(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Range Selector
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildDateButton('7D', 7),
                          const SizedBox(width: 8),
                          _buildDateButton('30D', 30),
                          const SizedBox(width: 8),
                          _buildDateButton('90D', 90),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _selectCustomDateRange,
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Custom'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_startDate.toString().split(' ')[0]} to ${_endDate.toString().split(' ')[0]}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // KPI Grid
            FutureBuilder<KPIData>(
              future: _analyticsService.getKPIData(_startDate, _endDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState(message: 'Loading KPI data...');
                }
                if (snapshot.hasError) {
                  return ErrorState(
                    message: 'Failed to load KPI data',
                    onRetry: () => setState(() {}),
                  );
                }
                final kpiData = snapshot.data;
                if (kpiData == null) {
                  return const EmptyState(
                    icon: Icons.trending_up,
                    title: 'No Data',
                    message: 'No transactions recorded in this period',
                  );
                }
                return KPIGridView(kpiData: kpiData);
              },
            ),
            const SizedBox(height: 24),
            // Revenue vs Expenses Chart
            FutureBuilder<List<MonthlyComparisonData>>(
              future: _analyticsService.getMonthlyComparison(6),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState(message: 'Loading chart data...');
                }
                if (snapshot.hasError) {
                  return ErrorState(
                    message: 'Failed to load chart data',
                    onRetry: () => setState(() {}),
                  );
                }
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const EmptyState(
                    icon: Icons.bar_chart,
                    title: 'No Chart Data',
                    message: 'Record some sales to see your revenue trends',
                  );
                }
                return RevenueExpensesChart(data: data);
              },
            ),
            const SizedBox(height: 24),
            // Sales Trend Chart
            FutureBuilder<List<DailySalesData>>(
              future: _analyticsService.getSalesByDate(_endDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState(message: 'Loading sales trend...');
                }
                if (snapshot.hasError) {
                  return ErrorState(
                    message: 'Failed to load sales data',
                    onRetry: () => setState(() {}),
                  );
                }
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const EmptyState(
                    icon: Icons.show_chart,
                    title: 'No Sales Data',
                    message: 'Start recording sales to see your trends',
                  );
                }
                return SalesTrendChart(data: data);
              },
            ),
            const SizedBox(height: 24),
            // Expense Category Chart
            FutureBuilder<List<ExpenseByCategoryData>>(
              future: _analyticsService.getExpensesByCategory(_startDate, _endDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState(message: 'Loading expense data...');
                }
                if (snapshot.hasError) {
                  return ErrorState(
                    message: 'Failed to load expense data',
                    onRetry: () => setState(() {}),
                  );
                }
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const EmptyState(
                    icon: Icons.pie_chart,
                    title: 'No Expenses',
                    message: 'Log some expenses to see the breakdown',
                  );
                }
                return ExpenseCategoryChart(data: data);
              },
            ),
            const SizedBox(height: 24),
            // Top Products
            FutureBuilder<List<ProductSalesData>>(
              future: _analyticsService.getTopProducts(_startDate, _endDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState(message: 'Loading products...');
                }
                if (snapshot.hasError) {
                  return ErrorState(
                    message: 'Failed to load product data',
                    onRetry: () => setState(() {}),
                  );
                }
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const EmptyState(
                    icon: Icons.shopping_bag,
                    title: 'No Sales Yet',
                    message: 'Add products and record sales to see top performers',
                  );
                }
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top Products',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...data.map((product) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${product.quantity} units',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '\$${product.totalSales.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, int days) {
    final isSelected = _endDate.difference(_startDate).inDays == days;
    return ElevatedButton(
      onPressed: () => _updateDateRange(days),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(label),
    );
  }

  Future<void> _selectCustomDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
      });
    }
  }
}

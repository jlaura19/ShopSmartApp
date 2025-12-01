import 'package:smartshop_app/services/firestore_service.dart';

class AnalyticsService {
  final FirestoreService _firestoreService = FirestoreService();

  /// Get KPI data for a date range
  Future<KPIData> getKPIData(DateTime startDate, DateTime endDate) async {
    final sales = await _firestoreService.getSalesByDateRange(startDate, endDate);
    final expenses = await _firestoreService.getExpensesByDateRange(startDate, endDate);

    final totalRevenue = sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
    final totalExpenses = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final totalSales = sales.length;
    final avgSaleValue = totalSales > 0 ? totalRevenue / totalSales : 0.0;

    return KPIData(
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      profit: totalRevenue - totalExpenses,
      totalSales: totalSales,
      avgSaleValue: avgSaleValue,
    );
  }

  /// Get sales by date for line chart (last 30 days)
  Future<List<DailySalesData>> getSalesByDate(DateTime endDate) async {
    final startDate = endDate.subtract(const Duration(days: 30));
    final sales = await _firestoreService.getSalesByDateRange(startDate, endDate);

    // Group sales by date
    final Map<String, double> salesByDate = {};
    for (final sale in sales) {
      final dateKey = '${sale.saleDate.month}/${sale.saleDate.day}';
      salesByDate[dateKey] = (salesByDate[dateKey] ?? 0) + sale.totalAmount;
    }

    // Create list of daily data
    final List<DailySalesData> dailyData = [];
    for (int i = 30; i >= 0; i--) {
      final date = endDate.subtract(Duration(days: i));
      final dateKey = '${date.month}/${date.day}';
      final amount = salesByDate[dateKey] ?? 0;
      dailyData.add(DailySalesData(
        date: date,
        sales: amount,
      ));
    }

    return dailyData;
  }

  /// Get expenses by category
  Future<List<ExpenseByCategoryData>> getExpensesByCategory(DateTime startDate, DateTime endDate) async {
    final expenses = await _firestoreService.getExpensesByDateRange(startDate, endDate);

    // Group by category
    final Map<String, double> expensesByCategory = {};
    for (final expense in expenses) {
      expensesByCategory[expense.category] = (expensesByCategory[expense.category] ?? 0) + expense.amount;
    }

    // Convert to list
    return expensesByCategory.entries
        .map((e) => ExpenseByCategoryData(category: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  /// Get top selling products
  Future<List<ProductSalesData>> getTopProducts(DateTime startDate, DateTime endDate) async {
    final sales = await _firestoreService.getSalesByDateRange(startDate, endDate);

    // Group by product
    final Map<String, ProductSalesData> productSales = {};
    for (final sale in sales) {
      if (productSales.containsKey(sale.productId)) {
        final existing = productSales[sale.productId]!;
        productSales[sale.productId] = ProductSalesData(
          productId: sale.productId,
          productName: sale.productName,
          totalSales: existing.totalSales + sale.totalAmount,
          quantity: existing.quantity + sale.quantity,
        );
      } else {
        productSales[sale.productId] = ProductSalesData(
          productId: sale.productId,
          productName: sale.productName,
          totalSales: sale.totalAmount,
          quantity: sale.quantity,
        );
      }
    }

    // Sort by revenue
    final list = productSales.values.toList();
    list.sort((a, b) => b.totalSales.compareTo(a.totalSales));
    return list.take(5).toList();
  }

  /// Get monthly comparison data
  Future<List<MonthlyComparisonData>> getMonthlyComparison(int months) async {
    final now = DateTime.now();
    final List<MonthlyComparisonData> monthlyData = [];

    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(date.year, date.month + 1, 1);
      
      final kpiData = await getKPIData(date, nextMonth.subtract(const Duration(days: 1)));
      
      monthlyData.add(MonthlyComparisonData(
        month: _getMonthName(date.month),
        revenue: kpiData.totalRevenue,
        expenses: kpiData.totalExpenses,
        profit: kpiData.profit,
      ));
    }

    return monthlyData;
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

/// Models for analytics data

class KPIData {
  final double totalRevenue;
  final double totalExpenses;
  final double profit;
  final int totalSales;
  final double avgSaleValue;

  KPIData({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.profit,
    required this.totalSales,
    required this.avgSaleValue,
  });

  double get profitMargin {
    if (totalRevenue == 0) return 0;
    return (profit / totalRevenue) * 100;
  }
}

class DailySalesData {
  final DateTime date;
  final double sales;

  DailySalesData({required this.date, required this.sales});
}

class ExpenseByCategoryData {
  final String category;
  final double amount;

  ExpenseByCategoryData({required this.category, required this.amount});
}

class ProductSalesData {
  final String productId;
  final String productName;
  final double totalSales;
  final int quantity;

  ProductSalesData({
    required this.productId,
    required this.productName,
    required this.totalSales,
    required this.quantity,
  });
}

class MonthlyComparisonData {
  final String month;
  final double revenue;
  final double expenses;
  final double profit;

  MonthlyComparisonData({
    required this.month,
    required this.revenue,
    required this.expenses,
    required this.profit,
  });
}
